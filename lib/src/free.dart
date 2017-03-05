part of dartz;

abstract class Free<F, A> extends FunctorOps<Free/*<F, dynamic>*/, A> with ApplicativeOps<Free/*<F, dynamic>*/, A>, MonadOps<Free/*<F, dynamic>*/, A> {

  @override Free<F, dynamic/*=B*/> pure/*<B>*/(/*=B*/ b) => new Pure(b);

  @override Free<F, dynamic/*=B*/> map/*<B>*/(/*=B*/ f(A a)) => bind((a) => new Pure(f(a)));

  @override Free<F, dynamic/*=B*/> bind/*<B>*/(Free<F, dynamic/*=B*/> f(A a)) => new Bind(this, f);

  /*=R*/ fold/*<R>*/(/*=R*/ ifPure(A a), /*=R*/ ifSuspend(F fa), /*=R*/ ifBind(Free<F, dynamic> ffb, Function1<dynamic, Free<F, A>> f));
/*
  Free<F, A> step() {
    Free<F, A> current = this;
    while(current is Bind) {
      final currentBind = cast/*<Bind<F, A, dynamic>>*/(current);
      current = currentBind.ffb.fold((a) => currentBind.f(a), (fa) => currentBind, (ffb, f) => ffb.bind((a) => f(a).bind((a2) => currentBind.f(a2))));
      if (identical(current, currentBind)) {
        return current;
      }
    }
    return current;
  }
*/
  /*=MA*/ foldMap/*<M, MA extends M>*/(Monad/*<M>*/ m, /*=M*/ f(F fa)) =>
      cast(/*step().*/fold((a) => m.pure(a), (fa) => f(fa), (ffb, f2) => m.bind(ffb.foldMap(m, f), (c) => f2(c).foldMap(m, f))));

  @override Free<F, dynamic/*=B*/> flatMap/*<B>*/(Free<F, dynamic/*=B*/> f(A a)) => new Bind(this, f);
  @override Free<F, dynamic/*=B*/> andThen/*<B>*/(Free<F, dynamic/*=B*/> next) => bind((_) => next);
  @override Free<F, A> operator <<(Free<F, dynamic> next) => bind((a) => next.map((_) => a));
}

class Pure<F, A> extends Free<F, A> {
  final A a;
  Pure(this.a);
  /*=R*/ fold/*<R>*/(/*=R*/ ifPure(A a), /*=R*/ ifSuspend(F fa), /*=R*/ ifBind(Free<F, dynamic> ffb, Function1<dynamic, Free<F, A>> f)) => ifPure(a);
}

class Suspend<F, A> extends Free<F, A> {
  final F/**<A>**/ fa;
  Suspend(this.fa);
  /*=R*/ fold/*<R>*/(/*=R*/ ifPure(A a), /*=R*/ ifSuspend(F fa), /*=R*/ ifBind(Free<F, dynamic> ffb, Function1<dynamic, Free<F, A>> f)) => ifSuspend(fa);
}

class Bind<F, A, B> extends Free<F, A> {
  final Free<F, B> ffb;
  final Function1<B, Free<F, A>> f;
  Bind(this.ffb, this.f);
  /*=R*/ fold/*<R>*/(/*=R*/ ifPure(A a), /*=R*/ ifSuspend(F fa), /*=R*/ ifBind(Free<F, dynamic> ffb, Function1<dynamic, Free<F, A>> f)) => ifBind(ffb, f);
}

final Monad<Free> FreeM = new MonadOpsMonad<Free>((a) => new Pure(a));
Monad<Free/*<F, A>*/> freeM/*<F, A>*/() => FreeM as dynamic/*=Monad<Free<F, A>>*/;

Free/*<F, A>*/ liftF/*<F, A>*/(/*=F*/ fa) => new Suspend(fa);
