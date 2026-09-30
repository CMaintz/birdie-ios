#!/usr/bin/env bash
# Prints the UDID of an available iPhone simulator on the newest installed iOS 18 runtime.
set -euo pipefail
xcrun simctl list devices available -j | jq -r '
  [.devices | to_entries[]
    | select(.key | test("SimRuntime\.iOS-18"))
    | .key as $runtime
    | .value[]
    | select(.name | test("^iPhone 16( Pro)?$"))
    | {runtime: $runtime, name, udid}]
  | sort_by(.runtime) | reverse | .[0].udid // empty'
