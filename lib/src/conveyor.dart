part of dartz;

/*
  WARNING: Very, very experimental, buggy and incomplete! Will most likely change substantially over time.
  Design similar to the "Process" construct from chapter 15 of "Functional Programming in Scala" by Paul Chiusano and Rúnar Bjarnason.
 */

abstract class Conveyor<F, O> extends FunctorOps<Conveyor/*<F, dynamic>*/, O> with ApplicativeOps<Conveyor/*<F, dynamic>*/, O>, ApplicativePlusOps<Conveyor/*<F, dynamic>*/, O>, MonadOps<Conveyor/*<F, dynamic>*/, O>, MonadPlusOps<Conveyor/*<F, dynamic>*/, O> {

  /*=A*/ interpret/*<A>*/(/*=A*/ ifProduce(O head, Conveyor<F, O> tail), /*=A*/ ifConsume(F req, Function1<Either<Object, dynamic>, Conveyor<F, O>> recv), /*=A*/ ifHalt(Object err));

  static Conveyor/*<F, O>*/ produce/*<F, O>*/(/*=O*/ head, [Conveyor/*<F, O>*/ tail]) => new _Produce(head, tail ?? halt(End));
  static Conveyor/*<F, O>*/ consume/*<F, A, O>*/(/*=F*/ req, Function1<Either<Object, dynamic/*=A*/>, Conveyor/*<F, O>*/> recv) => new _Consume/*<F, A, O>*/(req, recv);
  static Conveyor/*<F, O>*/ halt/*<F, O>*/(Object err) => new _Halt(err);

  static final End = new _End();
  static final Kill = new _Kill();

  Conveyor<F, dynamic/*=B*/> pure/*<B>*/(/*=B*/ b) => produce(b);

  Conveyor<F, dynamic/*=O2*/> map/*<O2>*/(/*=O2*/ f(O o)) =>
      interpret((h, t) => Try(() => produce(f(h), t.map/*<O2>*/(f))),
          (req, recv) => consume(req, (ea) => recv(ea).map/*<O2>*/(f)),
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

  Conveyor<F, dynamic/*=O2*/> flatMap/*<O2>*/(Conveyor<F, dynamic/*=O2*/> f(O o)) =>
      interpret((h, t) => Try(() => f(h)).lazyPlus(() => t.flatMap/*<O2>*/(f)),
          (req, recv) => consume(req, (ea) => recv(ea).flatMap/*<O2>*/(f)),
          halt);

  Conveyor<F, dynamic/*=O2*/> bind/*<O2>*/(Conveyor<F, dynamic/*=O2*/> f(O o)) => flatMap(f);

  Conveyor<F, O> repeat() => lazyPlus(repeat);

  F/*=FLA*/ runLog/*<FLA extends F>*/(MonadCatch<F> monadCatch) {
    F go(Conveyor<F, O> cur, IList<O> acc) =>
        cur.interpret((h, t) => go(t, cons(h, acc)),
            (req, recv) => monadCatch.bind(monadCatch.attempt(req), (Either<Object, dynamic> e) => go(Try(() => recv(e)), acc)),
            (err) => err == End ? monadCatch.pure(acc.reverse()) : monadCatch.fail(err));
    return go(this, nil()) as dynamic/*=FLA*/;
  }

  Conveyor<F, dynamic/*=O2*/> drain/*<O2>*/() =>
      interpret((h, t) => t.drain/*<O2>*/(),
          (req, recv) => consume(req, (ea) => recv(ea).drain/*<O2>*/()),
          halt);

  Conveyor<F, dynamic/*=O2*/> kill/*<O2>*/() =>
      interpret((h, t) => t.kill/*<O2>*/(),
          (req, recv) => recv(left(Kill)).drain/*<O2>*/().onHalt((e) => e == Kill ? halt(End) : halt(e)),
          halt);


  Conveyor<F, dynamic/*=O2*/> pipe/*<O2>*/(Conveyor<From<O>, dynamic/*=O2*/> p2) =>
      p2.interpret((h, t) => produce(h, pipe /*<O2>*/(t)),
          (req, recv) =>
              this.interpret((h, t) => t.pipe/*<O2>*/(Try(() => recv(right(h)))),
                  (req0, recv0) => consume/*<F, O, O2>*/(req0, (ea) => recv0(ea).pipe /*<O2>*/(p2)),
                  (err) => halt/*<F, O2>*/(err)),
          (err) => kill/*<O2>*/().onHalt((err2) => halt/*<F, O2>*/(err).plus(halt(err2))));

  Conveyor<F, dynamic> operator |(Conveyor<From<O>, dynamic> p2) => pipe(p2);

  Conveyor<F, O> lastOr(O o) =>
      interpret((h, t) => t.lastOr(h),
          (req, recv) => consume(req, (ea) => recv(ea).lastOr(o)),
          (err) => err == End ? produce(o) : halt(err));

  static Conveyor/*<F, O>*/ Try/*<F, O>*/(Conveyor/*<F, O>*/ p()) {
    try {
      return p();
    } catch (err) {
      return halt(err);
    }
  }

  Conveyor<F, O> take(int n) => pipe(Pipe.take(n));

  Conveyor<F, O> takeWhile(bool f(O o)) => pipe(Pipe.takeWhile(f));

  Conveyor<F, O> drop(int n) => pipe(Pipe.drop(n));

  Conveyor<F, O> dropWhile(bool f(O o)) => pipe(Pipe.dropWhile(f));

  Conveyor<F, O> filter(bool f(O o)) => pipe(Pipe.filter(f));

  Conveyor<F, Unit> sink(F f(O o)) => flatMap(composeF(Source.eval_, f));

  Conveyor<F, dynamic/*=O2*/> fold/*<O2>*/(/*=O2*/ z, Function2/*<O2, O, O2>*/ f) => pipe(Pipe.scan(z, f)).lastOr(z);

  Conveyor<F, O> concatenate(Monoid<O> monoid) => pipe(Pipe.scan(monoid.zero(), monoid.append)).lastOr(monoid.zero());

}

class _Produce<F, O> extends Conveyor<F, O> {
  final O _head;
  final Conveyor<F, O> _tail;
  _Produce(this._head, this._tail);
  /*=A*/ interpret/*<A>*/(/*=A*/ ifProduce(O head, Conveyor<F, O> tail), /*=A*/ ifConsume(F req, Function1<Either<Object, dynamic>, Conveyor<F, O>> recv), /*=A*/ ifHalt(Object err)) {
    return ifProduce(_head, _tail);
  }

  @override String toString() => "Produce($_head, $_tail)";
}

class _Consume<F, A, O> extends Conveyor<F, O> {
  final F /* really F<A> */ _req;
  final Function1<Either<Object, A>, Conveyor<F, O>> _recv;
  _Consume(this._req, this._recv);
  /*=A2*/ interpret/*<A2>*/(/*=A2*/ ifProduce(O head, Conveyor<F, O> tail), /*=A2*/ ifConsume(F req, Function1<Either<Object, dynamic>, Conveyor<F, O>> recv), /*=A2*/ ifHalt(Object err)) {
    final recvWithTypeSystemWorkaround = _recv as dynamic;
    return ifConsume(_req, recvWithTypeSystemWorkaround as dynamic/*=Function1<Either<Object, dynamic>, Conveyor<F, O>>*/);
  }

  @override String toString() => "Consume($_req, $_recv)";
}

class _Halt<F, O> extends Conveyor<F, O> {
  final Object _err;
  _Halt(this._err);
  /*=A*/ interpret/*<A>*/(/*=A*/ ifProduce(O head, Conveyor<F, O> tail), /*=A*/ ifConsume(F req, Function1<Either<Object, dynamic>, Conveyor<F, O>> recv), /*=A*/ ifHalt(Object err)) {
    return ifHalt(_err);
  }

  @override String toString() => "Halt($_err)";
}

class _End {}

class _Kill {}

class Nowhere {}

class Source {
  static Conveyor/*<F, A>*/ eval/*<F, A>*/(/*=F*/ fa) =>
      Conveyor.consume(fa, (ea) => ea.fold(Conveyor.halt, Conveyor.produce));

  static Conveyor/*<F, A>*/ eval_/*<F, A>*/(/*=F*/ fa) =>
      Conveyor.consume(fa, (ea) => ea.fold(Conveyor.halt, (_) => Conveyor.halt(Conveyor.End)));

  static Conveyor/*<F, O>*/ resource/*<F, R, O>*/(/*=F*/ acquire, Conveyor<dynamic/*=F*/, dynamic/*=O*/> use(/*=R*/ r), Conveyor<dynamic/*=F*/, dynamic/*=O*/> release(/*=R*/ r)) =>
      eval/*<F, R>*/(acquire).bind((r) => use(r).onComplete(() => release(r)));

  static Conveyor<Nowhere, dynamic/*=O*/> fromFoldable/*<F, O>*/(/*=F*/ fo, Foldable/*<F>*/ foldable) => foldable.collapse(conveyorMP(), fo);

  static dynamic/*=F*/ materialize/*<F, O>*/(Conveyor<Nowhere, dynamic/*=O*/> s, ApplicativePlus/*<F>*/ ap) =>
      s.interpret((h, t) => ap.prependElement(materialize/*<F, O>*/(t, ap), h),
          (req, recv) => materialize/*<F, O>*/(recv(left(Conveyor.End)), ap),
          (err) => err == Conveyor.End ? ap.empty() : throw err);

  static Conveyor<Nowhere, dynamic/*=O*/> fromIVector/*<F, O>*/(/*=IVector<O>*/ v) => fromFoldable(v, IVectorTr);
  static IVector/*<O>*/ toIVector/*<O>*/(Conveyor<Nowhere, dynamic/*=O*/> s) => materialize/*<IVector, O>*/(s, IVectorMP) as dynamic/*=IVector<O>*/;

  static Conveyor<Nowhere, dynamic/*=O*/> fromIList/*<F, O>*/(/*=IList<O>*/ v) => fromFoldable(v, IListTr);
  static IList/*<O>*/ toIList/*<O>*/(Conveyor<Nowhere, dynamic/*=O*/> s) => materialize/*<IList, O>*/(s, IListMP) as dynamic/*=IList<O>*/;

  static Conveyor<Task, dynamic/*=A*/> fromStream/*<A>*/(Stream/*<A>*/ s) => Source.resource(Task.delay(() => new StreamIterator(s)),
      (StreamIterator/*<A>*/ it) => Source.eval(new Task(it.moveNext)).repeat().takeWhile(id).flatMap((_) => Source.eval(Task.delay(() => it.current))),
      (StreamIterator/*<A>*/ it) => Source.eval_(new Task(() => new Future.value(unit).then((_) => it.cancel()))));
}

class From<A> {}

class Pipe {
  static final From _get = new From();

  static Conveyor<From/*<I>*/, dynamic/*=O*/> produce/*<I, O>*/(/*=O*/ h, [Conveyor/*<From<I>, O>*/ t]) =>
      Conveyor.produce(h, t);

  static Conveyor<From/*<I>*/, dynamic/*=O*/> consume/*<I, O>*/(Function1/*<I, Conveyor<From<I>, O>>*/ recv, [Function0/*<Conveyor<From<I>, O>>*/ fallback]) =>
      Conveyor.consume(_get as dynamic/*=From<I>*/, (ea) => ea.fold((err) => err == Conveyor.End ? (fallback == null ? halt() : fallback()) : Conveyor.halt(err), (/*=I*/ i) => Conveyor.Try(() => recv(i))));

  static Conveyor<From/*<I>*/, dynamic/*=O*/> halt/*<I, O>*/() => Conveyor.halt(Conveyor.End);

  static Conveyor<From/*<I>*/, dynamic/*=I*/> identity/*<I>*/() => lift(id);

  static Conveyor<From/*<I>*/, dynamic/*=O*/> lift/*<I, O>*/(Function1/*<I, O>*/ f) => consume((/*=I*/ i) => produce(f(i))).repeat();

  static Conveyor<From/*<I>*/, dynamic/*=I*/> take/*<I>*/(int n) => n <= 0 ? halt() : consume((i) => produce(i, take/*<I>*/(n-1)));

  static Conveyor<From/*<I>*/, dynamic/*=I*/> takeWhile/*<I>*/(bool f(/*=I*/ i)) => consume((i) => f(i) ? produce(i, takeWhile/*<I>*/(f)) : halt());

  static Conveyor<From/*<I>*/, dynamic/*=I*/> drop/*<I>*/(int n) => consume((i) => n > 0 ? drop/*<I>*/(n-1) : produce(i, identity()));

  static Conveyor<From/*<I>*/, dynamic/*=I*/> dropWhile/*<I>*/(bool f(/*=I*/ i)) => consume((i) => f(i) ? dropWhile/*<I>*/(f) : identity());

  static Conveyor<From/*<I>*/, dynamic/*=I*/> filter/*<I>*/(bool f(/*=I*/ i)) => consume/*<I, I>*/((i) => f(i) ? produce(i) : halt()).repeat();

  static Conveyor<From/*<I>*/, dynamic/*=O*/> scan/*<I, O>*/(/*=O*/ z, Function2/*<O, I, O>*/ f) {
    Conveyor/*<From<I>, O>*/ go(/*=O*/ previous) => consume((/*=I*/ i) {
      final current = f(previous, i);
      return produce(current, go(current));
    });
    return go(z);
  }
}

final MonadPlus<Conveyor> ConveyorMP = new MonadPlusOpsMonadPlus<Conveyor>((a) => Conveyor.produce(a), () => Conveyor.halt(Conveyor.End));
MonadPlus<Conveyor/*<F, O>*/> conveyorMP/*<F, O>*/() => ConveyorMP;
