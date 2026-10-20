#!/bin/bash
# Build content_shell for Haiku x86_64 in the haiku-chromium container on the
# M4 (arm64 Linux host). The Chromium tree is the arm64 port's
# /work/chromium/src, already carrying the Haiku port; this adds the x64
# edits and builds out/haiku-x64 beside out/haiku-arm64. Re-runnable.
#
# Inputs, prepared once (see AGENTS.md):
#   /root/sysroot-x64          boot/system/{lib,develop} of an x86_64 Haiku
#   /root/gen-x64/cross-tools-x86_64   Haiku's x86_64 cross gcc (for the shim)
set -ex
export PATH=/work/depot_tools:$PATH
export DEPOT_TOOLS_METRICS=0
R=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SRC=${SRC:-/work/chromium/src}
SYSROOT=${SYSROOT:-/root/sysroot-x64}
OUTDIR=out/haiku-x64

step() { printf '\n########## %s\n' "$*"; }

step "port"
# SKIP_PORT=1 on a tree the arm64 build already ported: apply-haiku-port.sh
# recopies port/files/, which would touch every arm64 object that uses them.
if [ -z "$SKIP_PORT" ]; then
	bash "$R/port/apply-haiku-port.sh" "$SRC" >/dev/null
	python3 "$R/port/port-ozone.py" "$SRC" >/dev/null
fi
python3 "$R/port/port-x64.py" "$SRC"

step "x64 build tools on the arm64 host"
bash "$R/setup-x64-host.sh"

step "shim"
sh "$R/haiku_shim/build-shim.sh" "$SYSROOT"

step "gn gen"
cd "$SRC"
mkdir -p $OUTDIR
cat > $OUTDIR/args.gn <<EOF
target_os = "haiku"
target_cpu = "x64"
is_debug = false
symbol_level = 0
dcheck_always_on = false
target_sysroot = "$SYSROOT"
haiku_sysroot = "$SYSROOT"
haiku_gcc_lib_dir = "$SYSROOT/boot/system/develop/tools/lib/gcc/x86_64-unknown-haiku/13.3.0"
haiku_toolprefix = "x86_64-unknown-haiku-"

# The arm64 port's shipping configuration: Haiku's own malloc, not
# PartitionAlloc (see the arm64 AGENTS.md, "Do not use PartitionAlloc").
use_partition_alloc_as_malloc = false
enable_backup_ref_ptr_support = false
use_allocator_shim = false

# The context snapshot generator links all of Blink, and it would have to be
# built a second time for x64 Linux (to run under Rosetta like mksnapshot).
# Without it Blink sets up each context at run time instead.
use_v8_context_snapshot = false
EOF
gn gen $OUTDIR

step "ninja"
ninja -C $OUTDIR -k ${KEEP:-0} content_shell

step "dist"
# What packaging/ expects, minus the fonts (copied from the arm64 release).
DIST=${DIST:-/root/dist-x64}/RChromium
STRIP=third_party/llvm-build/Release+Asserts/bin/llvm-strip
rm -rf "$DIST"
mkdir -p "$DIST/lib" "$DIST/locales"
$STRIP -o "$DIST/content_shell" $OUTDIR/content_shell
$STRIP -o "$DIST/lib/libtest_trace_processor.so" $OUTDIR/libtest_trace_processor.so
cp $OUTDIR/content_shell.pak $OUTDIR/icudtl.dat $OUTDIR/snapshot_blob.bin "$DIST/"
cp $OUTDIR/ui/en-US.pak "$DIST/locales/"
cp "$SYSROOT/boot/system/lib/libchromium_haiku.so" "$DIST/lib/"
echo "BUILD-DONE"
