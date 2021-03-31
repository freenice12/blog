---
title: "첫 게시물"
date: 2021-03-30T23:21:35+09:00
draft: false
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
  * **이 저장소를 생성할 때 README.md 라도 만들어 두지 않으면 경고 문구를 만나게 됩니다!**
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

* localhost:1313 에서 확인할 수 있습니다.
* 위에서 게시글을 생성하면 최초에 draft(draft: true)로 생성되기 때문에 별다른 수정을 하지 않고 게시글 작성을 마쳤다면 '-D' 옵션을 통해 draft 게시글도 확인할 수 있게 실행해야 합니다.

## 공개!

### 저장소 최신화

드디어 내가 작성한 게시글을 공개합니다. 위에서 생성한 게시글의 draft를 삭제하거나 false 로 변경하면 게시글이 공개되는데, 이를 github를 통해서 공개하기 위해서는 우리가 수정하고 설정한 코드와 문서들을 github에 push 해야 합니다.

* 순서:
  * hugo 빌드
  * public(문서가 저장될 공개 저장소: $yourrepo$.github.io) 저장소에 빌드 결과물 push
  * hugo 파일 등을 myblog 저장소에 push


```bash
# 빌드할 때 사용할 테마는 myblog/themes 하위 폴더를 참조합니다.
$ hugo -t <themename>

# public push
$ cd public # ..../myblog/public
$ git add .
$ git commit -m '<message>'
$ git push origin # 오류가 발생하는 경우 오류 메시지의 명령어를 실행하세요 ex) git push --set-upstream origin master

# myblog push
$ cd .. # ..../myblog
$ git add .
$ git commit -m '<message>'
$ git push --set-upstream origin master
```

### 확인

이제 드디어 블로그를 확인할 시간입니다. 우리가 정한 페이지로 브라우저에서 접속해 봅니다.

주소: $yourrepo$.github.io

이제 페이지를 확인 후 즐겁게 하던일을 합니다!!

## 저장소 최신화 (optional) 자동화

### cli 명령 이어 붙이기

> 스크립트 사용하기 어려울 때 themename 과 message 만 수정해서 사용할 수 있습니다. 하지만 스크립트로 자동화 하는것을 추천합니다.

```bash
# hugo 빌드 && public push && myblog push
$ hugo -t <themename>
  && cd public
  && git add .
  && git commit -m '<message>'
  && git push origin --set-upstream origin master
  && cd ..
  && git add .
  && git commit -m '<message>'
  && git push --set-upstream origin master
```

### 쉘 스크립트를 이용한 자동화

> 블로그 루트 폴더(..../myblob)에 publish.sh 파일 생성 후 실행할 수 있도록 권한을 변경

```sh
#!/bin/bash

echo "========="
echo "publising"
echo "========="

hugo -t harbor

cd public
git add .
msg="hugo build: `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"
git push

cd ..
git add .
msg="published: `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"
git push
```

#### 번외: 테마를 수정했다면...(optional)

테마를 수정한 경우 그리고 포크를 했다면 본인의 저장소에 push를 해주세요.

## 끝!
