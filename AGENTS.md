# Building R Chromium for Haiku x86_64

## Layout

- `port/` - the arm64 port's scripts (shared Haiku port) plus `port-x64.py`,
  the x86_64-only edits on top. Each edit adds an x64 branch and leaves arm64 alone,
  so both builds share one Chromium tree.
- `haiku_shim/` - `libchromium_haiku.so`, the BeAPI side, built with Haiku's gcc.
- `build-x64.sh` - port-x64 -> host setup -> shim -> gn gen -> ninja -> dist.
- `setup-x64-host.sh` - lets the arm64 Linux host run x86-64 Linux binaries.
- `packaging/make-release-tarball.sh` - dist -> `release/rchromium-x86_64.tar.gz`,
  the GitHub release asset and what the pkgman-repo recipe packages.
- `packaging/make-hpkg.sh` - standalone .hpkg for local testing (on Haiku).
- `install.sh` - registers pkgman.rainygirl.com/x86_64 and installs rchromium.

## Build host

rainygirl@MacMiniM4 (Apple Silicon), Docker Desktop context `desktop-linux`,
container `haiku-chromium` (Ubuntu 24.04 arm64). docker is `/usr/local/bin/docker`
(not on the ssh PATH). Docker Desktop must have "Use Rosetta for x86_64/amd64
emulation" on. Do not use the colima containers (renku-x64 belongs to other work).

The tree is `/work/chromium/src`, already ported for arm64 (out/haiku-arm64).
The x64 build goes to `out/haiku-x64`; use `SKIP_PORT=1` so the arm64 port
scripts are not reapplied (they would touch every arm64 object).

One-time inputs:

- `/root/sysroot-x64` - from a Haiku x86_64 machine:
  `tar` of `/boot/system/develop/headers`, `develop/lib`, `/boot/system/lib`,
  `develop/tools/lib/gcc`. haiku_devel must be installed there.
- `/root/gen-x64/cross-tools-x86_64` - Haiku's x86_64 cross gcc 13.3.0
  (copied from a Haiku buildtools build; the colima container renku-x64 has one
  at `/root/w/gen/cross-tools-x86_64`).
- The patched rustc in `third_party/rust-toolchain` already knows
  `x86_64-unknown-haiku`.

Sync this repo into the container at `/root/rchromium-x64`, then:

```sh
docker exec -d haiku-chromium bash -c \
  "SKIP_PORT=1 bash /root/rchromium-x64/build-x64.sh > /root/x64-build.log 2>&1"
```

A clean x64 build is about 13.5k steps (several hours on the M4).
The result is `/root/dist-x64/RChromium`, with `fonts/` filled by
`packaging/fetch-fonts.sh` (CJK, Arabic and colour emoji, pinned and checked).

`port/` is the arm64 repository's, kept in step with it: since arm64 PR #1
(extensions, the renderer sandbox, multi-process, the fonts, by idumych) it
also carries `port-x64.py` and `files/build/`. Re-applying the port to a tree
that was already ported needed two fixes, both in arm64 main now:
`port-gfx-sources.py`, and `port-content.py` writing the stack trace's x64
registers itself.

## Things that matter

- **mksnapshot is a real x86-64 binary.** V8 has no x64 simulator, so the
  snapshot toolchain is `//build/toolchain/linux:clang_x64` (Debian amd64
  sysroot) and the host runs it through Rosetta's binfmt handler.
  `setup-x64-host.sh` installs multiarch amd64 libc so the loader exists.
  qemu-user 8.2 does not work: it crashes in its /proc/self/maps emulation
  after mksnapshot reserves the pointer cage.
- `use_v8_context_snapshot = false`: the context snapshot generator would mean
  building all of Blink a second time for x64 Linux.
- PartitionAlloc and the allocator shim are off, as on arm64.
- `struct fpu_state` collides with Haiku x86_64's `<signal.h>`
  (pthreadpool), mcontext fields are rip/rsp/rbp (stack_trace_posix.cc,
  sampler.cc), and libjpeg-turbo's NASM needs the `ELF` define on Haiku -
  all in `port-x64.py`.
- `pkill -f "ninja -C out/haiku-x64"` inside `bash -c` kills its own shell;
  use `pkill ninja`.

## Testing

user@macbook (Haiku x86_64). The launcher sets LIBRARY_PATH itself, so
`rchromium` works over ssh. `screenshot` over ssh gives a black frame; use
`--remote-debugging-port` + an ssh tunnel and `Page.captureScreenshot` instead.

## Publishing

Same as arm64:

1. `packaging/make-release-tarball.sh <dist>/RChromium release` (add `fonts/`
   to the dist first).
2. GitHub release on rainygirl/renkuos-rchromium-x86_64 with the tarball and
   its .sha256.
3. pkgman-repo: `recipes/rchromium.recipe` has an x86_64 branch that unpacks
   `release/rchromium-x86_64.tar.gz`. On a Haiku x86_64 machine with
   pkgman-repo and this tree side by side: `scripts/build.sh rchromium`,
   `scripts/make-repo.sh x86_64`; copy `repo/x86_64` back and run
   `scripts/deploy.sh x86_64` on the workstation. Bump REVISION in the recipe
   for every new package.
