# R Chromium -- x86_64

[English](README.md) | **日本語** | [한국어](README.ko.md)

Haiku x86_64 でネイティブに動作する Chromium 154 です。戻る/進む/再読み込み、
アドレス欄、ブックマークからなる BeAPI ツールバー付きです。Noto Sans CJK、Noto Sans
Arabic、Noto Color Emoji を同梱しているので、日本語・韓国語・中国語・アラビア語のページと
カラー絵文字が追加フォントなしで表示されます。
素の Haiku x86_64 で動作し、[arm64 ビルド](https://github.com/rainygirl/renkuos-rchromium-arm64)
と違ってカーネルやランタイムローダーのパッチは不要です。2008 年の MacBook
(Core 2 Duo、AVX なし)、hrev60072 でテストしています。

![Haiku x86_64 で news.naver.com を描画する R Chromium](docs/images/screenshot-naver.png)

## pkgman でインストール

R Chromium は `pkgman.rainygirl.com` パッケージリポジトリで公開しています。
デバイスで Terminal を開いて入力します:

```sh
pkgman add-repo https://pkgman.rainygirl.com/x86_64
pkgman install rchromium
```

再起動は不要です。パッケージは約 140 MB なので、`/boot` にその分の空きを
確保してください。`/boot/system/apps/RChromium/` にインストールされ、
**Deskbar -> Applications** に **R Chromium** が追加され、`rchromium` コマンドが
使えるようになります。

pkgman が既存のリポジトリ項目を上書きするか尋ねたら yes と答えます:
`yes | pkgman add-repo https://pkgman.rainygirl.com/x86_64`。

## インストールスクリプトでインストール

`install.sh` は上のコマンドと同じことをします。リポジトリが未登録なら登録し、
`rchromium` をインストールします。チェックアウトから:

```sh
sh install.sh
```

チェックアウトなしで:

```sh
curl -fsSL https://raw.githubusercontent.com/rainygirl/renkuos-rchromium-x86_64/main/install.sh | sh
```

手元のパッケージファイルを入れるには `sh install.sh --hpkg rchromium-*.hpkg`。

## 実行

**Deskbar -> Applications** から **R Chromium** を選びます。Terminal からは:

```sh
rchromium https://news.naver.com
```

- **戻る / 進む / 再読み込み** -- 左側のアイコンボタン。読み込み中は再読み込みが
  停止ボタンに変わります。
- **アドレス欄** -- URL を入力して Enter。`example.com` だけなら
  `https://example.com` を開きます。
- **星** -- 現在のページを日付グループ (「今日」など) の下にブックマークします。
- **メニュー** -- 検索できるブックマークウィンドウを開きます。項目をダブルクリック
  すると開きます。

ページはソフトウェアで描画され、シングルプロセス・サンドボックスなしで動作します
(Haiku には seccomp、user namespace、zygote がありません)。

## アンインストール

```sh
pkgman uninstall rchromium
```

または `sh install.sh --uninstall`。

## ビルド

[AGENTS.md](AGENTS.md) を参照してください。Apple Silicon Mac 上の arm64 Linux
コンテナでクロスビルドし、V8 のスナップショットツールは Rosetta で実際の
x86-64 バイナリとして実行します。

## 拡張機能

Chrome 拡張 (Manifest V3) は、プロファイルの `Extensions` フォルダー
(`~/config/settings/content_shell/Extensions`) から読み込みます。展開した拡張
1 つがフォルダー 1 つです。`--load-extension=<dir>` で 1 回だけ読み込むこともできます。
action のある拡張はツールバーにボタンが付き、バッジとポップアップも出ます。Brave
Shields の広告ブロックをテストしました。動くものと省いたものは
[docs/EXTENSIONS.md](docs/EXTENSIONS.md) にあります。

ページはそれぞれのプロセスで描画され、そのプロセスは Web コンテンツを扱う前に root
権限を手放します ([docs/SANDBOX.md](docs/SANDBOX.md))。乗っ取られたページがユーザーの
ファイルを書き込むことはできませんが、完全なサンドボックスではありません。

## 貢献者

- [idumych](https://github.com/idumych) -- 拡張機能、レンダラーのサンドボックス、
  マルチプロセス、アラビア語とカラー絵文字のフォント、x86_64 Linux ホストでのビルド

## AI 利用について

このプログラムは Claude と一緒に作りました。
