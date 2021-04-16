---
title: "제스트에서 타입스크립트 테스트 하기(with babel)"
date: 2021-04-16T16:28:56+09:00
---

# 타입스크립트 테스트하기

## 준비

```bash
$ yarn add --dev jest
$ yarn add --dev babel-jest @babel/core @babel/preset-env @babel/preset-typescript @types/jest
```

타입스크립트를 jest로 테스트 할때 Typescript를 사용하기 위해서는 ES6+ 하위 호환 및 ts -> js 변환을 위한 `babel`이란 녀석이 꼭 필요하다고 합니다.

### 과정

> Typescript를 사용하는 프로젝트인데 jest를 사용하고 싶었다. import부터 제대로 되지 않는다...

프론트에서도 테스트를 사용해 내가 원하는 기능은 먼저 테스트해 보고, 화면을 그리는 UI~~나에게는 매우 어려운~~ 작업은 눈으로 테스트해 보려고 했습니다. 그런데 처음부터 만나게 된 import를 할 수 없다는 오류 메시지..

먼저 위 준비과정의 jest, typescript, babel(너는 왜? ㅠㅠ)을 설치해주고, 다음으로 관련 설정들을 설정 파일을 통해 작성합니다(아래 설정 파일들은 프로젝트 루트에 생성).

* package.json

```json
"scripts": {
    "test": "jest",
  },
```

* jest.config.js

```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  transform: {
    "\\.[jt]sx?$": "babel-jest"
  },
}
```

* babel.config.js

```javascript
module.exports = {
  presets: [
    ['@babel/preset-env', {targets: {node: 'current'}}],
    '@babel/preset-typescript'
  ],
}
```

그럼 설정은 모두 마쳤고 실제로 테스트가 잘 작동하는지 봅니다. 이런 설정들을 추가한 이유는 ts 파일에서 import를 사용해 테스트하는 경우 import를 해석하지 못하고 오류를 발생시키기 때문이었습니다.

* 먼저 finally.test.js, finallyEx.ts 파일 생성
  * finally는 원하시는 이름으로 변경할 수 있지만 `test.js`로 끝나게 해주세요.
  * finallyEx는 import해서 사용할 모듈입니다.
* 아래 내용을 작성하고 테스트를 실행합니다.

```javascript
// finally.test.js
import * as finallyEx from './finallyEx';

test("import datasetSupporter and use function", () => {
  const actual = finallyEx.add(1, 2)

  expect(actual).toBe(3)
})


// finallyEx.ts
export function add(a: number, b: number) {
  return a + b
}
```

이제 테스트를 실행하면 짜장! 드디어 import를 사용해 테스트를 진행할 수 있게 되었습니다.

테스트를 수정할 때마다 매번 확인하기 귀찮다면 `--watch`를 이용해보세요. 굉장히 편리합니다.

```bash
$ yarn test
# or
$ yarn test --watch
```

테스트 코드를 작성하지 않아도 설정을 먼저 해두면 언젠가 써먹지 않을까요?!

안녕~!