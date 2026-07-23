#!/usr/bin/env zsh
# Install + register Termux:Boot (com.termux.boot). Prefers PC adb; falls back to Termux SSH.
# Skill: k-25 — see references/s25-termux-sshd.md

set -euo pipefail

readonly APK_URL="https://f-droid.org/repo/com.termux.boot_1000.apk"
readonly PKG="com.termux.boot"
readonly REMOTE="s25"
readonly LOCAL_APK="/tmp/termux-boot.apk"
readonly SKILL_ASSETS="${HOME}/.agents/skills/k-25/assets"

curl -fsSL -o "$LOCAL_APK" "$APK_URL"
echo "==> APK: $LOCAL_APK ($(wc -c <"$LOCAL_APK") bytes)"

_adb_ready() {
  adb devices 2>/dev/null | rg -q 'device$'
}

_ssh_ready() {
  ssh -o ConnectTimeout=6 -o BatchMode=yes "$REMOTE" true 2>/dev/null
}

_install_via_adb() {
  echo "==> ADB: disable install verification (Samsung / Play Protect)"
  adb shell settings put global verifier_verify_adb_installs 0 2>/dev/null || true
  adb shell settings put global package_verifier_enable 0 2>/dev/null || true
  echo "==> ADB: push + install $PKG"
  adb push "$LOCAL_APK" /data/local/tmp/termux-boot.apk
  adb shell pm install -r -t -g /data/local/tmp/termux-boot.apk
  adb shell rm -f /data/local/tmp/termux-boot.apk

  echo "==> ADB: open Termux:Boot once (register BOOT_COMPLETED)"
  adb shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 || \
    adb shell am start -a android.intent.action.MAIN -p "$PKG" >/dev/null 2>&1 || true

  echo "==> ADB: battery / background (best effort)"
  adb shell dumpsys deviceidle whitelist "+$PKG" "+com.termux" 2>/dev/null || true
  adb shell cmd appops set "$PKG" RUN_IN_BACKGROUND allow 2>/dev/null || true
  adb shell cmd appops set com.termux RUN_IN_BACKGROUND allow 2>/dev/null || true
}

_install_via_ssh_ui() {
  echo "==> SSH: stage APK on /sdcard/Download/"
  scp -q "$LOCAL_APK" "${REMOTE}:termux-boot.apk"
  ssh "$REMOTE" 'mkdir -p ~/storage/downloads 2>/dev/null; cp -f ~/termux-boot.apk ~/storage/downloads/termux-boot.apk 2>/dev/null || true
cp -f ~/termux-boot.apk /sdcard/Download/termux-boot.apk'
  echo "==> SSH: open system package installer (confirm Install on phone screen)"
  ssh "$REMOTE" 'am start -a android.intent.action.VIEW -d "file:///sdcard/Download/termux-boot.apk" -t application/vnd.android.package-archive'
}

_verify() {
  if _adb_ready; then
    adb shell pm list packages | grep -F "$PKG" && return 0
  fi
  if _ssh_ready; then
    ssh "$REMOTE" "cmd package list packages 2>/dev/null | grep -F '$PKG'" && return 0
  fi
  return 1
}

_deploy_boot_script() {
  echo "==> SSH: ensure ~/.termux/boot/sshd"
  if _ssh_ready; then
    zsh "${HOME}/.agents/skills/k-25/scripts/termux-deploy-sshd.sh"
  fi
}

if _adb_ready; then
  _install_via_adb
elif _ssh_ready; then
  echo "==> No ADB device — using SSH + on-screen Install tap"
  _install_via_ssh_ui
  print -u2 "\n⚠️  On the phone: tap **Install** on the package installer, then re-run:"
  print -u2 "    zsh $HOME/.agents/skills/k-25/scripts/termux-install-boot.sh"
  sleep 12
else
  echo "✗ Need adb device or ssh s25" >&2
  exit 1
fi

if _verify; then
  echo "==> ✓ $PKG installed"
  ssh "$REMOTE" '/system/bin/monkey -p com.termux.boot -c android.intent.category.LAUNCHER 1' 2>/dev/null || true
  _deploy_boot_script
else
  echo "==> $PKG not installed yet"
  if ! _adb_ready; then
    print -u2 "Enable Wireless debugging on S25, then: adb-s25 <PORT> && zsh $0"
  fi
  exit 2
fi

echo "==> done — reboot phone to test: ssh s25 without opening Termux"
