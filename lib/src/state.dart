part of dartz;

// Bind on plain State is *not* stack safe. Composition of StateT with stack safe monad, such as Trampoline, is.

class State<S, A> extends FunctorOps<State/*<S, dynamic>*/, A> with ApplicativeOps<State/*<S, dynamic>*/, A>, MonadOps<State/*<S, dynamic>*/, A> {
  final Function1<S, Tuple2<A, S>> _run;
  Tuple2<A, S> run(S s) => _run(s);
  A value(S s) => run(s).value1;
  S state(S s) => run(s).value2;

  State(this._run);

  @override State/*<S, B>*/ pure/*<B>*/(/*=B*/ b) => new State/*<S, B>*/((s) => new Tuple2(b, s));
  @override State/*<S, B>*/ map/*<B>*/(/*=B*/ f(A a)) => new State/*<S, B>*/((S s) => run(s).map1(f));
  @override State/*<S, B>*/ bind/*<B>*/(State/*<S, B>*/ f(A a)) => new State/*<S, B>*/((S s) {
    final ran = run(s);
    return f(ran.value1).run(ran.value2);
  });
  @override State/*<S, B>*/ flatMap/*<B>*/(State/*<S, B>*/ f(A a)) => bind(f);
  @override State<S, dynamic/*=B*/> andThen/*<B>*/(State<S, dynamic/*=B*/> next) => bind((_) => next);
  @override State<S, A> operator <<(State<S, dynamic> next) => bind((a) => next.map((_) => a));
}

class StateMonad<S> extends MonadOpsMonad<State<S, dynamic>> {
  StateMonad() : super((a) => new State((S s) => new Tuple2(a, s)));

  @override State<S, dynamic/*=A*/> pure/*<A>*/(/*=A*/ a) => new State((S s) => new Tuple2(a, s));
  @override State<S, dynamic/*=B*/> map/*<A, B>*/(State<S, dynamic/*=A*/> fa, /*=B*/ f(/*=A*/ a)) => fa.map(f);
  @override State<S, dynamic/*=B*/> bind/*<A, B>*/(State<S, dynamic/*=A*/> fa, State<S, dynamic/*=B*/> f(/*=A*/ a)) => fa.bind(f);

  State<S, S> get() => new State((S s) => new Tuple2(s, s));
  State<S, dynamic/*=A*/> gets/*<A>*/(/*=A*/ f(S s)) => new State((S s) => new Tuple2(f(s), s));
  State<S, Unit> put(S newS) => new State((_) => new Tuple2(unit, newS));
  State<S, Unit> modify(S f(S s)) => new State((S s) => new Tuple2(unit, f(s)));
}

final StateMonad StateM = new StateMonad();
StateMonad/*<S>*/ stateM/*<S>*/() => StateM as dynamic/*=StateMonad<S>*/;

class StateT<F, S, A> extends FunctorOps<StateT/*<F, S, dynamic>*/, A> with ApplicativeOps<StateT/*<F, S, dynamic>*/, A>, MonadOps<StateT/*<F, S, dynamic>*/, A> {
  final Monad<F> _FM;
  final Function1<S, F> _run;

  StateT(this._FM, this._run);

  F run(S s) => _run(s);
  F value(S s) => _FM.map(_run(s), (t) => t.value1);
  F state(S s) => _FM.map(_run(s), (t) => t.value2);

  @override StateT/*<F, S, B>*/ pure/*<B>*/(/*=B*/ b) => new StateT/*<F, S, B>*/(_FM, (S s) => _FM.pure(new Tuple2<dynamic/*=B*/, S>(b, s)));
  @override StateT/*<F, S, B>*/ map/*<B>*/(/*=B*/ f(A a)) => new StateT/*<F, S, B>*/(_FM, (S s) => _FM.map(_run(s), (Tuple2<A, S> t) => t.map1(f)));
  @override StateT/*<F, S, B>*/ bind/*<B>*/(StateT/*<F, S, B>*/ f(A a)) => new StateT/*<F, S, B>*/(_FM, (S s) => _FM.bind(_FM.pure(() => _run(s)), (F tt()) {
    return _FM.bind(tt(), (Tuple2<A, S> t) => f(t.value1)._run(t.value2));
  }));
  @override StateT/*<F, S, B>*/ flatMap/*<B>*/(StateT/*<F, S, B>*/ f(A a)) => bind(f);
  @override StateT<F, S, dynamic/*=B*/> andThen/*<B>*/(StateT<F, S, dynamic/*=B*/> next) => bind((_) => next);
  @override StateT<F, S, A> operator <<(StateT<F, S, dynamic> next) => bind((a) => next.map((_) => a));
}

class StateTMonad<F, S> extends Functor<StateT<F, S, dynamic>> with Applicative<StateT<F, S, dynamic>>, Monad<StateT<F, S, dynamic>> {
  final Monad<F> _FM;

  StateTMonad(this._FM);

  @override StateT<F, S, dynamic/*=A*/> pure/*<A>*/(/*=A*/ a) =>  new StateT(_FM, (S s) => _FM.pure(new Tuple2(a, s)));
  @override StateT<F, S, dynamic/*=B*/> map/*<A, B>*/(StateT<F, S, dynamic/*=A*/> fa, /*=B*/ f(/*=A*/ a)) => fa.map(f);
  @override StateT<F, S, dynamic/*=B*/> bind/*<A, B>*/(StateT<F, S, dynamic/*=A*/> fa, StateT<F, S, dynamic/*=B*/> f(/*=A*/ a)) => fa.bind(f);

  StateT<F, S, S> get() => new StateT(_FM, (S s) => _FM.pure(new Tuple2(s, s)));
  StateT<F, S, dynamic/*=A*/> gets/*<A>*/(/*=A*/ f(S s)) => new StateT(_FM, (S s) => _FM.pure(new Tuple2(f(s), s)));
  StateT<F, S, Unit> put(S newS) => new StateT(_FM, (_) => _FM.pure(new Tuple2(unit, newS)));
  StateT<F, S, Unit> modify(S f(S s)) => new StateT(_FM, (S s) => _FM.pure(new Tuple2(unit, f(s))));

  StateT<F, S, dynamic/*=A*/> withState/*<A>*/(StateT<F, S, dynamic/*=A*/> f(S s)) => get().bind(f);
}

final StateTMonad<Trampoline, dynamic> TStateM = new StateTMonad(TrampolineM);
StateTMonad<Trampoline/*<F>*/, dynamic/*=S*/> tstateM/*<F, S>*/() => TStateM as dynamic/*=StateTMonad<Trampoline<F>, S>*/;
