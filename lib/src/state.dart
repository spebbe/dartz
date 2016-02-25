part of dartz;

// Bind on plain State is *not* stack safe. Composition of StateT with stack safe monad, such as Trampoline, is.

class State<S, A> extends MonadOps<State, A> {
  final Function _run;
  Tuple2<A, S> run(S s) => _run(s);
  A value(S s) => run(s).value1;
  S state(S s) => run(s).value2;

  State(this._run);

  @override State pure(a) => new State((s) => new Tuple2(a, s));

  @override State<S, dynamic> bind(State f(A a)) => new State<S, A>((S s) {
    final ran = run(s);
    return f(ran.value1).run(ran.value2);
  });
}

class StateMonad<S> extends MonadOpsMonad<State<S, dynamic>> {
  StateMonad() : super((a) => new State((S s) => new Tuple2(a, s)));

  State<S, S> get() => new State((S s) => new Tuple2(s, s));
  State<S, Unit> put(v) => new State((S s) => new Tuple2(unit, v));
  State<S, Unit> modify(S f(S s)) => get() >= (S s) => put(f(s));
}

final StateMonad StateM = new StateMonad();

class StateT<F, S, A> extends MonadOps<StateT, A> {
  final Monad<F> _FM;
  final Function _run;

  StateT(this._FM, this._run);

  F run(S s) => _run(s);
  F value(S s) => _FM.map(_run(s), (t) => t.value1);
  F state(S s) => _FM.map(_run(s), (t) => t.value2);

  @override StateT pure(a) => new StateT(_FM, (S s) => _FM.pure(new Tuple2<A, S>(a, s)));

  @override StateT bind(StateT f(A a)) => new StateT(_FM, (S s) => _FM.bind(_FM.pure(() => _run(s)), (tt) {
    return _FM.bind(tt(), (Tuple2<A, S> t) => f(t.value1)._run(t.value2));
  }));
}

class StateTMonad<F, S> extends Monad<StateT<F, S, dynamic>> {
  final Monad<F> _FM;

  StateTMonad(this._FM);

  @override StateT<F, S, dynamic> pure(a) =>  new StateT(_FM, (S s) => _FM.pure(new Tuple2<dynamic, S>(a, s)));

  @override StateT<F, S, dynamic> bind(StateT<F, S, dynamic> fa, StateT f(_)) => fa.bind(f);

  StateT<F, S, S> get() => new StateT(_FM, (S s) => _FM.pure(new Tuple2<S, S>(s, s)));
  StateT<F, S, Unit> put(S s) => new StateT(_FM, (_) => _FM.pure(new Tuple2<Unit, S>(unit, s)));
  StateT<F, S, Unit> modify(S f(S s)) => get().bind((S s) => put(f(s)));
}

final StateTMonad<Trampoline, dynamic> TStateM = new StateTMonad(TrampolineM);
