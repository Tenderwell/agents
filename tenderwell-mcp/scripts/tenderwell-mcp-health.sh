#!/usr/bin/env bash

set -euo pipefail

HOSTED_ENDPOINT="https://tenderwell.com/mcp"
LOCAL_ENDPOINT="http://localhost:8088/mcp"
CURL_TIMEOUT_SECONDS="${CURL_TIMEOUT_SECONDS:-10}"

if [ "$#" -gt 0 ]; then
  ENDPOINTS=("$@")
else
  ENDPOINTS=("$HOSTED_ENDPOINT" "$LOCAL_ENDPOINT")
fi

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

parse_status_code() {
  awk 'toupper($1) ~ /^HTTP\// { code=$2 } END { if (code != "") print code }' "$1"
}

extract_session_id() {
  python3 - "$1" <<'PY'
import pathlib
import re
import sys

headers = pathlib.Path(sys.argv[1]).read_text()
match = re.search(r"(?im)^Mcp-Session-Id:\s*(.+?)\s*$", headers)
if match:
    print(match.group(1).strip())
PY
}

extract_tool_names() {
  python3 - "$1" <<'PY'
import json
import pathlib
import sys

body = pathlib.Path(sys.argv[1]).read_text()
payload = json.loads(body)
tools = payload.get("result", {}).get("tools", [])
for tool in tools:
    name = tool.get("name")
    if name:
        print(name)
PY
}

summarize_error() {
  python3 - "$1" <<'PY'
import json
import pathlib
import sys

body = pathlib.Path(sys.argv[1]).read_text().strip()
if not body:
    print("empty response body")
    raise SystemExit

try:
    payload = json.loads(body)
except json.JSONDecodeError:
    print(body[:200].replace("\n", " "))
    raise SystemExit

error = payload.get("error")
if isinstance(error, dict):
    code = error.get("code")
    message = error.get("message")
    if code is not None and message:
        print(f"error {code}: {message}")
    elif message:
        print(message)
    else:
        print(json.dumps(error))
else:
    print(body[:200].replace("\n", " "))
PY
}

run_initialize() {
  local endpoint="$1"
  local headers_file="$2"
  local body_file="$3"

  curl -sS \
    --max-time "$CURL_TIMEOUT_SECONDS" \
    -D "$headers_file" \
    -o "$body_file" \
    -X POST "$endpoint" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    --data '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"tenderwell-mcp-health","version":"1.0"}}}'
}

run_tools_list() {
  local endpoint="$1"
  local session_id="$2"
  local headers_file="$3"
  local body_file="$4"

  curl -sS \
    --max-time "$CURL_TIMEOUT_SECONDS" \
    -D "$headers_file" \
    -o "$body_file" \
    -X POST "$endpoint" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    -H "Mcp-Session-Id: $session_id" \
    --data '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'
}

for endpoint in "${ENDPOINTS[@]}"; do
  init_headers="$tmpdir/init.headers"
  init_body="$tmpdir/init.body"
  tools_headers="$tmpdir/tools.headers"
  tools_body="$tmpdir/tools.body"

  printf 'Checking %s\n' "$endpoint"

  if ! run_initialize "$endpoint" "$init_headers" "$init_body"; then
    printf 'FAIL initialize: transport error for %s\n' "$endpoint" >&2
    continue
  fi

  init_status="$(parse_status_code "$init_headers")"
  if [ "$init_status" != "200" ]; then
    init_error="$(summarize_error "$init_body")"
    printf 'FAIL initialize: HTTP %s from %s (%s)\n' "$init_status" "$endpoint" "$init_error" >&2
    continue
  fi

  session_id="$(extract_session_id "$init_headers")"
  if [ -z "$session_id" ]; then
    printf 'FAIL initialize: missing Mcp-Session-Id from %s\n' "$endpoint" >&2
    continue
  fi

  printf 'OK initialize: %s\n' "$endpoint"

  if ! run_tools_list "$endpoint" "$session_id" "$tools_headers" "$tools_body"; then
    printf 'FAIL tools/list: transport error for %s\n' "$endpoint" >&2
    continue
  fi

  tools_status="$(parse_status_code "$tools_headers")"
  if [ "$tools_status" != "200" ]; then
    tools_error="$(summarize_error "$tools_body")"
    printf 'FAIL tools/list: HTTP %s from %s (%s)\n' "$tools_status" "$endpoint" "$tools_error" >&2
    continue
  fi

  if ! tool_names="$(extract_tool_names "$tools_body")"; then
    printf 'FAIL tools/list: could not parse tool list from %s\n' "$endpoint" >&2
    continue
  fi

  if [ -z "$tool_names" ]; then
    printf 'FAIL tools/list: empty tool list from %s\n' "$endpoint" >&2
    continue
  fi

  printf 'OK tools/list: %s\n' "$endpoint"
  printf 'OK using endpoint: %s\n' "$endpoint"
  if [ "$endpoint" = "$LOCAL_ENDPOINT" ]; then
    printf 'NOTE local development endpoint selected after hosted fallback\n'
  fi

  if [ -n "$tool_names" ]; then
    printf 'TOOLS %s\n' "$(printf '%s' "$tool_names" | tr '\n' ' ' | sed 's/[[:space:]]*$//')"
  fi
  exit 0
done

printf 'FAIL no usable Tenderwell MCP endpoint found\n' >&2
printf 'Tried endpoints: %s\n' "${ENDPOINTS[*]}" >&2
exit 1
