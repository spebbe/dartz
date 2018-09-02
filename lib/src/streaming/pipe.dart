// ignore_for_file: unnecessary_new

part of dartz_streaming;

class From<A> {}

class Pipe {
  //static final From _get = new From();

  static Conveyor<From<I>, O> produce<I, O>(O h, [Conveyor<From<I>, O> t]) =>
      Conveyor.produce(h, t);

  static Conveyor<From<I>, O> consume<I, O>(Function1<I, Conveyor<From<I>, O>> recv, [Function0<Conveyor<From<I>, O>> fallback]) =>
      Conveyor.consume(new From(), (Either<Object, I> ea) => ea.fold(
          (err) => err == Conveyor.End ? (fallback == null ? halt() : fallback()) : Conveyor.halt(err)
          ,(I i) => Conveyor.Try(() => recv(i))));

  static Conveyor<From<I>, O> halt<I, O>() => Conveyor.halt(Conveyor.End);

  static Conveyor<From<I>, I> identity<I>() => lift(id);

  static Conveyor<From<I>, O> lift<I, O>(Function1<I, O> f) => consume<I, O>((i) => produce(f(i))).repeatUntilExhausted();

  static Conveyor<From<I>, I> take<I>(int n) => n <= 0 ? halt() : consume((i) => produce(i, take(n-1)));

  static Conveyor<From<I>, I> takeWhile<I>(bool f(I i)) => consume((i) => f(i) ? produce(i, takeWhile(f)) : halt());

  static Conveyor<From<I>, I> drop<I>(int n) => consume((i) => n > 0 ? drop<I>(n-1) : produce(i, identity()));

  static Conveyor<From<I>, I> dropWhile<I>(bool f(I i)) => consume((i) => f(i) ? dropWhile(f) : produce(i, identity()));

  static Conveyor<From<I>, I> filter<I>(bool f(I i)) => consume<I, I>((i) => f(i) ? produce(i) : halt()).repeatUntilExhausted();

  static Conveyor<From<I>, O> scan<I, O>(O z, Function2<O, I, O> f) {
    Conveyor<From<I>, O> go(O previous) => consume((I i) {
      final current = f(previous, i);
      return produce(current, go(current));
    });
    return go(z);
  }

  static Conveyor<From<I>, I> roll<I>(Monoid<I> mi) => scan(mi.zero(), mi.append);

  static Conveyor<From<I>, O> scanWhile<I, O>(O z, Function2<O, I, O> f, Function1<O, bool> p) {
    Conveyor<From<I>, O> go(O previous) => consume((I i) {
      final current = f(previous, i);
      return produce(current, p(current) ? go(current) : halt());
    });
    return go(z);
  }

  static Conveyor<From<I>, I> intersperse<I>(I sep) => consume<I, I>((i) => produce(i, produce(sep))).repeatUntilExhausted();

  static Conveyor<From<I>, Tuple2<Option<I>, I>> window2<I>() {
    Conveyor<From<I>, Tuple2<Option<I>, I>> go(Option<I> prev) =>
        consume<I, Tuple2<Option<I>, I>>((I i) => produce<I, Tuple2<Option<I>, I>>(tuple2(prev, i)).lazyPlus(() => go(some(i))));
    return go(none());
  }

  static Conveyor<From<I>, Tuple2<I, I>> window2All<I>() => window2<I>().flatMap((t) => t.value1.fold(halt, (v1) => produce(tuple2(v1, t.value2))));

  static Conveyor<From<A>, A> buffer<A>(Monoid<A> monoid, int n) {
    Conveyor<From<A>, A> go(int i, A sofar) =>
        consume(
            (a) => i > 1 ? go(i-1, monoid.append(sofar, a)) : produce(monoid.append(sofar, a), go(n, monoid.zero()))
            ,() => sofar == monoid.zero() ? halt() : produce(sofar));
    return go(n, monoid.zero());
  }

  static Conveyor<From<A>, IVector<A>> chunk<A>(int n) {
    Conveyor<From<A>, IVector<A>> go(int i, IVector<A> sofar) =>
        consume(
            (a) => i > 1 ? go(i-1, sofar.appendElement(a)) : produce(sofar.appendElement(a), go(n, emptyVector()))
            ,() => sofar.length() == 0 ? halt() : produce(sofar));
    return go(n, emptyVector());
  }

  static Conveyor<From<A>, A> skipDuplicates<A>([Eq<A> _eq]) {
    final Eq<A> eq = _eq ?? objectEq();
    Conveyor<From<A>, A> loop(A lastA) => consume((A a) => eq.eq(lastA, a) ? loop(lastA) : produce(a, loop(a)));
    return consume((A a) => produce(a, loop(a)));
  }

  static Conveyor<From<Option<A>>, A> uniteOption<A>() => consume<Option<A>, A>((oa) => oa.fold(halt, produce)).repeatUntilExhausted();

  static Conveyor<From<A>, IVector<A>> window<A>(int n) => Pipe.scan(emptyVector<A>(), (IVector<A> v, A i) => v.length() >= n ? v.dropFirst().appendElement(i) : v.appendElement(i));

  static Conveyor<From<A>, IVector<A>> windowAll<A>(int n) => window<A>(n).filter((l) => l.length() >= n);
}