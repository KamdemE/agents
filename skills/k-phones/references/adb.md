# Wireless ADB over Tailscale

Use raw `adb`; there are no helper wrappers or saved address/port configuration.

## Routine connection

1. Keep the workstation and phone on the same Tailscale network.
2. On the phone, open **Developer options → Wireless debugging** and read the **current debug port** from the main screen.
3. Check the phone's Tailscale IP. If it is uncertain, run `tailscale status` on the workstation.
4. Connect and verify:

```bash
adb connect 100.125.54.1:<DEBUG_PORT>
adb devices -l
```

Current known example:

```bash
adb connect 100.125.54.1:42177
# connected to 100.125.54.1:42177
```

The debug port is volatile. Always use the live value shown by Android; do not treat the example as a default.

## First connection or re-pairing

Pairing authorizes the workstation; connecting opens an ADB session. They use different ports.

1. In **Wireless debugging**, choose **Pair device with QR code** and use Android Studio's QR pairing flow; or choose **Pair device with pairing code**.
2. For a pairing code, use the displayed pairing address and port:

```bash
adb pair ADDRESS:PAIRING_PORT
```

3. Return to the main Wireless Debugging screen and connect with its separate debug port:

```bash
adb connect 100.125.54.1:<DEBUG_PORT>
adb devices -l
```

Never use `adb pair` with the main-screen debug port. A successful pair alone does not create a connected device.

## Common commands

```bash
adb shell
adb install -r app.apk
adb push local-file /sdcard/Download/
adb pull /sdcard/Download/file .
scrcpy -s 100.125.54.1:<DEBUG_PORT>
adb disconnect
```
