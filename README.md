# Galaxy A37 Root — CVE-2026-43499

Native payload for the **Samsung Galaxy A37 5G** (`SM-A376B`, firmware
`A376BXXS4AZG4`, kernel `6.1.138-android14-11`) implementing the
CVE-2026-43499 exploit used by Root My Galaxy.

## Target

| Field | Value |
| --- | --- |
| Model | `SM-A376B` |
| AP | `A376BXXS4AZG4` |
| Kernel | `6.1.138-android14-11` |
| Image base | `0xffffffc008000000` |
| Tracefs event ID | `106` |
| KASLR slide | tracefs leak via `sched:sched_blocked_reason` |

All firmware-dependent constants live in
[`src/targets/a37-A376BXXS4AZG4/`](src/targets/a37-A376BXXS4AZG4/).

## Outputs

The build produces four artifacts under `build/a37-A376BXXS4AZG4/`:

| File | Type | Purpose |
| --- | --- | --- |
| `cve-2026-43499` | shared object (`.so`) | the exploit payload, loaded by `v2root` via `LD_PRELOAD` |
| `cve-2026-43499-root` | PIE executable | standalone `su` daemon / `root-umh` runner |
| `cve-2026-43499-app.so` | shared object | app-domain variant (used by the Root My Galaxy app) |
| `v2root` | PIE executable | LD_PRELOAD loader — sets `SLIDE_SOURCE=tracefs` and runs the payload `.so` |

The release app payload (size-pinned at `104128` bytes) is built with
`make release`.

## Build

```bash
export ANDROID_NDK_HOME=/path/to/android-ndk-r29
make TARGET=a37-A376BXXS4AZG4
```

The same Makefile drives all three binaries. `cve-2026-43499` is a
**shared library**, not a static executable — it must be loaded via
`LD_PRELOAD` (which is exactly what `v2root` does).

## Run on the device

```bash
adb push build/a37-A376BXXS4AZG4/v2root                    /data/local/tmp/v2root
adb push build/a37-A376BXXS4AZG4/cve-2026-43499          /data/local/tmp/cve-2026-43499
adb push build/a37-A376BXXS4AZG4/cve-2026-43499-root     /data/local/tmp/cve-2026-43499-root

adb shell
  cd /data/local/tmp
  chmod +x v2root cve-2026-43499-root
  ./v2root --run-payload /data/local/tmp/cve-2026-43499 \
                      /data/local/tmp/v2root \
                      /data/local/tmp/run.log
```

`v2root` re-execs itself with `LD_PRELOAD=/data/local/tmp/cve-2026-43499`,
the dynamic linker loads the `.so`, and the
`__attribute__((constructor))` function in `src/preload.c` runs the exploit
in-process.

## Source provenance

The exploit source files (`main.c`, `slide.c`, `preload.c`, `fops.c`,
`pipe.c`, `root.c`, `util.c`, `su_daemon.c`, `kernelsnitch/*.h`,
`common.h`, `offset.h`) and the `a37-A376BXXS4AZG4` target headers are
copied from
[BuSung-dev/Root-My-Galaxy-Payloads](https://github.com/BuSung-dev/Root-My-Galaxy-Payloads).
The `v2root` loader comes from the same project family.

## Use only on devices you own or are explicitly authorized to test.
