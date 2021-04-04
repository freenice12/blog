---
title: "Total Function"
date: 2021-04-04T21:23:58+09:00
---

# 완전 함수 - Scala With Cats library

## 먼저

제가 좋아하는 분 중 한 분인 케븬 님은 이렇게 조언해 주셨습니다.
> "캣츠 라이브러리 사용 전 먼저 해보면 좋은 작업 중 하나는 일반 함수를 완전 함수(Total Function)로 만드는 작업입니다."


저는 아래와 같은 계획으로 코딩을 해보려고 했습니다.
* 자바처럼 스칼라 코드 작성하기
* 라이브러리(캣츠 이팩트) 사용하기

그런데 위 내용을 토대로 해서 순서를 수정하면,
* 자바처럼 스칼라 코드 작성하기
  * 완전 함수로 작성하기
* 라이브러리(캣츠 이팩트) 사용하기

그럼 완전 함수는 뭔지 먼저 알아보겠습니다.

## 완전 함수(Total Function)

완전 함수는 "모든 입력값에 대해 정의된 함수"라고 설명되어 있습니다. 완전 함수와 친한 관계인 부분 함수(Partial Function)와 함께 아주 상황을 가정해보면 아래 코드와 같습니다(프로그래밍에선 완전 함수와 부분 함수라는 표현을 사용). 다만, 수학에서 말하는 함수는 완전 함수를 칭합니다. 예를 들어 y = x 같은 함수가 있습니다.

```scala
// 억지 스러운 예제인건 아량으로 넘어가주시고...

// Partial Function
def divideP(a: Int, b: Int): String = s"Answer: ${a/b}"

// Total Function
def divideT(a: Int, b: Int): String = b match {
  case 0 => "b must not be ZERO(0)!"
  case _ => s"Answer: ${a/b}"
}
```

차이는 한가지 입니다. "어떤 함수가 '가능한 입력'을 모두 다뤘느냐". 그리고 비슷한 예로 Enum을 생각해보면 쉽습니다.
```java
enum State {
  Start, Progress, End
}

// ...

switch(state) {
  case Start:
  // do something
  break;
  case Progress:
  // do something
  break;
  case End:
  // do something
  break;
}

// 혹은

switch(state) {
  case Progress:
  // do progress
  break;
  default:
  // do nothing
  break;
}

```

### 에러 타입 사용 전

이런 식의 코드로 완전 함수를 표현할 수 있습니다. 하지만 종종 우리가 스위치 문을 다룰 땐 default 등은 빼놓기도 하고 if-else로 복잡한 코드가 구현되어 있을 때 구멍이 생기기도 하는 등(혹은 구멍이 생긴 논리의 흐름이 몽땅 else 부분을 통과한다든지...) 신경을 써야 하는 부분이 존재합니다.

그래서 위 스칼라 문서에서 소개하는 방법이 "Option(자바의 Optional과 비슷)이나 Either를 활용하자" 입니다. 이 내용을 듣기 전에 저는 아래와 같은 형식으로 완전 함수를 구현했는데요. 아래의 형식으로 구현해도 의미가 충분히 전달되는 경우 상관없지만, 그 외에는(~~else ㅋㅋ~~) 에러 타입을 사용하는 편이 훨씬 좋은 방법이라고 하셨습니다.

```scala
trait FeTrait
case class FullAbc() extends FeTrait
case class EmptyAbc() extends FeTrait

def feFun(n: Int): FeTrait = {
  try {
    // 뚝딱뚝딱
    FullAbc()
  } catch {
    case e: Exception => EmptyAbc()
  }
}

```

### 에러 타입 사용 후

#### Option, Either

Option과 Either는 많이 사용하는 에러 타입입니다. Option의 경우 결과가 있는지 없는지를 표현할 때, Either는 내가 수행한 함수의 결과가 정상인지 비정상인지 나타내는 효율적인 타입입니다. 역시 자세한 [설명과 코드](https://2020-hindsight-scala.kevinly.dev/docs/more-types/#error-handling)를 확인 하실 수 있습니다. 아래 간략히 코드로 써보겠습니다.

특정 맵의 임의의 키로 값을 찾는 경우에는 그 맵에 해당 키(값)가 없을 수 있기 때문에 Option으로 표현할 수 있습니다. 그리고 드라이버를 연결할 때 드라이버를 찾을 수 없어 에러가 발생하는 경우(Left)와 찾은 드라이버를 반환하는 정상인 경우(Right - 중의적 표현)로 표현할 수 있습니다.

```scala
// 특정 맵의 특정 키로 값을 찾는 함수
def getFrom(map: Map[Int, String], key: Int): Option[String] = ???

// 드라이버 연결
def conn(from: String): Either[NotFound, Driver] = ???
```

## 에러 타입을 사용한 완전 함수

결과적으로 처음 작성했던 feFunc 함수의 경우 에러 타입을 이용해 완전 함수로 수정하면 아래와 같이 사용할 수 있습니다.

```scala
// 변경 전
def feFun(n: Int): FeTrait = {
  try {
    // 뚝딱뚝딱
    FullAbc()
  } catch {
    case e: Exception => EmptyAbc()
  }
}

// 변경 후
def feFunT(n: Int): Either[Exception, FeTrait] = {
  try {
    // 뚝딱뚝딱
    Right(FullAbc())
  } catch {
    case e: Exception => Left(e)
  }
}

// 정상 결과
Either[Exception, FeTrait] = Right(FullAbc())

// 비정상 결과
Either[Exception, FeTrait] = Left(java.lang.ArithmeticException: / by zero)

```

위 코드처럼 에러 타입을 이용한 완전 함수를 작성한 경우 함수의 합성 등에서 좀 더 직관적으로 한쪽의 결과(Right or Left) 만 집중적으로 생각하고 다룰 수 있습니다. 그리고 캣츠를 사용한 코드도 [이 링크](https://2020-hindsight-scala.kevinly.dev/docs/more-types/#use-either)에서 확인하실 수 있습니다. 코드를 더 읽기 쉽게 작성할 수 있도록 도와줬다고 생각됩니다.

## 기타

* 읽어볼 거리:
  * 스칼라 나잇 발표 - [실 세계의 캣츠](https://www.slideshare.net/ikhoon1/real-world-cats-93894867) 슬라이드 쉐어