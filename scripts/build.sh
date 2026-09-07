#!/bin/bash
set -e

NDK_HOME="${ANDROID_NDK_HOME:-$HOME/android-ndk-r29}"

if [ ! -d "$NDK_HOME" ]; then
    echo "[ERROR] NDK not found at: $NDK_HOME"
    echo "Set ANDROID_NDK_HOME or place android-ndk-r29 in your home directory"
    exit 1
fi

echo "[BUILD] NDK: $NDK_HOME"
echo "[BUILD] Target: a37-A376BXXS4AZG4"

export PATH="$NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"

make TARGET=a37-A376BXXS4AZG4 ANDROID_NDK_HOME="$NDK_HOME"

echo ""
echo "[VERIFY] Checking output types..."
file build/a37-A376BXXS4AZG4/cve-2026-43499
file build/a37-A376BXXS4AZG4/cve-2026-43499-root
file build/a37-A376BXXS4AZG4/v2root

echo ""
echo "[DONE] Artifacts in build/a37-A376BXXS4AZG4/"
ls -lh build/a37-A376BXXS4AZG4/
