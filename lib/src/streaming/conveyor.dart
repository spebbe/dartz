part of dartz_streaming;

/*
  WARNING: Experimental, incomplete and somewhat buggy! Not fully stack safe yet! Will most likely change substantially over time.
  Design similar to the "Process" construct from chapter 15 of "Functional Programming in Scala" by Paul Chiusano and Rúnar Bjarnason.
 */

typedef Conveyor<F, Unit> SinkF<F, O>(O o);
typedef Conveyor<F, O> ChannelF<F, I, O>(I i);

// Workaround for https://github.com/dart-lang/sdk/issues/29949
abstract class Conveyor<F, O> extends FunctorOps<Conveyor/*<F, dynamic>*/, O> with ApplicativeOps<Conveyor/*<F, dynamic>*/, O>, ApplicativePlusOps<Conveyor/*<F, dynamic>*/, O>, MonadOps<Conveyor/*<F, dynamic>*/, O>, MonadPlusOps<Conveyor/*<F, dynamic>*/, O> {

  A interpret<A>(A ifProduce(O head, Conveyor<F, O> tail), A ifConsume(F req, Function1<Either<Object, dynamic>, Conveyor<F, O>> recv), A ifHalt(Object err));

  static Conveyor<F, O> produce<F, O>(O head, [Conveyor<F, O> tail]) => new _Produce(head, tail ?? halt(End));
  static Conveyor<F, O> consume<F, A, O>(F req, Function1<Either<Object, A>, Conveyor<F, O>> recv) => new _Consume(req, recv);
  static Conveyor<F, O> halt<F, O>([Object err]) => new _Halt(err ?? End);

  static final End = new _End();
  static final Kill = new _Kill();

  Conveyor<F, B> pure<B>(B b) => produce(b);

  Conveyor<F, O2> map<O2>(O2 f(O o)) =>
      interpret((h, t) => tryOrDie(() => produce(f(h), t.map(f))),
          (req, recv) => consume(req, (ea) => recv(ea).map(f)),
          halt);

  Conveyor<F, O> lazyPlus(Conveyor<F, O> p()) =>
      onHaltEnd(() => Try(p));

  Conveyor<F, O> empty() => halt(End);

  Conveyor<F, O> plus(Conveyor<F, O> p) =>
      onHaltEnd(() => p);

  Conveyor<F, O> operator +(Conveyor<F, O> p) => plus(p);

  Conveyor<F, O> onComplete(Conveyor<F, O> p()) =>
      onHalt((err) => err == End ? p().asFinalizer() : p().asFinalizer().plus(halt(err)));

  Conveyor<F, O> asFinalizer() =>
      interpret((h, t) => produce(h, t.asFinalizer()),
          (req, recv) => consume(req, (ea) => ea == left(Kill) ? asFinalizer() : recv(ea)),
          halt);

  Conveyor<F, O> onHalt(Conveyor<F, O> f(Object err)) =>
      interpret((h, t) => produce(h, t.onHalt(f)),
          (req, recv) => consume(req, (ea) => recv(ea).onHalt(f)),
          (err) => Try(() => f(err)));

  Conveyor<F, O> onHaltEnd(Conveyor<F, O> f()) =>
      onHalt((err) => err == End ? f() : halt(err));

  Conveyor<F, O2> flatMap<O2>(Conveyor<F, O2> f(O o)) =>
      interpret((h, t) => tryOrDie(() => (f(h).onHalt((err) => err == End ? halt(End) : kill<O2>().plus(halt(err)))).lazyPlus(() => t.flatMap(f))),
          (req, recv) => consume(req, (ea) => recv(ea).flatMap(f)),
          halt);

  Conveyor<F, O2> bind<O2>(Conveyor<F, O2> f(O o)) => flatMap(f);

  Conveyor<F, O> repeat() => lazyPlus(repeat);

  Conveyor<F, O> repeatUntilExhausted() =>
      interpret((h, t) => produce(h, t.lazyPlus(repeatUntilExhausted)),
          (req, recv) => consume(req, (ea) => ea.fold((l) => recv(left(l)), (r) => recv(right(r)).lazyPlus(repeatUntilExhausted))),
          halt);

  Conveyor<F, O> repeatNonEmpty() {
    final cycle = this.map(some).lazyPlus(() => produce(none())).repeat();
    final sentinel = tuple2(some(none()), none());
    final trimmed = cycle.pipe(Pipe.window2()).takeWhile((pair) => pair != sentinel);
    return trimmed.map((t) => t.value2).flatMap((o) => o.fold(() => halt(End), (v) => produce(v)));
  }

  FLA runLog<FLA extends F>(MonadCatch<F> monadCatch) {
    F go(Conveyor<F, O> cur, IList<O> acc) =>
        cur.interpret((h, t) => go(t, cons(h, acc)),
            (req, recv) => monadCatch.bind(monadCatch.attempt(req), (Either<Object, dynamic> e) => go(Try(() => recv(e)), acc)),
            (err) => err == End ? monadCatch.pure(acc.reverse()) : monadCatch.fail(err));
    return cast(go(this, nil()));
  }

  Conveyor<F, O2> drain<O2>() =>
      interpret((h, t) => t.drain<O2>(),
          (req, recv) => consume(req, (ea) => recv(ea).drain()),
          halt);

  Conveyor<F, O2> kill<O2>() =>
      interpret((h, t) => t.kill<O2>(),
          (req, recv) => recv(left(Kill)).drain<O2>().onHalt((e) => e == Kill ? halt(End) : halt(e)),
          halt);


  Conveyor<F, O2> pipe<O2>(Conveyor<From<O>, O2> c2) =>
      c2.interpret((h, t) => produce(h, pipe(t)),
          (req, recv) =>
              this.interpret((h, t) => t.pipe(Try(() => recv(right(h)))),
                  (req0, recv0) => consume(req0, (ea) => recv0(ea).pipe(c2)),
                  (err) => halt<F, O>(err).pipe(recv(left(err)))),
          (err) => kill<O2>().onHalt((err2) => halt<F, O2>(err).plus(halt(err2))));

  Conveyor<F, dynamic> operator |(Conveyor<From<O>, dynamic> c2) => pipe(c2);

  Conveyor<F, O> lastOr(O o) =>
      interpret((h, t) => t.lastOr(h),
          (req, recv) => consume(req, (ea) => recv(ea).lastOr(o)),
          (err) => err == End ? produce(o) : halt(err));

  static Conveyor<F, O> Try<F, O>(Conveyor<F, O> p()) {
    try {
      return p();
    } catch (err) {
      return halt(err);
    }
  }

  Conveyor<F, O2> tryOrDie<O2>(Conveyor<F, O2> p()) {
    try {
      return p();
    } catch (err) {
      return kill<O2>().onHalt((err2) => halt<F, O2>(err).plus(halt(err2)));
    }
  }

  Conveyor<F, O> take(int n) => pipe(Pipe.take(n));

  Conveyor<F, O> takeWhile(bool f(O o)) => pipe(Pipe.takeWhile(f));

  Conveyor<F, O> drop(int n) => pipe(Pipe.drop(n));

  Conveyor<F, O> dropWhile(bool f(O o)) => pipe(Pipe.dropWhile(f));

  Conveyor<F, O> filter(bool f(O o)) => pipe(Pipe.filter(f));

  Conveyor<F, O2> fold<O2>(O2 z, Function2<O2, O, O2> f) => pipe(Pipe.scan(z, f)).lastOr(z);

  Conveyor<F, O2> foldWhile<O2>(O2 z, Function2<O2, O, O2> f, Function1<O2, bool> p) => pipe(Pipe.scanWhile(z, f, p)).lastOr(z);

  Conveyor<F, O> concatenate(Monoid<O> monoid) => pipe(Pipe.scan(monoid.zero(), monoid.append)).lastOr(monoid.zero());

  Conveyor<F, O> intersperse(O sep) => pipe(Pipe.intersperse(sep));

  Conveyor<F, O> buffer(Monoid<O> monoid, int n) => pipe(Pipe.buffer(monoid, n));

  Conveyor<F, IVector<O>> chunk(int n) => pipe(Pipe.chunk(n));

  Conveyor<F, O> skipDuplicates([Eq<O> eq]) => pipe(Pipe.skipDuplicates(eq));

  Conveyor<F, IVector<O>> window(int n) => pipe(Pipe.window(n));

  Conveyor<F, IVector<O>> windowAll(int n) => pipe(Pipe.windowAll(n));

  Conveyor<F, O3> tee<O2, O3>(Conveyor<F, O2> c2, Conveyor<Both<O, O2>, O3> t) => t.interpret<Conveyor<F, O3>>(
      (h, t) => produce(h, tee(c2, t))
      ,(side, recv) => side == Tee._getL
          ? interpret(
          (o, ot) => ot.tee(c2, Try(() => recv(right(o))))
          ,(reqL, recvL) => consume(reqL, (ea) => recvL(ea).tee(c2, t))
          ,(e) => c2.kill<O3>().onComplete(() => halt(e)))
          : c2.interpret(
          (o2, ot) => tee(ot, Try(() => recv(right(o2))))
          ,(reqR, recvR) => consume(reqR, (ea) => tee(recvR(ea), t))
          ,(e) => kill<O3>().onComplete(() => halt(e)))
      ,(e) => kill<O3>().onComplete(() => c2.kill<O3>().onComplete(() => halt(e))));

  Conveyor<F, O3> zipWith<O2, O3>(Conveyor<F, O2> c2, Function2<O, O2, O3> f) => tee(c2, Tee.zipWith(f));

  Conveyor<F, Tuple2<O, O2>> zip<O2>(Conveyor<F, O2> c2) => tee(c2, Tee.zip());

  Conveyor<F, O> interleave(Conveyor<F, O> c2) => tee(c2, Tee.interleave());

  Conveyor<F, Unit> to(Conveyor<F, SinkF<F, O>> sink) => zipWith(sink, (o, f) => f(o)).flatMap(cast(id));

  Conveyor<F, O2> through<O2>(Conveyor<F, ChannelF<F, O, O2>> channel) => zipWith(channel, (o, f) => f(o)).flatMap(cast(id));

  Conveyor<F, O2> onto<O2>(Conveyor<F, O2> f(Conveyor<F, O> c)) => f(this);
}

class _Produce<F, O> extends Conveyor<F, O> {
  final O _head;
  final Conveyor<F, O> _tail;
  _Produce(this._head, this._tail);
  A interpret<A>(A ifProduce(O head, Conveyor<F, O> tail), A ifConsume(F req, Function1<Either<Object, dynamic>, Conveyor<F, O>> recv), A ifHalt(Object err)) => ifProduce(_head, _tail);

  @override String toString() => "Produce($_head, $_tail)";
}

class _Consume<F, A, O> extends Conveyor<F, O> {
  final F /** really F<A> **/ _req;
  final Function1<Either<Object, A>, Conveyor<F, O>> _recv;
  _Consume(this._req, this._recv);
  A2 interpret<A2>(A2 ifProduce(O head, Conveyor<F, O> tail), A2 ifConsume(F req, Function1<Either<Object, dynamic>, Conveyor<F, O>> recv), A2 ifHalt(Object err)) => ifConsume(_req, cast(_recv));

  @override String toString() => "Consume($_req, $_recv)";
}

class _Halt<F, O> extends Conveyor<F, O> {
  final Object _err;
  _Halt(this._err);
  A interpret<A>(A ifProduce(O head, Conveyor<F, O> tail), A ifConsume(F req, Function1<Either<Object, dynamic>, Conveyor<F, O>> recv), A ifHalt(Object err)) => ifHalt(_err);

  @override String toString() => "Halt($_err)";
}

class _End {}

class _Kill {}

final MonadPlus<Conveyor> ConveyorMP = new MonadPlusOpsMonadPlus<Conveyor>((a) => Conveyor.produce(a), () => Conveyor.halt(Conveyor.End));
MonadPlus<Conveyor<F, O>> conveyorMP<F, O>() => cast(ConveyorMP);
