part of dartz;

// Bind on plain monad is *not* stack safe

class State<S, A> extends MonadOps<State, A> {
  final Function _run;
  Tuple2<A, S> run(S s) => _run(s);
  A value(S s) => run(s).value1;
  S state(S s) => run(s).value2;

  State(this._run);

  @override State pure(a) => new State((s) => new Tuple2(a, s));

  @override State<S, A> bind(State f(A a)) => new State<S, A>((S s) {
    final ran = run(s);
    return f(ran.value1).run(ran.value2);
  });

  static final State get = new State((s) => new Tuple2(s, s));
  static State put(v) => new State((s) => new Tuple2(unit, v));
  static State modify(f(_)) => get >= (s) => put(f(s));
}

final Monad<State> StateM = new MonadOpsMonad<State>((a) => new State((s) => new Tuple2(a, s)));

