part of dartz;

// Prestacked Future<Either<E, Reader<R> + Writer<W> + State<S>>> monad.
// Binds are stack safe but relatively expensive, because of Future chaining.
class Evaluation<E, R, W, S, A> extends MonadOps<Evaluation<E, R, W, S, dynamic>, A> {
  final Monoid<W> _W;
  final Function _run;

  Evaluation(this._W, this._run);

  @override Evaluation<E, R, W, S, dynamic> pure(a) {
    return new Evaluation(_W, (r, s) {
      return new Future.value(new Right(new Tuple3(_W.zero(), s, a)));
    });
  }


  @override Evaluation<E, R, W, S, dynamic> map(f(A a)) {
    return new Evaluation(_W, (r, s) {
      return run(r, s).then((Either<E, Tuple3<W, S, A>> leftOrRight) {
        return leftOrRight.map((t) => new Tuple3(t.value1, t.value2, f(t.value3)));
      });
    });
  }

  @override Evaluation<E, R, W, S, dynamic> bind(Evaluation<E, R, W, S, dynamic> f(A a)) {
    return new Evaluation(_W, (r, s) {
      return new Future.microtask(() {
        return run(r, s).then((Either<E, Tuple3<W, S, A>> leftOrRight) {
          return leftOrRight.fold((e) => new Future.value(new Left(e)), (t) {
            final w1 = t.value1;
            final s2 = t.value2;
            final a = t.value3;
            return f(a).run(r, s2).then((Either<E, Tuple3<W, S, dynamic>> leftOrRight2) {
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

  Evaluation<E, R, W, S, A> handleError(Evaluation<E, R, W, S, A> onError(E err)) {
    return new Evaluation(_W, (r, s) {
      final Future<Either<E, Tuple3<W, S, A>>> ran = run(r, s);
      return ran.then((e) => e.fold((l) => onError(l).run(r, s), (r) => new Future.value(right(r))));
    });
  }

  Future<Either<E, Tuple3<W, S, A>>> run(R r, S s) => _run(r, s);

  Future<Either<E, W>> written(R r, S s) => run(r, s).then((e) => e.map((t) => t.value1));

  Future<Either<E, S>> state(R r, S s) => run(r, s).then((e) => e.map((t) => t.value2));

  Future<Either<E, A>> value(R r, S s) => run(r, s).then((e) => e.map((t) => t.value3));

}

class EvaluationMonad<E, R, W, S> extends Monad<Evaluation<E, R, W, S, dynamic>> {

  final Monoid<W> _W;

  EvaluationMonad(this._W);

  @override Evaluation<E, R, W, S, dynamic> map(Evaluation fa, f(_)) => fa.map(f);

  @override Evaluation<E, R, W, S, dynamic> bind(Evaluation fa, Evaluation<E, R, W, S, dynamic> f(_)) => fa.bind(f);

  @override Evaluation<E, R, W, S, dynamic> pure(a) => new Evaluation(_W, (r, s) {
    return new Future.value(new Right(new Tuple3(_W.zero(), s, a)));
  });

  Evaluation<E, R, W, S, dynamic> liftFuture(Future fut) => new Evaluation(_W, (r, s) {
    return fut.then((ta) => new Right(new Tuple3(_W.zero(), s, ta)));
  });

  Evaluation<E, R, W, S, dynamic> liftEither(Either<E, dynamic> either) => either.fold(raiseError, pure);

  Evaluation<E, R, W, S, S> get() => new Evaluation(_W, (r, s) => new Future.value(new Right(new Tuple3(_W.zero(), s, s))));

  Evaluation<E, R, W, S, dynamic> gets(f(S s)) => get().map(f);

  Evaluation<E, R, W, S, Unit> put(S s) => new Evaluation(_W, (r, _) => new Future.value(new Right(new Tuple3(_W.zero(), s, unit))));

  Evaluation<E, R, W, S, Unit> modify(S f(S s)) => get() >= ((S s)=> put(f(s)));

  Evaluation<E, R, W, S, Unit> write(W w) => new Evaluation(_W, (_, s) => new Future.value(new Right(new Tuple3(w, s, unit))));

  Evaluation<E, R, W, S, R> ask() => new Evaluation(_W, (r, s) => new Future.value(new Right(new Tuple3(_W.zero(), s, r))));

  Evaluation<E, R, W, S, dynamic> asks(f(R r)) => ask().map(f);

  Evaluation<E, R, W, S, dynamic> raiseError(E err) => new Evaluation(_W, (r, s) => new Future.value(new Left(err)));

  Evaluation<E, R, W, S, dynamic> handleError(Evaluation<E, R, W, S, dynamic> ev, Evaluation<E, R, W, S, dynamic> onError(E e)) => ev.handleError(onError);
}
