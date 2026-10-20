#!/bin/sh
#
# Installs R Chromium (x86_64) on Haiku with pkgman. Run on the device itself.
#
#   sh install.sh                install (or update) R Chromium from the repository
#   sh install.sh --hpkg FILE    install a local rchromium-*-x86_64.hpkg instead
#   sh install.sh --uninstall    remove it again
#   sh install.sh --url BASE     use another repository host
#
# Unlike arm64, x86_64 needs no kernel or runtime loader fixes: a stock
# Haiku x86_64 system runs it.
set -e

BASE="${RCHROMIUM_REPO_BASE:-https://pkgman.rainygirl.com}"
MODE=install
HPKG=

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

while [ $# -gt 0 ]; do
	case "$1" in
		--uninstall) MODE=uninstall; shift ;;
		--hpkg) HPKG="$2"; shift 2 ;;
		--url) BASE="${2%/}"; shift 2 ;;
		--url=*) BASE="${1#--url=}"; BASE="${BASE%/}"; shift ;;
		-h|--help) sed -n '3,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
		*) die "unknown option: $1 (see --help)" ;;
	esac
done

if [ "$MODE" = uninstall ]; then
	pkgman uninstall -y rchromium
	exit 0
fi

ARCH=$(uname -m)
[ "$ARCH" = x86_64 ] || die "this is the x86_64 build; this machine is $ARCH"

if [ -n "$HPKG" ]; then
	[ -f "$HPKG" ] || die "no such file: $HPKG"
	info "installing $HPKG"
	pkgman install -y "$HPKG"
else
	REPO="$BASE/x86_64"
	case "$(pkgman list-repos 2>/dev/null)" in
		*"$REPO"*) info "repository already registered: $REPO" ;;
		*) info "registering $REPO"
		   yes | pkgman add-repo "$REPO" ;;
	esac
	pkgman refresh || true
	info "installing rchromium"
	pkgman install -y rchromium
fi

info "done. Start it from Deskbar -> Applications -> R Chromium, or run: rchromium"
