#!/bin/bash
# One-time container setup so the arm64 host can run the x64 Linux build tools
# (mksnapshot, torque, ...): the Debian amd64 sysroot they link against, and an
# amd64 glibc installed multiarch for them to run against. The execution
# itself is Docker Desktop's Rosetta binfmt handler ("Use Rosetta for x86_64/
# amd64 emulation" in its settings); nothing here can turn that on.
set -e
SRC=${SRC:-/work/chromium/src}

python3 "$SRC/build/linux/sysroot_scripts/install-sysroot.py" --arch=amd64

if [ ! -e /lib64/ld-linux-x86-64.so.2 ]; then
	# The ports mirror carries no amd64; restrict it to arm64 and take amd64
	# from the main archive.
	S=/etc/apt/sources.list.d/ubuntu.sources
	grep -q '^Architectures' $S || sed -i 's/^Types: deb/Types: deb\nArchitectures: arm64/' $S
	cat > /etc/apt/sources.list.d/amd64.sources <<EOS
Types: deb
URIs: http://archive.ubuntu.com/ubuntu
Suites: noble noble-updates
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOS
	dpkg --add-architecture amd64
	apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get install -y libc6:amd64 libgcc-s1:amd64 libstdc++6:amd64
fi

# The check that matters: an x86-64 executable runs.
T=$(mktemp -d)
printf 'int main(){return 7;}\n' > "$T/t.c"
"$SRC/third_party/llvm-build/Release+Asserts/bin/clang" --target=x86_64-linux-gnu \
	--sysroot="$SRC/build/linux/debian_bullseye_amd64-sysroot" -fuse-ld=lld \
	"$T/t.c" -o "$T/t"
set +e; "$T/t"; rc=$?; set -e
rm -rf "$T"
[ $rc -eq 7 ] || { echo "x86-64 binaries do not run here (enable Rosetta in Docker Desktop)" >&2; exit 1; }
echo "x86-64 executables run on this host"
