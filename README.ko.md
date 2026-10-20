# R Chromium -- x86_64

[English](README.md) | [日本語](README.ja.md) | **한국어**

Haiku x86_64에서 네이티브로 동작하는 Chromium 154입니다. 뒤로/앞으로/새로고침,
주소 입력란, 북마크로 이루어진 BeAPI 툴바가 붙어 있습니다. Noto Sans CJK를
내장해 한국어, 일본어, 중국어 페이지가 추가 폰트 없이 표시됩니다. 순정 Haiku
x86_64에서 동작하며, [arm64 빌드](https://github.com/rainygirl/renkuos-rchromium-arm64)와
달리 커널이나 런타임 로더 패치가 필요 없습니다. 2008년 MacBook(Core 2 Duo,
AVX 없음), hrev60072에서 테스트했습니다.

![Haiku x86_64에서 news.naver.com을 렌더링하는 R Chromium](docs/images/screenshot-naver.png)

## pkgman으로 설치

R Chromium은 `pkgman.rainygirl.com` 패키지 저장소에 올라가 있습니다. 기기에서
Terminal을 열고 입력합니다:

```sh
pkgman add-repo https://pkgman.rainygirl.com/x86_64
pkgman install rchromium
```

재부팅은 필요 없습니다. 패키지는 약 140 MB이니 `/boot`에 그만큼 여유 공간을
두세요. `/boot/system/apps/RChromium/`에 설치되고, **Deskbar -> Applications**에
**R Chromium**이 추가되며, `rchromium` 명령이 생깁니다.

pkgman이 기존 저장소 항목을 덮어쓸지 물으면 yes로 답하면 됩니다:
`yes | pkgman add-repo https://pkgman.rainygirl.com/x86_64`.

## 설치 스크립트로 설치

`install.sh`는 위 명령과 같은 일을 합니다. 저장소가 등록되어 있지 않으면 등록하고
`rchromium`을 설치합니다. 체크아웃한 디렉터리에서:

```sh
sh install.sh
```

체크아웃 없이:

```sh
curl -fsSL https://raw.githubusercontent.com/rainygirl/renkuos-rchromium-x86_64/main/install.sh | sh
```

이미 받아 둔 패키지 파일을 설치하려면 `sh install.sh --hpkg rchromium-*.hpkg`.

## 실행

**Deskbar -> Applications**에서 **R Chromium**을 고릅니다. Terminal에서:

```sh
rchromium https://news.naver.com
```

- **뒤로 / 앞으로 / 새로고침** -- 왼쪽의 아이콘 버튼. 페이지를 불러오는 동안
  새로고침은 중지 버튼으로 바뀝니다.
- **주소 입력란** -- URL을 입력하고 Enter. `example.com`만 입력하면
  `https://example.com`을 엽니다.
- **별** -- 현재 페이지를 날짜 그룹("오늘" 등) 아래에 북마크합니다.
- **메뉴** -- 검색할 수 있는 북마크 창을 엽니다. 항목을 더블클릭하면 열립니다.

페이지는 소프트웨어로 렌더링되며, 단일 프로세스로 샌드박스 없이 동작합니다
(Haiku에는 seccomp, user namespace, zygote가 없습니다).

## 제거

```sh
pkgman uninstall rchromium
```

또는 `sh install.sh --uninstall`.

## 빌드

[AGENTS.md](AGENTS.md)를 참고하세요. Apple Silicon Mac의 arm64 Linux
컨테이너에서 크로스 빌드하며, V8 스냅샷 도구는 Rosetta로 실제 x86-64
바이너리로 실행합니다.

## AI 활용 고지

이 프로그램은 Claude와 함께 작업해 만들었습니다.
