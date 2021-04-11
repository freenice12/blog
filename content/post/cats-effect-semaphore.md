---
title: "Cats Effect - Semaphore"
date: 2021-04-11T21:21:05+09:00
draft: true
---

# 캣츠-이펙트 세마포어

> 세마포어는 양수(non-negative)개의 허가(permits)를 가지고 있습니다. 허가를 취득(acquire)하면 현재 허가의 수가 줄어들고, 허가를 방출(release)하면 현재 허가의 수가 증가합니다. 얻을 수 있는 허가가 없는 경우에는 허가를 취득할 수 있을 때까지 `의미적 블로킹`되는 상황이 나타납니다. [참고 문서](https://typelevel.org/cats-effect/docs/2.x/concurrency/semaphore)

사용 예로는 리소스 공유, 생산자/소비자 채널, 두 개의 포크를 가진 철학자들의 식사 등...

## 코드 보기

우리가 가장 먼저 알아야 할 내용은 서두에 설명했듯 아래 3가지입니다.

* 가능한 permits의 수
* permits 취득
* permits 방출

```scala
abstract class Semaphore[F[_]] {
  def available: F[Long]
  def acquire: F[Unit]
  def release: F[Unit]
  // ... and more
}
```

그리고, `의미적 블로킹`이 뜻하는 바는 permit을 취득하려 대기하는 동안에 실제로는 어떤 thread도 블로킹 되지 않는다는 의미입니다. 세마포어를 생성할 때에는 Concurrent[F] 인스턴스를 사용하는 `Semaphore.apply`(취소 가능함, cancelable)와 Async[F] 인스턴스를 사용하는 `Semaphore.uncancelable`(취소 불가)이 있습니다.

끝으로, 간단하게 리소스를 공유하는 코드에서 사용된 세마포어 예를 확인해 보겠습니다.

```scala
import cats.effect.{Concurrent, IO, Timer}
import cats.effect.concurrent.Semaphore
import cats.syntax.all._

import scala.concurrent.ExecutionContext
import scala.concurrent.duration._

// Concurrent[IO] instance 를 위한 implicit val
implicit val ctx = IO.contextShift(ExecutionContext.global)
// 테스트를 위한 `sleep`이 사용할 implicit val
implicit val timer = IO.timer(ExecutionContext.global)

class PreciousResource[F[_]](name: String, s: Semaphore[F])(implicit F: Concurrent[F], timer: Timer[F]) {
  def use: F[Unit] =
    for {
      x <- s.available
      _ <- F.delay(println(s"$name >> Availability: $x"))
      _ <- s.acquire
      y <- s.available
      _ <- F.delay(println(s"$name >> Started | Availability: $y"))
      _ <- timer.sleep(3.seconds)
      _ <- s.release
      z <- s.available
      _ <- F.delay(println(s"$name >> Done | Availability: $z"))
    } yield ()
}

val program: IO[Unit] =
  for {
    s  <- Semaphore[IO](1)
    r1 = new PreciousResource[IO]("R1", s)
    r2 = new PreciousResource[IO]("R2", s)
    r3 = new PreciousResource[IO]("R3", s)
    _  <- List(r1.use, r2.use, r3.use).parSequence.void
  } yield ()
```

* 세마포어를 하나(1) 생성한 후 여러 리소스를 생성할 때 이 세마포어를 사용합니다.
* 세마포어는 최초 Permit이 몇 개 있는지 확인 후 이를 취득하고 릴리즈 할 때까지 긴 작업(3초)을 진행합니다.
* 이후 permits를 방출(release)하고 취득 가능한 permit이 몇 개인지 확인한 후 종료합니다.
* 3개의 리소스를 생성하는데 하나의 세마포어를 공유해서 사용합니다.
  * 이때 취득을 기다리는 다른 스레드들은 `의미적 블록`되어 있지만 실제로는 블로킹 되어 있지 않습니다.
* 마지막 parSequence로 3개의 리소스를 동시에 사용하는데 이때 순서는 무작위로 먼저 permit을 취득한 리소스가 작업을 시작하고 종료합니다.

개념은 간단하지만, 실제로 저처럼 FP와 Cats에 감이 없는 경우 사용하기가 매우 난해합니다. 콜럼버스의 달걀이라고 생각될 만큼요.

앞으로도 노력해야 할 것 같습니다.