---
title: "스칼라로 본 Functional Programming(FP) - 2"
date: 2021-04-09T10:54:08+09:00
draft: true
---

# 스칼라로 본 Functional Programming(FP) - 2

## Cats와 함께하는 FP (Cats 문서 내용을 토대로 내용을 전개합니다.)

## Type classes

> [이전 글](/post/brief-fp-in-scala-1/)에서 Monoid를 이런게 있구나 하고 훑어보았습니다. 이번에는 Functor를 훑어보겠습니다.

### Functor

> Functor is a type class that abstracts over type constructors that can be map‘ed over. Examples of such type constructors are List, Option, and Future.

펑터는 map이 가능한 타입 생성자를 추상화하는 type class 입니다. Monoid에서도 봤듯 type class란 어떤 행위를 할 수 있는지 미리 정해놓은 모음(일단은...)이라고 봐도 좋습니다.

먼저, 캣츠 Functor 코드를 보겠습니다.
```scala
trait Functor[F[_]] { // F[_] 는 어떤 타입을 가지고 있는 효과라고 읽겠습니다.
  def map[A, B](fa: F[A])(f: A => B): F[B]
}
```
A 타입의 값을 가진 F("effect" 또는 "computational context" 라고 부름)효과와 A 타입을 B 타입으로 바꾸는 함수를 받고, B 타입의 값을 갖는 F 효과를 반환합니다. 이게 코드를 봐도 뭘 본건지 잘 이해햐기 어렵기 때문에(추상화 어려움 ㅠㅠ) 바로 구현된 코드로 이해를 돕고있습니다.
```scala
implicit val functorForOption: Functor[Option] = new Functor[Option] {
  def map[A, B](fa: Option[A])(f: A => B): Option[B] = fa match {
    case None    => None
    case Some(a) => Some(f(a))
  }
}
/* A => B 는 String => int 로 생각할 수 있고 convert 라는 메소드 이름(위에선 f)으로 나타낼 수 있습니다.
public int convert(String input) {
 if (input.equals("one")) return 1;
 return -1;
}

물론 convert 자체는 나쁜 예.
*/
```
구현은 접어두고 다시 정의한 것을 보면 `map[A, B](fa: Option[A])(f: A => B): Option[B]` 이고, `F[A]` 와 `f`를 확인하실 수 있습니다. 이에 더해 다른 관점으로 `lift` 라는 함수도 있는데 코드로 보겠습니다.
```scala
trait Functor[F[_]] {
  def map[A, B](fa: F[A])(f: A => B): F[B]
  def lift[A, B](f: A => B): F[A] => F[B] =
    fa => map(fa)(f)
}
```
리프트 함수는 `f: A => B`를 `F[A] => F[B]`로 승격 시키는 코드입니다. 어디선가 언젠가 써먹겠죠? 꼭 다음번 포스트에서 이를 사용하는 실 세계(real-world) 예제를 작성해 보겠습니다.

### Functors compose

F 효과가 중첩된 경우(ex: F[G[_]])에 펑터의 합성을 통해 해결할 수 있습니다. 아래 코드를 보겠습니다.

```scala
val listOption = List(Some(1), None, Some(2))

Functor[List].compose[Option].map(listOption)(_ + 1)
// res1: List[Option[Int]] = List(Some(2), None, Some(3))
```
listOption 은 List(효과)에 Option(효과)이 중첩되어 있습니다. 이를 컴포즈를 통해 해결한 예인데요. 마지막 결과(res1)를 보면 리스트 효과(F) 내의 각 효과(G)에 함수(_ + 1)가 적용된 것을 확인하실 수 있습니다. 이처럼 펑터에는 효과의 중첩을 효과적으로 다룰 장치도 이미 마련되어 있습니다. 캣츠에는 더 간단하고 직관적으로 알수 있도록 `Nested`라는 `data type`을 제공하고 있습니다. 이 Nested를 이용한 코드는 조금 더 간결해지고 읽기 쉬워집니다(익숙하면).

```scala
val nested: Nested[List, Option, Int] = Nested(listOption)
// nested: Nested[List, Option, Int] = Nested(List(Some(1), None, Some(2)))

nested.map(_ + 1)
```
위 두 예제는 같은 값을 결과로 반환합니다.

Functor는 F[A](A 타입을 가지는 효과)에서 A 타입의 값을 f(A => B) 함수를 이용해 B타입의 값을 가지는 효과로 변환하는 `map`과
f(A => B) 함수를 F[A] 를 인자로 받아 F[B]를 반환하는 함수로 변환하는 `lift`를 가지고 있습니다.

그럼 다음 글에서는 Monad(모나드)를 가지고 살포시 이야기 해보겠습니다.

(~~.. 뭐라는거지?ㅠㅠ~~)