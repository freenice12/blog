---
title: "스칼라로 본 Functional Programming(FP)"
date: 2021-04-08T21:27:10+09:00
draft: true
---

# 스칼라로 본 Functional Programming(FP)

## 서론

FP라는 개념을 알게되고 실제로 프로그래밍 하기 전까지 왜 어려웠는지 생각해보니 바로 'FP 개념에 나오는 여러 typeclass 들이 정리가 안돼서'가 아니라 이런거 몰라도 일단 코딩해보는 닥코 느낌을 못 가져가서 그렇다고 깨닫게 되었습니다. 그러나 역시 기초는 뭐가 있는지는 알아야 하기에 간략하게 Monoid, Functor, Monad 라는게 이런 것이구나 하고 스윽 넘어가보도록 하겠습니다. 덧붙이자면 저에게도 FP는 생소합니다. 배우면서 정리하고 있습니다.

많은 책들이 행위의 정의 및 코드로 구현 즉 typeclass를 열심히 설명 해줍니다. 언젠가는 이것들이 왜 그리고 언제 필요한지. 이것들을 통한 실 세계(real-world)의 예제를 가지고 꼭 포스팅을 해보도록 하겠습니다. 여러분도 많이 들어보셨을 바로 그! 이야기!

> Talk is cheap. Show me the F code!

## Cats와 함께하는 FP (Cats 문서 내용을 토대로 내용을 전개합니다.)

### Typeclass & Datatypes

> [Cats](https://typelevel.org/cats)에 보면 큰 분류로 [Type classes](https://typelevel.org/cats/typeclasses.html) 와 [Data types](https://typelevel.org/cats/datatypes.html)가 있습니다. 각각에 대해서 소개를 보겠습니다.

#### Type classes(문서 내용)

> Type classes are a powerful tool used in functional programming to enable ad-hoc polymorphism, more commonly known as overloading. Where many object-oriented languages leverage subtyping for polymorphic code, functional programming tends towards a combination of parametric polymorphism (think type parameters, like Java generics) and ad-hoc polymorphism.

타입 클래스는 FP에서 ad-hoc(임시) 다형성(오버로딩으로 더 잘 알려짐)을 가능하게 하는 강력한 도구입니다. 많은 개채 지향 언어의 다형적 코드에 대한 subtyping을 활용하는데, FP는 파라미터를 이용한 다형성(자바 제네릭같은 타입 파라미터를 생각해보세요)과 ad-hoc 다형성 조합을 지향합니다.

#### Data types(문서 내용)

> `Type class`가 다형성 및 ad-hoc 다형성의 조합을 정의하면 이 정의를 토대로 우리가 실제로 프로그래밍 할 때 사용할 타입(구현)을 `Data type`이라고 부릅니다.

앞으로 자주 볼 데이터 타입에는...
* OptionT
* EitherT
* FunctionK
등이 있다고 합니다. 데이터 타입을 사용하는 예제와 실 세계 예제들은 곧(~~진짜?~~) 포스팅 할 수 있(~~을까?~~)도록 하겠습니다.

## Type classes

### Monoid - 드디어 모노이드

잔말 말고 코드를 보겠습니다.

```scala
def sumInts(list: List[Int]): Int = list.foldRight(0)(_ + _)
def concatStrings(list: List[String]): String = list.foldRight("")(_ ++ _)
def unionSets[A](list: List[Set[A]]): Set[A] = list.foldRight(Set.empty[A])(_ union _)
```

구현부의 공통점이 보이시나요?

바로, foldRight를 썻다는 점입니다. 그럼 foldRight은 어떤 함수일까요? 바로, 초기값(`0, "", Set.empty[A]`)을 인자로 받고 그 다음 함수(`(_ + _), (_ ++ _), _ union _`)를 받고 있습니다. 두 번째 인자의 공통점은 `_`(underscore)가 2개인 함수라는 점입니다.

왠지 타입을 뭉뚱그려주면(= 특정하지 않으면 = 일반화 하면 = java... generic???) 타입에 구애받지 않고 사용할 수 있(~~을것 같다고 합니다~~)습니다. "다 더하기" trait을 만들어 보겠습니다.
```scala
trait AllPlus[A] {           // 이름 실화? 다 더하기? -_-;;
  def initValue: A           // 빈 초기값
  def allPlus(x: A, y: A): A // 인자 2개 함수
}
```

멋진 이름의 trait이 추출 되었습니다. 위에서 정의한 인터페이스로 먼저 sumInts 함수에서 사용할 수 있도록 구현해보면...
```scala
val intAdditionMonoid: AllPlus[Int] = new AllPlus[Int] {
  def initValue: Int = 0
  def allPlus(x: Int, y: Int): Int = x + y
}
```

짜잔~! 새로운 AllPlus 타입이 탄생했습니다. 이제 위에서 정의한 인터페이스와 그를 구현한 타입을 사용할 함수를 작성해 보겠습니다.
```scala
def neoPlusAll[A](list: List[A], ap: AllPlus[A]): A = list.foldRight(ap.initValue)(ap.allPlus)
```

이제 newPlusAll 을 통해서 타입에 구애받지 않고 String, Set 등도 모두모두 "다 더하기"할 수 있게 되었습니다. 종종 듣는(~~듣기 싫은~~) 모노이드(Monoid)가 바로 위 AllPlus trait 입니다.
* 모노이드로 전환:
  * "AllPlus" => `Monoid`
  * "initValue" => `empty`
  * "allPlus" => `combine`

이렇게 이름을 바꾸면 완전한(남들이 말하는!) 모노이드가 됩니다. 모노이드는 또 `SemiGroup(combine)`의 조합과 확장(`empty`)을 통해 표현하는데 이런건 천천히 알아봐도 되고 일단 모노이드는 이런거구나 하고 넘어가도록 하겠습니다. 왜냐면 우리는 `나중에 이걸 어디서 어떻게 써먹을지`에 관심이 더 있기 때문입니다.