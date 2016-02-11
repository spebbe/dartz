part of dartz;

// Prestacked Future<Either<E, Reader<R> + Writer<W> + State<S>>> monad.
// Binds are stack safe but costly, because of Future dispatches.
class Evaluation<E, R, W, S, A> extends MonadOps<Evaluation, A> {
  final Monoid<W> _W;
  final Function _run;

  Evaluation(this._W, this._run);

  @override Evaluation pure(a) {
    return new Evaluation(_W, (r, s) {
      return new Future.value(new Right(new Tuple3(_W.zero(), s, a)));
    });
  }

  @override Evaluation bind(Evaluation f(A a)) {
    return new Evaluation(_W, (r, s) {
      return new Future(() {
        final prev = run(r, s);
        return FutureM.bind(prev, (Either<E, Tuple3<W, S, A>> leftOrRight) {
          return leftOrRight.fold((e) => new Future.value(new Left(e)), (t) {
            final w1 = t.value1;
            final s2 = t.value2;
            final a = t.value3;
            final next = f(a).run(r, s2);
            return FutureM.map(next, (Either<E, Tuple3<W, S, A>> leftOrRight2) {
              return leftOrRight2.map((t2) {
                final w2 = t2.value1;
                final s3 = t2.value2;
                final a2 = t2.value3;
                return new Tuple3(_W.append(w1, w2), s3, a2);
              });
            });
          });
        });
      });
    });
  }

  Future<Either<E, Tuple3<W, S, A>>> run(R r, S s) => _run(r, s);

  Future<Either<E, W>> written(R r, S s) => run(r, s).then((e) => e.map((t) => t.value1));

  Future<Either<E, S>> state(R r, S s) => run(r, s).then((e) => e.map((t) => t.value2));

  Future<Either<E, A>> value(R r, S s) => run(r, s).then((e) => e.map((t) => t.value3));

}

class EvaluationMonad<W> extends Monad<Evaluation> {

  final Monoid<W> _W;

  EvaluationMonad(this._W);

  @override Evaluation bind(Evaluation fa, Evaluation f(_)) => fa.bind(f);

  @override Evaluation pure(a) => new Evaluation(_W, (r, s) {
    return new Future.value(new Right(new Tuple3(_W.zero(), s, a)));
  });

  Evaluation liftFuture(Future fut) => new Evaluation(_W, (r, s) {
    return fut.then((ta) => new Right(new Tuple3(_W.zero(), s, ta)));
  });

  Evaluation get() => new Evaluation(_W, (r, s) => new Future.value(new Right(new Tuple3(_W.zero(), s, s))));

  Evaluation gets(f(S)) => get().map(f);

  Evaluation put(s) => new Evaluation(_W, (r, _) => new Future.value(new Right(new Tuple3(_W.zero(), s, unit))));

  Evaluation modify(f(S)) => get() >= ((s)=> put(f(s)));

  Evaluation write(W w) => new Evaluation(_W, (_, s) => new Future.value(new Right(new Tuple3(w, s, unit))));

  Evaluation ask() => new Evaluation(_W, (r, s) => new Future.value(new Right(new Tuple3(_W.zero(), s, r))));

  Evaluation asks(f(R)) => ask().map(f);

  Evaluation raiseError(err) => new Evaluation(_W, (r, s) => new Future.value(new Left(err)));

}
