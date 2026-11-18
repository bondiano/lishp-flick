#!/usr/bin/env bash
# Runs the examples of the original lishp and checks their output byte for byte.
set -euo pipefail
cd "$(dirname "$0")"

BIN=${BIN:-./dist/flick-main}
if [ ! -x "$BIN" ]; then
  echo "build first: flick build --project . --emit go" >&2
  exit 1
fi

check() {
  local name=$1 expected=$2 input=${3-}
  local actual
  if [ -n "$input" ]; then
    actual=$(printf '%s\n' "$input" | "$BIN" run "examples/$name" 2>&1)
  else
    actual=$(printf '' | "$BIN" run "examples/$name" 2>&1)
  fi
  if [ "$actual" != "$expected" ]; then
    echo "FAIL $name" >&2
    printf 'expected:\n%s\nactual:\n%s\n' "$expected" "$actual" >&2
    exit 1
  fi
  echo "ok   $name"
}

check test_simple.lsp '42'
check test_factorial.lsp '"input a number"
120' 5
check expand_macro_demo.lsp '1
1
6
6
42
42'
check acc-class.lsp ''
check knight.lsp ''

echo "all examples match the original"
