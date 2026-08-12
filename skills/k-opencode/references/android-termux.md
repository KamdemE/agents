# Android / Termux — Incompatible (upstream limitation)

OpenCode does **not** ship Android-compatible binaries. The Linux ARM64 build fails on Termux with:

```
error: "...opencode" has unexpected e_type: 2
```

**Root cause:** The released Linux ARM64 binary is a non-PIE (`ET_EXEC`) glibc executable. Android's `linker64` rejects non-PIE binaries, and Termux uses bionic libc (not glibc).

**Upstream issue:** [`anomalyco/opencode#11689`](https://github.com/anomalyco/opencode/issues/11689) — feature request for Android ARM64 support (unresolved as of 2026-07).

**Workarounds tested on kpihx-s25 (Snapdragon 8 Elite, Android 16):**

| Method | Verdict | Detail |
|--------|---------|--------|
| `termux-elf-cleaner` | ❌ Fails | Fixes TLS alignment but `e_type` remains `ET_EXEC` |
| `patchelf` + glibc-runner | ❌ Fails | Binary is non-PIE regardless of interpreter |
| `proot -0` | ⚠️ Partial | Runs but adds overhead; not practical for daily use |
| `proot-distro ubuntu` | ✅ Works | Full Ubuntu ARM64 in proot — opencode runs normally inside |
| Build from source with `-buildmode=pie` | ✅ Guaranteed | `CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -buildmode=pie` produces a static PIE binary that Termux can exec directly |

**Recommendation for S25/Android devices:** Use `proot-distro login ubuntu` to run opencode in a glibc environment, or build from source with `-buildmode=pie`.
