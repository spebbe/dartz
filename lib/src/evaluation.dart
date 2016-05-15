part of dartz;

// Prestacked Future<Either<E, Reader<R> + Writer<W> + State<S>>> monad.
// Binds are stack safe but relatively expensive, because of Future chaining.
class Evaluation<E, R, W, S, A> extends FunctorOps<Evaluation/*<E, R, W, S, dynamic>*/, A> with ApplicativeOps<Evaluation/*<E, R, W, S, dynamic>*/, A>, MonadOps<Evaluation/*<E, R, W, S, dynamic>*/, A> {
  final Monoid<W> _W;
  final Function2<R, S, Future<Either<E, Tuple3<W, S, A>>>> _run;

  Evaluation(this._W, this._run);

  Evaluation<E, R, W, S, dynamic/*=B*/> pure/*<B>*/(/*=B*/ b) {
    return new Evaluation(_W, (r, s) {
      return new Future.value(new Right(new Tuple3(_W.zero(), s, b)));
    });
  }

  Evaluation<E, R, W, S, dynamic/*=B*/> map/*<B>*/(/*=B*/ f(A a)) {
    return new Evaluation(_W, (r, s) {
      return run(r, s).then((Either<E, Tuple3<W, S, A>> leftOrRight) {
        return leftOrRight.map((t) => new Tuple3(t.value1, t.value2, f(t.value3)));
      });
    });
  }

  Evaluation<E, R, W, S, dynamic/*=B*/> bind/*<B>*/(Evaluation<E, R, W, S, dynamic/*=B*/> f(A a)) {
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
    return new Evaluation(_W, (R r, S s) {
      final Future<Either<E, Tuple3<W, S, A>>> ran = run(r, s);
      return ran.then((e) {
        final Future<Either<E, Tuple3<W, S, A>>> folded = e.fold((l) => onError(l).run(r, s), (r) => new Future.value(right(r)));
        return folded as Either/*<E, Tuple3<W, S, A>>*/;
      });
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

  @override Evaluation<E, R, W, S, dynamic> map(Evaluation<E, R, W, S, dynamic> fa, f(_)) => fa.map(f);

  @override Evaluation<E, R, W, S, dynamic> bind(Evaluation<E, R, W, S, dynamic> fa, Evaluation<E, R, W, S, dynamic> f(_)) => fa.bind(f);

  @override Evaluation<E, R, W, S, dynamic/*=A*/> pure/*<A>*/(/*=A*/ a) => new Evaluation(_W, (r, s) {
    return new Future.value(new Right(new Tuple3(_W.zero(), s, a)));
  });

  Evaluation<E, R, W, S, dynamic/*=A*/> liftFuture/*<A>*/(Future/*<A>*/ fut) => new Evaluation(_W, (r, s) {
    return fut.then((ta) => new Right(new Tuple3(_W.zero(), s, ta)));
  });

  Evaluation<E, R, W, S, dynamic/*=A*/> liftEither/*<A>*/(Either<E, dynamic/*=A*/> either) => either.fold(raiseError, pure);

  Evaluation<E, R, W, S, S> get() => new Evaluation(_W, (r, s) => new Future.value(new Right(new Tuple3(_W.zero(), s, s))));

  Evaluation<E, R, W, S, dynamic/*=A*/> gets/*<A>*/(/*=A*/ f(S s)) => new Evaluation(_W, (r, s) => new Future.value(new Right(new Tuple3(_W.zero(), s, f(s)))));

  Evaluation<E, R, W, S, Unit> put(S s) => new Evaluation(_W, (r, _) => new Future.value(new Right(new Tuple3(_W.zero(), s, unit))));

  Evaluation<E, R, W, S, Unit> modify(S f(S s)) => new Evaluation(_W, (r, s) => new Future.value(new Right(new Tuple3(_W.zero(), f(s), unit))));

  Evaluation<E, R, W, S, Unit> write(W w) => new Evaluation(_W, (_, s) => new Future.value(new Right(new Tuple3(w, s, unit))));

  Evaluation<E, R, W, S, R> ask() => new Evaluation(_W, (r, s) => new Future.value(new Right(new Tuple3(_W.zero(), s, r))));

  Evaluation<E, R, W, S, dynamic/*=A*/> asks/*<A>*/(/*=A*/ f(R r)) => ask().map(f);

  Evaluation<E, R, W, S, dynamic/*=A*/> local/*<A>*/(R f(R r), Evaluation<E, R, W, S, dynamic/*=A*/> fa) => new Evaluation(_W, (r, s) => fa.run(f(r), s));

  Evaluation<E, R, W, S, dynamic/*=A*/> scope/*<A>*/(R scopedR, Evaluation<E, R, W, S, dynamic/*=A*/> fa) => new Evaluation(_W, (_, s) => fa.run(scopedR, s));

  Evaluation<E, R, W, S, dynamic/*=A*/> raiseError/*<A>*/(E err) => new Evaluation(_W, (r, s) => new Future.value(new Left(err)));

  Evaluation<E, R, W, S, dynamic/*=A*/> handleError/*<A>*/(Evaluation<E, R, W, S, dynamic/*=A*/> ev, Evaluation<E, R, W, S, dynamic/*=A*/> onError(E e)) => ev.handleError(onError);
}
