---
title: "Deprecated Implicit Conversion"
date: 2021-04-12T23:24:16+09:00
---

# 스칼라의 Implicit 마법과 작별 준비

스칼라에서 implicit, implicitly가 저 같은 입문자를 괴롭힌다는 소식을 접했지만 이내 `Scala 3`에서는 사용하지 않아도 충분한 대안이 마련되었다고 합니다. 대안은 다음 글에 작성하도록 하겠습니다(~~아직은 몰라요~~).

그럼 implicit이 사라지기 전에 가볍게 한 번 보고 지나가겠습니다.

## 예제

스칼라를 더 나은 자바로 사용하기 위해서 아래와 같은 코드를 사용했습니다. 이 예제 하나를 위해서는 그럭저럭 작성할 만한 코드같습니다.

먼저 아래 코드를 보시죠.

### 입장

```scala
case class Point(x: Int, y: Int)

@tailrec
def sumP(xs: List[Point], acc: Point = Point(0, 0)): Point = xs match {
  case h :: t => sumP(t, Point(acc.x + h.x, acc.y + h.y))
  case _      => acc
}

sumP(List(Point(1, 2), Point(3, 4))) // Point(4, 6)
```

멋져 보이는 코드를 작성했습니다. 하지만... 우리의 목표 implicit을 위해~!

그럼 새로운 trait을 만들어 위에서 사용할 시작 값(Point(0, 0))과 각 값을 합하는 작업을 추상화해보겠습니다.

```scala
trait HapHae[A] {
  def init: A
  def hap(x: A, y: A): A
}

def hapHaeRa[A](xs: List[A])(hapHae: HapHae[A]): A =
  xs.foldLeft(hapHae.init)(hapHae.hap) // init과 hap을 사용하기 위해 foldLeft(for 문과 비슷)로 변경!
```

새로운 합을 할 수 있도록 합해!(`HapHae`)라는 trait을 통해 거부할 수 없는 명령어 합해라!(`hapHaeRa`) 함수를 작성했습니다. `init`이라는 초깃값을 가져야 하고 `hap`이라는 함수를 구현해야만 잘 동작합니다.

그럼 이 `HapHae`는 어떻게 써먹을까요?

```scala
val pointHapHae = new HapHae[Point] {
  override def init: Point = Point(0, 0)
  override def hap(x: Point, y: Point): Point = Point(x.x + y.x, x.y + y.y)
}

hapHaeRa(List(Point(4, 2), Point(3, 4)))(pointHapHae) // // Point(7, 6)
```

짜잔~!

위 코드에서 보듯 초깃값과 합 함수를 구현한 새로운 HapHae를 생성했습니다. 거부할 수 없는 명령 합해라!(haeHaeRa)를 통해 결과를 잘 얻어올 수 있었습니다.

### 절정

> `implicit`은 Deprecated 되었습니다. Scala 3에서 대안이 소개됩니다. 다음(~~다음다음 다음?!~~) 글에서 이 대안을 (골고루~ 골고루~)다루도록 하겠습니다!

하지만 뭔가 마음에 들지 않습니다. 뒤에 꼬리처럼 붙는 `pointHapHae`가 거슬리기 시작합니다. 그래서 이를 없앨 수 있는 `implicit 마법`을 준비해 봤습니다. 간단히 키워드(`implicit`)를 더해주기만 하면 됩니다. 임시 다형성을 통해서 이를 해결해 보겠습니다.

> 임시 다형성(ad-hoc polymorphism)은 타입 파라미터를 이용해 암시적 인스턴스를 주입받아 사용하는 방법입니다.

이번에는 사람(Person)을 합해보도록 하겠습니다.

```scala
case class Person(name: String, age: Int)

implicit val personHapHae = new HapHae[Person] { // <--------- 여기
  override def init: Person = Person("", 0)
  override def hap(x: Person, y: Person): Person = Person(x.name + y.name, x.age + y.age)
}

// ...

def hapHaeRa[A](xs: List[A])(implicit hapHae: HapHae[A]): A = ...  // <--------- 여기

// 사용
hapHaeRa(List(Person("Hello + ", 30), Person("Scala", 40))) // Person(Hello + Scala, 70)
```

`hapHaeRa`의 꼬리 `personHapHae`가 사라졌지만, 코드는 컴파일되고 정상 작동합니다. `implicit`을 사용해서 귀찮은 꼬리 하나를 뗴는 `마법`을 부려봤습니다.

계속 이야기했지만 곧 사라질 예정이긴 하지만 어딘가엔 기존 코드에 남아있을... 혹은 다른 프레임워크 등에 산재해 있을 `implicit`을 이해하는 데 도움이 되었으면 좋겠습니다.

## 결론

> implicit은 알아두되 사용은 자제하고 대안으로 소개된 Scala 3 에서의 방법을 사용하자!