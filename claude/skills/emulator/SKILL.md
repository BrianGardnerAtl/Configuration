# Android Emulator Manager

Manage Android Virtual Devices (AVDs) using the Android SDK command-line tools.

User request: $ARGUMENTS

Parse the operation and any arguments from the request, then follow the instructions below.

---

## Tool Resolution

Before executing any operation, resolve the paths for `avdmanager`, `emulator`, `adb`, and `sdkmanager`.

1. Check if each binary is available on PATH.
2. For any that are not found, fall back to `$ANDROID_HOME` (or `$ANDROID_SDK_ROOT` if `$ANDROID_HOME` is unset):

   | Binary        | Fallback path                                          |
   |---------------|--------------------------------------------------------|
   | `emulator`    | `$ANDROID_HOME/emulator/emulator`                      |
   | `adb`         | `$ANDROID_HOME/platform-tools/adb`                     |
   | `avdmanager`  | `$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager`    |
   | `sdkmanager`  | `$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager`    |

3. If a required binary is not found via PATH or the fallback, stop immediately and tell the user which tool is missing and suggest checking the SDK location in Android Studio under **Settings > SDK Manager**.

Use the resolved paths for all commands in the operation.

---

## Operations

### list

Show all configured AVDs and which are currently running.

```bash
avdmanager list avd
adb devices
```

Cross-reference the two outputs to show a unified view: AVD name, API level, device profile, and whether it is currently running (and on which port if so).

---

### create \<name\> [--api \<level\>] [--device \<device-id\>]

**Defaults:** `--api 35`, `--device pixel_6`, image type `google_apis_playstore`

1. Detect host architecture to select the correct ABI:
   ```bash
   uname -m
   ```
   - Apple Silicon (`arm64`): use `arm64-v8a`
   - Intel (`x86_64`): use `x86_64`

2. Check if the required system image is already installed:
   ```bash
   sdkmanager --list 2>/dev/null | grep "Installed" -A 9999 | grep "system-images;android-<api>"
   ```

3. If not installed, install it:
   ```bash
   sdkmanager "system-images;android-<api>;google_apis_playstore;<abi>"
   ```

4. Create the AVD:
   ```bash
   avdmanager create avd \
     -n <name> \
     -k "system-images;android-<api>;google_apis_playstore;<abi>" \
     -d <device-id>
   ```

5. Confirm it was created:
   ```bash
   avdmanager list avd | grep <name>
   ```

If the user specifies a screen size instead of a device ID (e.g. "phone", "tablet", "large"), map it to a reasonable device profile:
- phone / default → `pixel_6`
- small phone → `pixel_4`
- large phone → `pixel_7_pro`
- tablet → `pixel_tablet`
- foldable → `pixel_fold`

---

### delete \<name\>

```bash
avdmanager delete avd -n <name>
```

---

### start \<name\>

```bash
emulator @<name> &
```

Wait a moment, then confirm it started:
```bash
adb devices
```

---

### stop [\<name\>]

First, get all running emulators and resolve each one to its AVD name:

```bash
adb devices
# For each emulator-XXXX listed:
adb -s emulator-XXXX emu avd name
```

**If a name was provided in the request:**
Find the running instance whose AVD name matches, then stop it:
```bash
adb -s emulator-XXXX emu kill
```

**If no name was provided:**
Present a numbered list of running emulators with their AVD names, for example:
```
Running emulators:
  1. Pixel6_API35 (emulator-5554)
  2. Pixel4_API33 (emulator-5556)

Which emulator would you like to stop?
```
Wait for the user to choose, then stop the selected one.

If no emulators are running, say so clearly and exit.

---

### versions [--available] [--api \<level\>]

Show version information for emulator tooling and system images.

**Default (no flags):** Show installed versions only.

1. Show the emulator binary version:
   ```bash
   emulator -version
   ```

2. List installed system images:
   ```bash
   sdkmanager --list 2>/dev/null | grep "system-images/" | grep "Installed"
   ```
   Present as a table: API level, image type, ABI.

**With `--available`:** Also show system images available for download.

3. List available (not yet installed) system images:
   ```bash
   sdkmanager --list 2>/dev/null | grep "system-images/"
   ```
   Group results by API level. If `--api <level>` is provided, filter to only that API level.

---

## Error Handling

- If a system image download is needed, show progress and wait for it to complete before creating the AVD.
- If an AVD with the requested name already exists during create, ask the user whether to overwrite or pick a different name.
