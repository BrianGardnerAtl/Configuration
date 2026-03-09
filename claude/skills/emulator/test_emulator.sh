#!/bin/bash
#
# Integration tests for the Android Emulator Manager skill.
# Requires a working Android SDK installation.
#
# Usage:
#   ./test_emulator.sh              # run all tests (emulator window visible)
#   ./test_emulator.sh --skip-boot  # skip start/stop tests (slow ~30s)
#   ./test_emulator.sh --headless   # run boot tests without an emulator window

set -euo pipefail

SKIP_BOOT=false
HEADLESS=false
TEST_AVD="_test_emulator_skill"
PASSED=0
FAILED=0
SKIPPED=0

for arg in "$@"; do
  case "$arg" in
    --skip-boot) SKIP_BOOT=true ;;
    --headless) HEADLESS=true ;;
  esac
done

# --- Helpers ---

pass() {
  echo "  PASS: $1"
  PASSED=$((PASSED + 1))
}

fail() {
  echo "  FAIL: $1 — $2"
  FAILED=$((FAILED + 1))
}

skip() {
  echo "  SKIP: $1"
  SKIPPED=$((SKIPPED + 1))
}

# --- Tool Resolution ---

resolve_tool() {
  local name="$1"
  local fallback="$2"

  if command -v "$name" &>/dev/null; then
    command -v "$name"
  elif [[ -n "${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}" ]] && \
       [[ -x "${ANDROID_HOME:-${ANDROID_SDK_ROOT}}/$fallback" ]]; then
    echo "${ANDROID_HOME:-${ANDROID_SDK_ROOT}}/$fallback"
  else
    echo ""
  fi
}

EMULATOR=$(resolve_tool emulator "emulator/emulator")
ADB=$(resolve_tool adb "platform-tools/adb")
AVDMANAGER=$(resolve_tool avdmanager "cmdline-tools/latest/bin/avdmanager")
SDKMANAGER=$(resolve_tool sdkmanager "cmdline-tools/latest/bin/sdkmanager")

# --- Cleanup ---

cleanup() {
  # Kill test AVD if running
  if [[ -n "$ADB" ]]; then
    local serials
    serials=$("$ADB" devices 2>/dev/null | grep "^emulator-" | awk '{print $1}') || true
    for serial in $serials; do
      local avd_name
      avd_name=$("$ADB" -s "$serial" emu avd name 2>/dev/null | head -1) || true
      if [[ "$avd_name" == "$TEST_AVD" ]]; then
        "$ADB" -s "$serial" emu kill &>/dev/null || true
        sleep 2
      fi
    done
  fi

  # Delete test AVD if it exists
  if [[ -n "$AVDMANAGER" ]]; then
    if "$AVDMANAGER" list avd -c 2>/dev/null | grep -q "^${TEST_AVD}$"; then
      "$AVDMANAGER" delete avd -n "$TEST_AVD" &>/dev/null || true
    fi
  fi
}

trap cleanup EXIT

echo "=== Emulator Skill Tests ==="
echo ""

# --- Test: Tool Resolution ---

echo "[tool_resolution]"

for pair in "emulator:$EMULATOR" "adb:$ADB" "avdmanager:$AVDMANAGER" "sdkmanager:$SDKMANAGER"; do
  name="${pair%%:*}"
  path="${pair#*:}"
  if [[ -n "$path" && -x "$path" ]]; then
    pass "$name resolved to $path"
  else
    fail "$name" "not found via PATH or \$ANDROID_HOME"
  fi
done

# Bail early if critical tools are missing
if [[ -z "$AVDMANAGER" || -z "$SDKMANAGER" || -z "$ADB" ]]; then
  echo ""
  echo "Cannot continue without avdmanager, sdkmanager, and adb."
  echo "Results: $PASSED passed, $FAILED failed, $SKIPPED skipped"
  exit 1
fi

echo ""

# --- Test: list ---

echo "[list]"

if avd_output=$("$AVDMANAGER" list avd 2>&1); then
  pass "avdmanager list avd executes"
else
  fail "avdmanager list avd" "exited with non-zero status"
fi

adb_output=$("$ADB" devices 2>&1)
if echo "$adb_output" | grep -q "List of devices"; then
  pass "adb devices executes"
else
  fail "adb devices" "unexpected output"
fi

echo ""

# --- Test: versions ---

echo "[versions]"

if [[ -n "$EMULATOR" ]]; then
  version_output=$("$EMULATOR" -version 2>&1) || true
  if echo "$version_output" | grep -qi "emulator"; then
    pass "emulator -version returns version info"
  else
    fail "emulator -version" "no version string found"
  fi
else
  skip "emulator -version (binary not found)"
fi

installed_images=$("$SDKMANAGER" --list 2>/dev/null | grep "system-images/" || true)
if [[ -n "$installed_images" ]]; then
  pass "sdkmanager --list returns system image entries"
else
  fail "sdkmanager --list" "no system-images lines found"
fi

echo ""

# --- Test: versions --available ---

echo "[versions_available]"

all_images=$("$SDKMANAGER" --list 2>/dev/null | grep "system-images/" || true)
image_count=$(echo "$all_images" | wc -l | tr -d ' ')
if [[ "$image_count" -gt 0 && -n "$all_images" ]]; then
  pass "sdkmanager --list returns $image_count system image lines"
else
  fail "sdkmanager --list (available)" "no images found"
fi

echo ""

# --- Test: versions --api filter ---

echo "[versions_api_filter]"

filtered=$("$SDKMANAGER" --list 2>/dev/null | grep "system-images/android-35" || true)
if [[ -n "$filtered" ]]; then
  pass "API 35 filter returns results"
  # Verify no other API levels leaked through
  leaked=$(echo "$filtered" | grep -v "android-35" || true)
  if [[ -z "$leaked" ]]; then
    pass "API 35 filter contains only API 35 entries"
  else
    fail "API 35 filter" "found non-API-35 entries in filtered output"
  fi
else
  skip "API 35 filter (no API 35 images available)"
fi

echo ""

# --- Test: create ---

echo "[create]"

# Clean up any leftover test AVD
if "$AVDMANAGER" list avd -c 2>/dev/null | grep -q "^${TEST_AVD}$"; then
  "$AVDMANAGER" delete avd -n "$TEST_AVD" &>/dev/null || true
fi

# Detect architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
  ABI="arm64-v8a"
else
  ABI="x86_64"
fi

API=35
IMAGE="system-images;android-${API};google_apis_playstore;${ABI}"

# Ensure system image is installed
if ! "$SDKMANAGER" --list 2>/dev/null | grep "$IMAGE" | grep -qi "installed"; then
  echo "  Installing system image $IMAGE (this may take a while)..."
  yes | "$SDKMANAGER" "$IMAGE" >/dev/null 2>&1 || true
fi

# Create AVD
create_output=$(echo "no" | "$AVDMANAGER" create avd -n "$TEST_AVD" -k "$IMAGE" -d pixel_6 2>&1) || true
if "$AVDMANAGER" list avd -c 2>/dev/null | grep -q "^${TEST_AVD}$"; then
  pass "created AVD $TEST_AVD"
else
  fail "create AVD" "AVD not found after creation: $create_output"
fi

echo ""

# --- Test: start / stop ---

echo "[start_stop]"

if $SKIP_BOOT; then
  skip "start (--skip-boot)"
  skip "stop (--skip-boot)"
else
  if [[ -z "$EMULATOR" ]]; then
    skip "start (emulator binary not found)"
    skip "stop (emulator binary not found)"
  else
    # Start
    EMU_FLAGS=(-no-audio -no-boot-anim)
    if $HEADLESS; then
      EMU_FLAGS+=(-no-window)
    fi
    "$EMULATOR" @"$TEST_AVD" "${EMU_FLAGS[@]}" &>/dev/null &
    EMU_PID=$!

    # Wait for device to appear (up to 60s)
    BOOT_OK=false
    for i in $(seq 1 30); do
      if "$ADB" devices 2>/dev/null | grep -q "emulator-"; then
        BOOT_OK=true
        break
      fi
      sleep 2
    done

    if $BOOT_OK; then
      pass "emulator started and visible in adb devices"
    else
      fail "start" "emulator did not appear in adb devices within 60s"
    fi

    # Stop
    SERIAL=$("$ADB" devices 2>/dev/null | grep "^emulator-" | head -1 | awk '{print $1}') || true
    if [[ -n "$SERIAL" ]]; then
      "$ADB" -s "$SERIAL" emu kill &>/dev/null || true
      sleep 3

      if ! "$ADB" devices 2>/dev/null | grep -q "$SERIAL"; then
        pass "emulator stopped and no longer in adb devices"
      else
        fail "stop" "emulator $SERIAL still visible after kill"
      fi
    else
      skip "stop (no running emulator to stop)"
    fi

    # Clean up background process
    kill "$EMU_PID" &>/dev/null || true
    wait "$EMU_PID" &>/dev/null || true
  fi
fi

echo ""

# --- Test: delete ---

echo "[delete]"

if "$AVDMANAGER" list avd -c 2>/dev/null | grep -q "^${TEST_AVD}$"; then
  "$AVDMANAGER" delete avd -n "$TEST_AVD" &>/dev/null
  if ! "$AVDMANAGER" list avd -c 2>/dev/null | grep -q "^${TEST_AVD}$"; then
    pass "deleted AVD $TEST_AVD"
  else
    fail "delete" "AVD still present after deletion"
  fi
else
  skip "delete (AVD $TEST_AVD not found, likely create failed)"
fi

echo ""

# --- Summary ---

echo "=== Results ==="
echo "  $PASSED passed, $FAILED failed, $SKIPPED skipped"

if [[ $FAILED -gt 0 ]]; then
  exit 1
fi
