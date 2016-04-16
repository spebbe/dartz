part of dartz;

// TODO: unify with Free?

abstract class Trampoline<A> extends FunctorOps<Trampoline, A> with ApplicativeOps<Trampoline, A>, MonadOps<Trampoline, A> {
  @override Trampoline pure(a) => new _TPure(a);
  @override Trampoline bind(Trampoline f(A a)) => new _TBind(this, f);

  A run() {
    var current = this;
    while(current is _TBind) {
      var fa = current._fa;
      Function f = current._f;
      if (fa is _TBind) {
        var fa2 = fa._fa;
        Function f2 = fa._f;
        current = new _TBind(fa2, (a2) => new _TBind(f2(a2), f));
      } else {
        current = f((fa as _TPure)._a);
      }
    }
    return (current as _TPure)._a;
  }
}

class _TPure<A> extends Trampoline<A> {
  final A _a;
  _TPure(this._a);
}

class _TBind<A> extends Trampoline<A> {
  final Trampoline<A> _fa;
  final Function _f;
  _TBind(this._fa, this._f);
}

final Monad<Trampoline> TrampolineM = new MonadOpsMonad((a) => new _TPure(a));

Trampoline treturn(a) => new _TPure(a);

final Trampoline<Unit> tunit = new _TPure(unit);
Trampoline tcall(Thunk thunk) => new _TBind(tunit, (_) => thunk());

