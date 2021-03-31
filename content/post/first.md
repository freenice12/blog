---
title: "첫 게시물"
date: 2021-03-30T23:21:35+09:00
draft: true
---

# 휴고(hugo)를 이용한 github 페이지 작성하기
> 본 게시물은 mac 환경에서 작성 되었습니다. placeholder($$)안의 내용은 직접 변경하셔야 합니다.

## 준비
### hugo with brew

```bash
$ brew install hugo
```

### github

먼저, github에 repository를 생성해야 합니다. github에 페이지를 노출하는게 목표이기 때문입니다.
* myblog:
  * ex) https://github.com/$yourrepo$/myblog
  * 컨텐츠 저장용 저장소입니다.
* <yourname>.github.io:
  * ex) https://github.com/$yourrepo$/$yourrepo$.github.io
  * 실제 블로그를 게시할 저장소입니다.
  * **단, 이 저장소를 생성할 때 READEME.md 파일을 함께 생성(체크) 해주세요.**
    * 추후 블로그에 서브 모듈을 추가할 때 사소한 문제가 생길 수 있습니다.

### 테마 쇼핑

아래 사이트에서 테마를 먼저 골라보세요.
* https://themes.gohugo.io/

### local

이제 내 컴퓨터에 블로그 포스팅을 위한 저장소를 클론하겠습니다.

```bash
# 원하는 폴더로 이동
$ mkdir /path/to/myblog/root
$ cd /path/to/myblog/root

# 블로그 생성
$ hugo new site myblog
$ cd myblog

# 구조 확인 or ls
$ ll
```

이제부터는 깃허브 저장소와 연동을 할 차례입니다.
* myblog 저장소 연결
  * https://github.com/$yourrepo$/myblog
* publish 저장소 연결
  * https://github.com/$yourrepo$/$yourrepo$.github.io
  * **이 저장소를 생성할 때 README.md 라도 만들어 두지 않으면 아래 서브모듈을 추가할 때 조~금 에로 사항이 생깁니다.**
* 쇼핑한 테마 저장소 연결
  * 쇼핑한 저장소는 두 가지 방법중 택해서 연동합니다.
    * fork 한 후 연결
    * 직접 연결
    * *각 테마 메인 페이지 등을 살펴보시면 설정에 참고할 수 있도록 코드가 있습니다.*

테마는 fork 한 후 연동하는 것을 추천합니다. 커스텀(저는 제외 ㅠㅠ)을 하던지 최신으로 동기화 하던지 먼저 내손을 거쳐야만 하기 때문에 좀 더 이점이 있습니다.

```bash
# myblog 저장소 연결
$ git remote add origin https://github.com/$yourrepo$/blog.git

# publish 할 저장소 연결 - 이름은 public 으로...
$ git submodule add https://github.com/$yourrepo$/$yourrepo$.github.io.git public

# 테마 연결
$ cd themes
$ git submodule add https://github.com/$yourrepo$/<themename>.git <themename>
```

#### 환경 설정

기본적인 준비는 마쳤습니다.

이제 myblog 루트에 config.toml 파일을 수정합니다. 이 파일은 *각 테마의 메인 페이지 등에 설정에 참고할 수 있는 코드가 있습니다.*

저의 경우에는 아래 설정을 가장 먼저 변경했습니다.

```
theme = "<themename>"
baseurl = "https://$yourrepo$.github.io/"
title = "<title>"
```

## 확인(local)

이제 내 컴퓨터에서 블로그를 직접 확인해봅니다. 자세한 내용은 [휴고 홈](https://gohugo.io) 페이지([옵션 관련 페이지](https://gohugo.io/commands/hugo_server/#options))를 확인합니다.

먼저 게시글을 작성하고 확인해봅니다.
```bash
# 게시글 생성
$ hugo new post/first.md

# 게시글 작성
$ vim post/first.md

# 게시글 확인
$ hugo server -D
```
위에서 게시글을 생성하면 최초에 draft(draft: true)로 생성되기 때문에 별다른 수정을 하지 않고 게시글 작성을 마쳤다면 '-D' 옵션을 통해 draft 게시글도 확인할 수 있게 실행해야 합니다.

## 공개!

드디어 내가 작성한 게시글을 공개합니다. 위에서 생성한 게시글의 draft를 삭제하거나 false 로 변경하면 게시글이 공개되는데, 이를 github를 통해서 공개하기 위해서는 우리가 수정하고 설정한 코드와 문서들을 github에 push 해야 합니다.

