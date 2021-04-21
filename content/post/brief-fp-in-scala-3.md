---
title: "스칼라로 본 Functional Programming(FP) - 3"
date: 2021-04-21T21:38:30+09:00
draft: true
---

# 스칼라로 본 Functional Programming(FP) - 3

## Cats와 함께하는 FP (Cats 문서 내용을 토대로 내용을 전개합니다.)

### Monad

> Monad extends the Applicative type class with a new function flatten. Flatten takes a value in a nested context (eg. F[F[A]] where F is the context) and “joins” the contexts together so that we have a single context (ie. F[A]).
> The name flatten should remind you of the functions of the same name on many classes in the standard library.

모나드는 `flatten`이라는 새로운 함수와 `type class`인 `Applicative`를 확장(Monad extends Applicative ...)합니다. `Flatten`은 컨텍스트(컨테이너 F: `F`[F[A]])내 값을 취할 수 있고, 두 컨택스트를 합(joins)칠 수 있습니다. 그 결과로 하나의 컨택스트(컨테이너)를 갖게 됩니다. "flatten"이란 이름은 여러 라이브러이에서 사용되며 이를 볼 때마다 어떤 기능인지 유추할 수 있게 됩니다.

* flatten ex:
  * Option(Option(1)).flatten
    * => Option[Int] = Some(1)

Cats 문서에 나온 모나드 설명은 간단합니다. 하지만 우린 이미 `모나드 괴담`을 많이 들어 어렵다는 것쯤은 파악한 상태입니다.

그러나 쫄지 말고(~~레포트 제출하고 학점 받을 것도 아니고~~) 역시 실제 코드로 유추해 봅니다.

```scala
trait Monad[F[_]] {
  def flatMap[A, B](fa: F[A])(f: A => F[B]): F[B]
  def map[A, B](fa: F[A])(f: A => B): F[B]
  def pure[A](a: A): F[A]
}
```

코드를 보니 감이 좀 오기 시작합니다(~~안드로메다에서 출발했나... 왜않와?!~~). 역시 친절한 문서 덕분에 이전에도 본 `map`과 간단해 보이는 `pure` 그리고 쪼~끔 어려워 보이는 `flatMap`이 전부입니다.

* map: [functor](./brief-fp-in-scala-2)에서 본 map은 HOF을 받아 컨테이너 안의 값(타입)을 변경해 반환합니다.
* pure: 임의의 값(타입) a(A)를 받아 컨테이너에 넣어 반환합니다.
* flatMap: fa(F[A])를 받아 그 값(타입)을 꺼낸 후 HOF를 통해 값(타입)을 변경해 컨테이너에 넣어 반환합니다.

아주 쉽습니다. 그럼 아래 예제에서 컨테이너(= 컨텍스트 = F)가 Option인 경우 코드를 살펴보겠습니다.

```scala
def OptionMonad: Monad[Option] = new Monad[Option] {
  def flatMap[A, B](fa: Option[A])(f: A => Option[B]): Option[B] = fa match {
    case Some(a) => f(a)
    case None => None
  }

  def map[A, B](fa: Option[A])(f: A => B): Option[B] = fa match {
    case Some(a) => Some(f(a))
    case None => None
  }

  def pure[A](a: A): Option[A] = Some(a)
}
```

구현도 참 쉽습니다.

실제 Cats 문서에는 어떤 식으로 되어있을까요? `pure`와 `flatten`은 `Applicative`에 이미 구현되어 있다고 가정하고 그대로 사용합니다.
* 참고:
  * flatten = flatMap(_)(x => x)

```scala
implicit def optionMonad(implicit app: Applicative[Option]) =
  new Monad[Option] {
    // Define flatMap using Option's flatten method
    override def flatMap[A, B](fa: Option[A])(f: A => Option[B]): Option[B] =
      app.map(fa)(f).flatten
    // Reuse this definition from Applicative.
    override def pure[A](a: A): Option[A] = app.pure(a)

    @annotation.tailrec
    def tailRecM[A, B](init: A)(fn: A => Option[Either[A, B]]): Option[B] =
      fn(init) match {
        case None => None
        case Some(Right(b)) => Some(b)
        case Some(Left(a)) => tailRecM(a)(fn)
      }
  }
```

특히 꼬리 재귀(tailRecM) 코드가 있는데 HOF(fn)의 결과가 Option[Left[A]]라면 그 결괏값(a: A)을 기초로 해서 다시 `tailRecM` 함수를 호출하는 재귀로 되어 있습니다. 결국 HOF(fn)의 결과가 None이거나 Some(Right)인 경우까지 호출되다 종료하게 됩니다.

`tailRecM`의 경우 `스택에 안전`한 `Monadic recursion`입니다. 굉장히 일반적인 기법이지만 이런 코드는 JVM 위에서는 스택에 안전하지 않습니다. Cats에서는 모든 모나드 구현체에 제공하고 있습니다.

`flatMap`의 경우 모나드의 핵심일 테고, 스칼라의 경우 [for comprehensions](https://docs.scala-lang.org/tour/for-comprehensions.html)를 사용하는 편의 문법(문법 설탕, Syntactic sugar)을 제공합니다. 따라서 아래와 같이 코드를 작성할 수 있습니다.

```scala
// flatMap syntactic sugar
import scala.reflect.runtime.universe

universe.reify(
  for {
    x <- Some(1)
    y <- Some(2)
  } yield x + y
).tree
// res3: universe.Tree = Apply(
//   Select(Apply(Select(Ident(Some), apply), List(Literal(Constant(1)))), flatMap),
//   List(
//     Function(
//       List(ValDef(Modifiers(8192L, , List()), x, <type ?>, <empty>)),
//       Apply(
//         Select(
//           Apply(Select(Ident(Some), apply), List(Literal(Constant(2)))),
//           map
//         ),
//         List(
//           Function(
//             List(ValDef(Modifiers(8192L, , List()), y, <type ?>, <empty>)),
//             Apply(Select(Ident(x), $plus), List(Ident(y)))
//           )
//         )
//       )
//     )
//   )
// )
```

결국 중요한 부분은 `for`와 `<-`를 통해서 `flatMap`을 호출하고 그 값을 사용할 수 있는 편의를 제공한다는 점입니다.

Cats에서 제공하는 `ifM`이란 기능도 있습니다. `if 문`을 `monadic context`로 승격 시켜 제공됩니다.
```scala
import cats.implicits._

Monad[List].ifM(List(true, false, true))(ifTrue = List(1, 2), ifFalse = List(3, 4))
// res5: List[Int] = List(1, 2, 3, 4, 1, 2)
```

예제를 보면 알 수 있듯, [true, false, true] 리스트가 각 조건에 맞는 경우 값을 치환해 줍니다.

끝으로 다시 모나드를 위해 flatMap을 보자면 Cats에서는 `FlatMap`이라는 타입을 제공하고이는 모나드처럼 사용되지만 `pure`함수가 제거된 그리고 `flatMap`함수를 가진 trait입니다. 실제 모나드에서는 pure를 따로 언급하고 있지 않기 때문입니다. 그러나 `pure`는 승격(lift)을 위해 필요하기 때문에 Cats의 모나드는 pure 함수를 가진 `Applicative`의 하위 클래스가 됩니다.

코드를 확인하고 마지막으로 왜 캣츠에 `FlatMap`이 존재하게 되었는지 살펴보겠습니다.

```scala
trait FlatMap[F[_]] extends Apply[F] {
  def flatMap[A, B](fa: F[A])(f: A => F[B]): F[B]
}

trait Monad[F[_]] extends FlatMap[F] with Applicative[F]
```

### 번외... (아래는 이해하기 어렵네요.)

`FlatMap`이 존재하게 된 이유는 **모나드가 아니지만 `flatMap`을 사용해야 하는 경우**가 있기 때문입니다.

예를 들어 `Map[K, A]`에 대한 pure를 구현할 방법이 따로 없습니다.

Map[K, A] 와 Map[K, B]를 연산할 경우 같은 `K`를 가지고 값(A)을 연산하는 것이 간단하기 때문에 이 경우 `flatMap`을 사용할 수 있습니다.

따라서 Map[K, *]은 모나드라고 할 수 없지만 `flatMap`을 통해 연산은 할 수 있어야 하므로 Cats에는 `FlatMap`이 존재하게 된 것입니다.

### 번외 2

> for-comprehensions

```scala
//////////////////////////////////////////////////////////

// for comprehensions 일반 문법
// with yield
def foo(n: Int, v: Int) =
   for (i <- 0 until n;
        j <- 0 until n if i + j == v)
   yield (i, j)

foo(10, 10) foreach {
  case (i, j) =>
    println(s"($i, $j) ")  // prints (1, 9) (2, 8) (3, 7) (4, 6) (5, 5) (6, 4) (7, 3) (8, 2) (9, 1)
}

// for comprehensions 일반 문법
// without yield
def foo(n: Int, v: Int) =
   for (i <- 0 until n;
        j <- 0 until n if i + j == v)
   println(s"($i, $j)")

foo(10, 10)
```

## Cats와 함께하는 FP를 마치며...

사실상 모나드 괴담으로 잘 알려진 모나드까지 간단히 알아보기 위해 글을 썻지만, 여전히 쉽지는 않습니다. 앞으로는 이 간단한(~~정말?~~) 개념을 모르고도 FP 코드를 작성한 실제 사례들을 가지고 글을 작성하도록 하겠습니다.

FP는 미지의 영역이긴 하지만 우리는 엔지니어이기 때문에 과학(학문)을 다루듯 세심하게 접근하지 않아도 죄책감을 느낄 필요는 없어 보입니다. 게다가 추후 이런 내용을 이해하게 되면 코드가 지저분해 보일 테고 이는 우리가 가진 핵심 무기 `Refactoring`을 통해 충분히 개선할 수 있기 때문(이라고 믿자)입니다.

그럼 이제(언제?) 실제 코드를 가지고 이야기해보도록 하겠습니다.