// ignore_for_file: unnecessary_new

part of dartz;

// TODO: unify with Free?

abstract class Trampoline<A> implements MonadOps<Trampoline, A> {
  Trampoline<B> pure<B>(B b) => new _TPure(b);
  @override Trampoline<B> map<B>(B f(A a)) => bind((a) => pure(f(a)));
  @override Trampoline<B> bind<B>(Function1<A, Trampoline<B>> f) => new _TBind(this, f);

  @override Trampoline<Tuple2<B, A>> strengthL<B>(B b) => map((a) => tuple2(b, a));

  @override Trampoline<Tuple2<A, B>> strengthR<B>(B b) => map((a) => tuple2(a, b));

  A run() {
    var current = this;
    while(current is _TBind) {
      var fa = cast<_TBind>(current)._fa;
      Function f = cast<_TBind>(current)._f;
      if (fa is _TBind) {
        var fa2 = cast<Trampoline<A>>(fa._fa);
        Function f2 = fa._f;
        current = new _TBind(fa2, (a2) => new _TBind(cast(f2(a2)), f));
      } else {
        current = cast(f(cast<_TPure>(fa)._a));
      }
    }
    return cast(cast<_TPure>(current)._a);
  }

  @override Trampoline<B> andThen<B>(Trampoline<B> next) => bind((_) => next);

  @override Trampoline<B> ap<B>(Trampoline<Function1<A, B>> ff) => ff.bind((f) => map(f)); // TODO: optimize

  @override Trampoline<B> flatMap<B>(Function1<A, Trampoline<B>> f) => new _TBind(this, f);

  @override Trampoline<B> replace<B>(B replacement) => map((_) => replacement);
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

final Monad<Trampoline> TrampolineM = new MonadOpsMonad((a) => new _TPure(a));

Trampoline<T> treturn<T>(T t) => new _TPure(t);

final Trampoline<Unit> tunit = new _TPure(unit);
Trampoline<T> tcall<T>(Function0<Trampoline<T>> thunk) => new _TBind(cast(tunit), (_) => thunk());
