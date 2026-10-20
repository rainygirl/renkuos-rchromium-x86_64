# R Chromium -- x86_64

**English** | [日本語](README.ja.md) | [한국어](README.ko.md)

Chromium 154 running natively on Haiku x86_64, with a BeAPI toolbar:
back/forward/reload, an address field, and bookmarks. Noto Sans CJK is
bundled, so Korean, Japanese and Chinese pages render without extra fonts. It
runs on a stock Haiku x86_64 system -- unlike the
[arm64 build](https://github.com/rainygirl/renkuos-rchromium-arm64) it needs no
kernel or runtime loader patches. Tested on a 2008 MacBook (Core 2 Duo, no AVX)
with hrev60072.

![R Chromium rendering news.naver.com on Haiku x86_64](docs/images/screenshot-naver.png)

## Install with pkgman

R Chromium is published in the `pkgman.rainygirl.com` package repository.
Open Terminal on the device:

```sh
pkgman add-repo https://pkgman.rainygirl.com/x86_64
pkgman install rchromium
```

No reboot is needed. The package is about 140 MB; keep that much free on
`/boot`. It installs into `/boot/system/apps/RChromium/`, adds **R Chromium**
to **Deskbar -> Applications**, and adds an `rchromium` command.

If pkgman asks whether to overwrite an existing repository entry, answer yes:
`yes | pkgman add-repo https://pkgman.rainygirl.com/x86_64`.

## Install with the installer script

`install.sh` does the same as the commands above -- registers the repository
if it is not registered yet and installs `rchromium`. From a checkout:

```sh
sh install.sh
```

Without a checkout:

```sh
curl -fsSL https://raw.githubusercontent.com/rainygirl/renkuos-rchromium-x86_64/main/install.sh | sh
```

`sh install.sh --hpkg rchromium-*.hpkg` installs a package file you already
have instead of fetching one.

## Run

Double-click **R Chromium** in **Deskbar -> Applications**. From Terminal:

```sh
rchromium https://news.naver.com
```

- **Back / Forward / Reload** -- icon buttons on the left; Reload turns into Stop
  while a page is loading.
- **Address field** -- type a URL and press Enter; a bare `example.com` opens
  `https://example.com`.
- **Star** -- bookmarks the current page under a date group ("Today", ...).
- **Menu** -- opens a searchable bookmarks window; double-click an entry to
  open it.

Pages are rendered in software, in a single process, without a sandbox
(Haiku has no seccomp, user namespaces or zygote).

## Uninstall

```sh
pkgman uninstall rchromium
```

or `sh install.sh --uninstall`.

## Building

See [AGENTS.md](AGENTS.md). It is cross-built on an Apple Silicon Mac in an
arm64 Linux container; the V8 snapshot tool runs as a real x86-64 binary
under Rosetta.

## AI disclosure

This program was written with Claude.
