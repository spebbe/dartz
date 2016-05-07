part of dartz;

// TODO: unify with Free?

abstract class Trampoline<A> extends FunctorOps<Trampoline, A> with ApplicativeOps<Trampoline, A>, MonadOps<Trampoline, A> {
  @override Trampoline/*<B>*/ pure/*<B>*/(/*=B*/ b) => new _TPure(b);
  @override Trampoline/*<B>*/ bind/*<B>*/(Trampoline/*<B>*/ f(A a)) => new _TBind(this, f);

  A run() {
    var current = this;
    while(current is _TBind) {
      var fa = (current as _TBind)._fa;
      Function f = (current as _TBind)._f;
      if (fa is _TBind) {
        var fa2 = fa._fa as Trampoline/*<A>*/;
        Function f2 = fa._f;
        current = new _TBind(fa2, (a2) => new _TBind(f2(a2), f));
      } else {
        current = f((fa as _TPure)._a) as Trampoline/*<A>*/;
      }
    }
    return (current as _TPure)._a as A;
  }
}

class _TPure<A> extends Trampoline<A> {
  final A _a;
  _TPure(this._a);
}

class _TBind<A, B> extends Trampoline<A> {
  final Trampoline<B> _fa;
  final Function _f;
  _TBind(this._fa, this._f);
}

final Monad<Trampoline> TrampolineM = new MonadOpsMonad/*<Trampoline>*/((a) => new _TPure(a));

Trampoline/*<T>*/ treturn/*<T>*/(/*=T*/ t) => new _TPure(t);

final Trampoline<Unit> tunit = new _TPure(unit);
Trampoline/*<T>*/ tcall/*<T>*/(Function0/*<Trampoline<T>>*/ thunk) => new _TBind(tunit as Trampoline/*<T>*/, (_) => thunk());

