// ignore_for_file: unnecessary_new

part of dartz;

// Bind on plain State is *not* stack safe. Composition of StateT with stack safe monad, such as Trampoline, is.

class State<S, A> implements MonadOps<State<S, dynamic>, A> {
  final Function1<S, Tuple2<A, S>> _run;
  Tuple2<A, S> run(S s) => _run(s);
  A value(S s) => run(s).value1;
  S state(S s) => run(s).value2;

  State(this._run);

  State<S, B> pure<B>(B b) => new State((s) => new Tuple2(b, s));
  @override State<S, B> map<B>(B f(A a)) => new State((S s) => run(s).map1(f));
  @override State<S, B> bind<B>(Function1<A, State<S, B>> f) => new State((S s) {
    final ran = run(s);
    return f(ran.value1).run(ran.value2);
  });
  @override State<S, B> flatMap<B>(Function1<A, State<S, B>> f) => bind(f);
  @override State<S, B> andThen<B>(State<S, B> next) => bind((_) => next);

  @override State<S, Tuple2<B, A>> strengthL<B>(B b) => map((a) => tuple2(b, a));

  @override State<S, Tuple2<A, B>> strengthR<B>(B b) => map((a) => tuple2(a, b));

  @override State<S, B> ap<B>(State<S, Function1<A, B>> ff) => ff.bind((f) => map(f)); // TODO: optimize

  @override State<S, B> replace<B>(B replacement) => map((_) => replacement);
}

class StateMonad<S> extends Functor<State<S, dynamic>> with Applicative<State<S, dynamic>>, Monad<State<S, dynamic>> {
  const StateMonad() : super._();
  @override State<S, A> pure<A>(A a) => new State((S s) => new Tuple2(a, s));
  @override State<S, B> map<A, B>(covariant State<S, A> fa, covariant B f(A a)) => fa.map(f);
  @override State<S, B> bind<A, B>(covariant State<S, A> fa, covariant Function1<A, State<S, B>> f) => fa.bind(f);

  State<S, S> get() => new State((S s) => new Tuple2(s, s));
  State<S, A> gets<A>(A f(S s)) => new State((S s) => new Tuple2(f(s), s));
  State<S, Unit> put(S newS) => new State((_) => new Tuple2(unit, newS));
  State<S, Unit> modify(S f(S s)) => new State((S s) => new Tuple2(unit, f(s)));
}

final StateMonad StateM = new StateMonad();
StateMonad<S> stateM<S>() => new StateMonad();

class StateT<F, S, A> implements MonadOps<StateT<F, S, dynamic>, A> {
  final Monad<F> _FM;
  final Function1<S, F> _run;

  StateT(this._FM, this._run);

  F run(S s) => _run(s);
  F value(S s) => _FM.map(_run(s), (t) => t.value1);
  F state(S s) => _FM.map(_run(s), (t) => t.value2);

  StateT<F, S, B> pure<B>(B b) => new StateT(_FM, (S s) => _FM.pure(new Tuple2(b, s)));
  @override StateT<F, S, B> map<B>(B f(A a)) => new StateT(_FM, (S s) => _FM.map(_run(s), (Tuple2<A, B> t) => t.map1(f)));
  @override StateT<F, S, B> bind<B>(Function1<A, StateT<F, S, B>> f) => new StateT(_FM, (S s) => _FM.bind(_FM.pure(() => _run(s)), (F tt()) {
    return _FM.bind(tt(), (Tuple2<A, S> t) => f(t.value1)._run(t.value2));
  }));
  @override StateT<F, S, B> flatMap<B>(Function1<A, StateT<F, S, B>> f) => bind(f);
  @override StateT<F, S, B> andThen<B>(StateT<F, S, B> next) => bind((_) => next);
  @override StateT<F, S, B> replace<B>(B b) => map((_) => b);
  @override StateT<F, S, B> ap<B>(StateT<F, S, Function1<A, B>> ff) => ff.bind((f) => map(f)); // TODO: optimize

  @override StateT<F, S, Tuple2<B, A>> strengthL<B>(B b) => map((a) => tuple2(b, a));

  @override StateT<F, S, Tuple2<A, B>> strengthR<B>(B b) => map((a) => tuple2(a, b));
}

class StateTMonad<F, S> extends Functor<StateT<F, S, dynamic>> with Applicative<StateT<F, S, dynamic>>, Monad<StateT<F, S, dynamic>> {
  final Monad<F> _FM;

  const StateTMonad(this._FM) : super._();

  @override StateT<F, S, A> pure<A>(A a) =>  new StateT(_FM, (S s) => _FM.pure(new Tuple2(a, s)));
  @override StateT<F, S, B> map<A, B>(covariant StateT<F, S, A> fa, covariant B f(A a)) => fa.map(f);
  @override StateT<F, S, B> bind<A, B>(covariant StateT<F, S, A> fa, covariant Function1<A, StateT<F, S, B>> f) => fa.bind(f);

  StateT<F, S, S> get() => new StateT(_FM, (S s) => _FM.pure(new Tuple2(s, s)));
  StateT<F, S, A> gets<A>(A f(S s)) => new StateT(_FM, (S s) => _FM.pure(new Tuple2(f(s), s)));
  StateT<F, S, Unit> put(S newS) => new StateT(_FM, (_) => _FM.pure(new Tuple2(unit, newS)));
  StateT<F, S, Unit> modify(S f(S s)) => new StateT(_FM, (S s) => _FM.pure(new Tuple2(unit, f(s))));

  StateT<F, S, A> withState<A>(StateT<F, S, A> f(S s)) => get().bind(f);
}

final StateTMonad<Trampoline, dynamic> TStateM = new StateTMonad(TrampolineM);
StateTMonad<Trampoline<F>, S> tstateM<F, S>() => cast(TStateM);
