// ignore_for_file: unnecessary_new

part of dartz;

abstract class Option<A> implements TraversableMonadPlusOps<Option, A> {
  const Option();

  B fold<B>(B ifNone(), B ifSome(A a));

  B cata<B, B2 extends B>(B ifNone(), B2 ifSome(A a)) => fold(ifNone, ifSome);
  Option<A> orElse(Option<A> other()) => fold(other, (_) => this);
  A getOrElse(A dflt()) => fold(dflt, (a) => a);
  Either<B, A> toEither<B>(B ifNone()) => fold(() => left(ifNone()), (a) => right(a));
  Either<dynamic, A> operator %(ifNone) => toEither(() => ifNone);
  A operator |(A dflt) => getOrElse(() => dflt);

  @override Option<B> map<B>(B f(A a)) => fold(none, (A a) => some(f(a)));
  @override Option<B> ap<B>(Option<Function1<A, B>> ff) => fold(none, (A a) => ff.fold(none, (Function1<A, B> f) => some(f(a))));
  @override Option<B> bind<B>(Function1<A, Option<B>> f) => fold(none, f);
  @override Option<B> flatMap<B>(Function1<A, Option<B>> f) => fold(none, f);
  @override Option<B> andThen<B>(Option<B> next) => fold(none, (_) => next);



  IList<Option<B>> traverseIList<B>(IList<B> f(A a)) => fold(() => cons(none(), nil()), (a) => f(a).map(some));

  IVector<Option<B>> traverseIVector<B>(IVector<B> f(A a)) => fold(() => emptyVector<Option<B>>().appendElement(none()), (a) => f(a).map(some));

  Future<Option<B>> traverseFuture<B>(Future<B> f(A a)) => fold(() => new Future.microtask(none), (a) => f(a).then(some));

  State<S, Option<B>> traverseState<S, B>(State<S, B> f(A a)) => fold(() => new State((s) => tuple2(none(), s)), (a) => f(a).map(some));

  Free<F, Option<B>> traverseFree<F, B>(Free<F, B> f(A a)) => fold(() => new Pure(none()), (a) => f(a).map(some));

  static IList<Option<A>> sequenceIList<A>(Option<IList<A>> ola) => ola.traverseIList(id);

  static IVector<Option<A>> sequenceIVector<A>(Option<IVector<A>> ova) => ova.traverseIVector(id);

  static Future<Option<A>> sequenceFuture<A>(Option<Future<A>> ofa) => ofa.traverseFuture(id);

  static State<S, Option<A>> sequenceState<S, A>(Option<State<S, A>> osa) => osa.traverseState(id);

  static Free<F, Option<A>> sequenceFree<F, A>(Option<Free<F, A>> ofa) => ofa.traverseFree(id);

  @override Option<A> plus(Option<A> o2) => orElse(() => o2);

  @override Option<A> filter(bool predicate(A a)) => fold(none, (a) => predicate(a) ? this : none());
  @override Option<A> where(bool predicate(A a)) => filter(predicate);

  @override bool all(bool f(A a)) => map(f)|true;
  @override bool every(bool f(A a)) => all(f);

  @override bool any(bool f(A a)) => map(f)|false;

  @override Option<A> appendElement(A a) => orElse(() => some(a));

  @override A concatenate(Monoid<A> mi) => getOrElse(mi.zero);

  @override Option<A> concatenateO(Semigroup<A> si) => this;

  @override B foldLeft<B>(B z, B f(B previous, A a)) => fold(() => z, (a) => f(z, a));

  @override B foldLeftWithIndex<B>(B z, B f(B previous, int i, A a)) => fold(() => z, (a) => f(z, 0, a));

  @override B foldMap<B>(Monoid<B> bMonoid, B f(A a)) => fold(bMonoid.zero, f);

  @override Option<B> foldMapO<B>(Semigroup<B> si, B f(A a)) => map(f);

  @override B foldRight<B>(B z, B f(A a, B previous)) => fold(() => z, (a) => f(a, z));

  @override B foldRightWithIndex<B>(B z, B f(int i, A a, B previous))=> fold(() => z, (a) => f(0, a, z));

  @override A intercalate(Monoid<A> mi, A a) => fold(mi.zero, id);

  @override int length() => fold(() => 0, (_) => 1);

  @override Option<B> mapWithIndex<B>(B f(int i, A a)) => map((a) => f(0, a));

  @override Option<A> maximum(Order<A> oa) => this;

  @override Option<A> minimum(Order<A> oa) => this;

  Tuple2<Option<A>, Option<A>> partition(bool f(A a)) => map(f)|false ? tuple2(this, none()) : tuple2(none(), this);

  @override Option<A> prependElement(A a) => some(a).orElse(() => this);

  @override Option<B> replace<B>(B replacement) => map((_) => replacement);

  Option<A> reverse() => this;

  @override Option<Tuple2<B, A>> strengthL<B>(B b) => map((a) => tuple2(b, a));

  @override Option<Tuple2<A, B>> strengthR<B>(B b) => map((a) => tuple2(a, b));

  @override Option<Tuple2<int, A>> zipWithIndex() => map((a) => tuple2(0, a));

  bool isSome() => fold(() => false, (_) => true);

  bool isNone() => !isSome();

  static Option<C> map2<A, A2 extends A, B, B2 extends B, C>(Option<A2> fa, Option<B2> fb, C fun(A a, B b)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => some(fun(a, b))));

  static Option<D> map3<A, A2 extends A, B, B2 extends B, C, C2 extends C, D>(Option<A2> fa, Option<B2> fb, Option<C2> fc, D fun(A a, B b, C c)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => some(fun(a, b, c)))));

  static Option<E> map4<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, E fun(A a, B b, C c, D d)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => some(fun(a, b, c, d))))));

  static Option<F> map5<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, F fun(A a, B b, C c, D d, E e)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => some(fun(a, b, c, d, e)))))));

  static Option<G> map6<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, Option<F2> ff, G fun(A a, B b, C c, D d, E e, F f)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => some(fun(a, b, c, d, e, f))))))));

  static Option<H> map7<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G, G2 extends G, H>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, Option<F2> ff, Option<G2> fg, H fun(A a, B b, C c, D d, E e, F f, G g)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => fg.fold(none, (g) => some(fun(a, b, c, d, e, f, g)))))))));

  static Option<I> map8<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G, G2 extends G, H, H2 extends H, I>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, Option<F2> ff, Option<G2> fg, Option<H2> fh, I fun(A a, B b, C c, D d, E e, F f, G g, H h)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => fg.fold(none, (g) => fh.fold(none, (h) => some(fun(a, b, c, d, e, f, g, h))))))))));

  static Option<J> map9<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G, G2 extends G, H, H2 extends H, I, I2 extends I, J>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, Option<F2> ff, Option<G2> fg, Option<H2> fh, Option<I2> fi, J fun(A a, B b, C c, D d, E e, F f, G g, H h, I i)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => fg.fold(none, (g) => fh.fold(none, (h) => fi.fold(none, (i) => some(fun(a, b, c, d, e, f, g, h, i)))))))))));

  static Option<K> map10<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G, G2 extends G, H, H2 extends H, I, I2 extends I, J, J2 extends J, K>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, Option<F2> ff, Option<G2> fg, Option<H2> fh, Option<I2> fi, Option<J2> fj, K fun(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => fg.fold(none, (g) => fh.fold(none, (h) => fi.fold(none, (i) => fj.fold(none, (j) => some(fun(a, b, c, d, e, f, g, h, i, j))))))))))));

  static Option<L> map11<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G, G2 extends G, H, H2 extends H, I, I2 extends I, J, J2 extends J, K, K2 extends K, L>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, Option<F2> ff, Option<G2> fg, Option<H2> fh, Option<I2> fi, Option<J2> fj, Option<K2> fk, L fun(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => fg.fold(none, (g) => fh.fold(none, (h) => fi.fold(none, (i) => fj.fold(none, (j) => fk.fold(none, (k) => some(fun(a, b, c, d, e, f, g, h, i, j, k)))))))))))));

  static Option<M> map12<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G, G2 extends G, H, H2 extends H, I, I2 extends I, J, J2 extends J, K, K2 extends K, L, L2 extends L, M>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, Option<F2> ff, Option<G2> fg, Option<H2> fh, Option<I2> fi, Option<J2> fj, Option<K2> fk, Option<L2> fl, M fun(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => fg.fold(none, (g) => fh.fold(none, (h) => fi.fold(none, (i) => fj.fold(none, (j) => fk.fold(none, (k) => fl.fold(none, (l) => some(fun(a, b, c, d, e, f, g, h, i, j, k, l))))))))))))));

  static Option<N> map13<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G, G2 extends G, H, H2 extends H, I, I2 extends I, J, J2 extends J, K, K2 extends K, L, L2 extends L, M, M2 extends M, N>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, Option<F2> ff, Option<G2> fg, Option<H2> fh, Option<I2> fi, Option<J2> fj, Option<K2> fk, Option<L2> fl, Option<M2> fm, N fun(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l, M m)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => fg.fold(none, (g) => fh.fold(none, (h) => fi.fold(none, (i) => fj.fold(none, (j) => fk.fold(none, (k) => fl.fold(none, (l) => fm.fold(none, (m) => some(fun(a, b, c, d, e, f, g, h, i, j, k, l, m)))))))))))))));

  static Option<O> map14<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G, G2 extends G, H, H2 extends H, I, I2 extends I, J, J2 extends J, K, K2 extends K, L, L2 extends L, M, M2 extends M, N, N2 extends N, O>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, Option<F2> ff, Option<G2> fg, Option<H2> fh, Option<I2> fi, Option<J2> fj, Option<K2> fk, Option<L2> fl, Option<M2> fm, Option<N2> fn, O fun(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l, M m, N n)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => fg.fold(none, (g) => fh.fold(none, (h) => fi.fold(none, (i) => fj.fold(none, (j) => fk.fold(none, (k) => fl.fold(none, (l) => fm.fold(none, (m) => fn.fold(none, (n) => some(fun(a, b, c, d, e, f, g, h, i, j, k, l, m, n))))))))))))))));

  static Option<P> map15<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G, G2 extends G, H, H2 extends H, I, I2 extends I, J, J2 extends J, K, K2 extends K, L, L2 extends L, M, M2 extends M, N, N2 extends N, O, O2 extends O, P>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, Option<F2> ff, Option<G2> fg, Option<H2> fh, Option<I2> fi, Option<J2> fj, Option<K2> fk, Option<L2> fl, Option<M2> fm, Option<N2> fn, Option<O2> fo, P fun(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l, M m, N n, O o)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => fg.fold(none, (g) => fh.fold(none, (h) => fi.fold(none, (i) => fj.fold(none, (j) => fk.fold(none, (k) => fl.fold(none, (l) => fm.fold(none, (m) => fn.fold(none, (n) => fo.fold(none, (o) => some(fun(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o)))))))))))))))));

  static Option<Q> map16<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G, G2 extends G, H, H2 extends H, I, I2 extends I, J, J2 extends J, K, K2 extends K, L, L2 extends L, M, M2 extends M, N, N2 extends N, O, O2 extends O, P, P2 extends P, Q>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, Option<F2> ff, Option<G2> fg, Option<H2> fh, Option<I2> fi, Option<J2> fj, Option<K2> fk, Option<L2> fl, Option<M2> fm, Option<N2> fn, Option<O2> fo, Option<P2> fp, Q fun(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l, M m, N n, O o, P p)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => fg.fold(none, (g) => fh.fold(none, (h) => fi.fold(none, (i) => fj.fold(none, (j) => fk.fold(none, (k) => fl.fold(none, (l) => fm.fold(none, (m) => fn.fold(none, (n) => fo.fold(none, (o) => fp.fold(none, (p) => some(fun(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p))))))))))))))))));

  static Option<R> map17<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G, G2 extends G, H, H2 extends H, I, I2 extends I, J, J2 extends J, K, K2 extends K, L, L2 extends L, M, M2 extends M, N, N2 extends N, O, O2 extends O, P, P2 extends P, Q, Q2 extends Q, R>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, Option<F2> ff, Option<G2> fg, Option<H2> fh, Option<I2> fi, Option<J2> fj, Option<K2> fk, Option<L2> fl, Option<M2> fm, Option<N2> fn, Option<O2> fo, Option<P2> fp, Option<Q2> fq, R fun(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l, M m, N n, O o, P p, Q q)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => fg.fold(none, (g) => fh.fold(none, (h) => fi.fold(none, (i) => fj.fold(none, (j) => fk.fold(none, (k) => fl.fold(none, (l) => fm.fold(none, (m) => fn.fold(none, (n) => fo.fold(none, (o) => fp.fold(none, (p) => fq.fold(none, (q) => some(fun(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q)))))))))))))))))));

  static Option<S> map18<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G, G2 extends G, H, H2 extends H, I, I2 extends I, J, J2 extends J, K, K2 extends K, L, L2 extends L, M, M2 extends M, N, N2 extends N, O, O2 extends O, P, P2 extends P, Q, Q2 extends Q, R, R2 extends R, S>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, Option<F2> ff, Option<G2> fg, Option<H2> fh, Option<I2> fi, Option<J2> fj, Option<K2> fk, Option<L2> fl, Option<M2> fm, Option<N2> fn, Option<O2> fo, Option<P2> fp, Option<Q2> fq, Option<R2> fr, S fun(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l, M m, N n, O o, P p, Q q, R r)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => fg.fold(none, (g) => fh.fold(none, (h) => fi.fold(none, (i) => fj.fold(none, (j) => fk.fold(none, (k) => fl.fold(none, (l) => fm.fold(none, (m) => fn.fold(none, (n) => fo.fold(none, (o) => fp.fold(none, (p) => fq.fold(none, (q) => fr.fold(none, (r) => some(fun(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r))))))))))))))))))));

  static Option<T> map19<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G, G2 extends G, H, H2 extends H, I, I2 extends I, J, J2 extends J, K, K2 extends K, L, L2 extends L, M, M2 extends M, N, N2 extends N, O, O2 extends O, P, P2 extends P, Q, Q2 extends Q, R, R2 extends R, S, S2 extends S, T>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, Option<F2> ff, Option<G2> fg, Option<H2> fh, Option<I2> fi, Option<J2> fj, Option<K2> fk, Option<L2> fl, Option<M2> fm, Option<N2> fn, Option<O2> fo, Option<P2> fp, Option<Q2> fq, Option<R2> fr, Option<S2> fs, T fun(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l, M m, N n, O o, P p, Q q, R r, S s)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => fg.fold(none, (g) => fh.fold(none, (h) => fi.fold(none, (i) => fj.fold(none, (j) => fk.fold(none, (k) => fl.fold(none, (l) => fm.fold(none, (m) => fn.fold(none, (n) => fo.fold(none, (o) => fp.fold(none, (p) => fq.fold(none, (q) => fr.fold(none, (r) => fs.fold(none, (s) => some(fun(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s)))))))))))))))))))));

  static Option<U> map20<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G, G2 extends G, H, H2 extends H, I, I2 extends I, J, J2 extends J, K, K2 extends K, L, L2 extends L, M, M2 extends M, N, N2 extends N, O, O2 extends O, P, P2 extends P, Q, Q2 extends Q, R, R2 extends R, S, S2 extends S, T, T2 extends T, U>(Option<A2> fa, Option<B2> fb, Option<C2> fc, Option<D2> fd, Option<E2> fe, Option<F2> ff, Option<G2> fg, Option<H2> fh, Option<I2> fi, Option<J2> fj, Option<K2> fk, Option<L2> fl, Option<M2> fm, Option<N2> fn, Option<O2> fo, Option<P2> fp, Option<Q2> fq, Option<R2> fr, Option<S2> fs, Option<T2> ft, U fun(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l, M m, N n, O o, P p, Q q, R r, S s, T t)) =>
    fa.fold(none, (a) => fb.fold(none, (b) => fc.fold(none, (c) => fd.fold(none, (d) => fe.fold(none, (e) => ff.fold(none, (f) => fg.fold(none, (g) => fh.fold(none, (h) => fi.fold(none, (i) => fj.fold(none, (j) => fk.fold(none, (k) => fl.fold(none, (l) => fm.fold(none, (m) => fn.fold(none, (n) => fo.fold(none, (o) => fp.fold(none, (p) => fq.fold(none, (q) => fr.fold(none, (r) => fs.fold(none, (s) => ft.fold(none, (t) => some(fun(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t))))))))))))))))))))));

  static Option<C> mapM2<A, A2 extends A, B, B2 extends B, C>(Option<A2> fa, Option<B2> fb, Option<C> f(A a, B b)) => fa.bind((a) => fb.bind((b) => f(a, b)));

  static Function1<Option<A>, Option<B>> lift<A, B>(B f(A a)) => ((Option<A> oa) => oa.map(f));
  static Function2<Option<A>, Option<B>, Option<C>> lift2<A, B, C>(C f(A a, B b)) => (Option<A> fa, Option<B> fb) => map2(fa, fb, f);
  static Function3<Option<A>, Option<B>, Option<C>, Option<D>> lift3<A, B, C, D>(D f(A a, B b, C c)) => (Option<A> fa, Option<B> fb, Option<C> fc) => map3(fa, fb, fc, f);
  static Function4<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>> lift4<A, B, C, D, E>(E f(A a, B b, C c, D d)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd) => map4(fa, fb, fc, fd, f);
  static Function5<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>> lift5<A, B, C, D, E, F>(F f(A a, B b, C c, D d, E e)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe) => map5(fa, fb, fc, fd, fe, f);
  static Function6<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>, Option<G>> lift6<A, B, C, D, E, F, G>(G f(A a, B b, C c, D d, E e, F f)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe, Option<F> ff) => map6(fa, fb, fc, fd, fe, ff, f);
  static Function7<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>, Option<G>, Option<H>> lift7<A, B, C, D, E, F, G, H>(H f(A a, B b, C c, D d, E e, F f, G g)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe, Option<F> ff, Option<G> fg) => map7(fa, fb, fc, fd, fe, ff, fg, f);
  static Function8<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>, Option<G>, Option<H>, Option<I>> lift8<A, B, C, D, E, F, G, H, I>(I f(A a, B b, C c, D d, E e, F f, G g, H h)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe, Option<F> ff, Option<G> fg, Option<H> fh) => map8(fa, fb, fc, fd, fe, ff, fg, fh, f);
  static Function9<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>, Option<G>, Option<H>, Option<I>, Option<J>> lift9<A, B, C, D, E, F, G, H, I, J>(J f(A a, B b, C c, D d, E e, F f, G g, H h, I i)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe, Option<F> ff, Option<G> fg, Option<H> fh, Option<I> fi) => map9(fa, fb, fc, fd, fe, ff, fg, fh, fi, f);
  static Function10<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>, Option<G>, Option<H>, Option<I>, Option<J>, Option<K>> lift10<A, B, C, D, E, F, G, H, I, J, K>(K f(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe, Option<F> ff, Option<G> fg, Option<H> fh, Option<I> fi, Option<J> fj) => map10(fa, fb, fc, fd, fe, ff, fg, fh, fi, fj, f);
  static Function11<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>, Option<G>, Option<H>, Option<I>, Option<J>, Option<K>, Option<L>> lift11<A, B, C, D, E, F, G, H, I, J, K, L>(L f(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe, Option<F> ff, Option<G> fg, Option<H> fh, Option<I> fi, Option<J> fj, Option<K> fk) => map11(fa, fb, fc, fd, fe, ff, fg, fh, fi, fj, fk, f);
  static Function12<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>, Option<G>, Option<H>, Option<I>, Option<J>, Option<K>, Option<L>, Option<M>> lift12<A, B, C, D, E, F, G, H, I, J, K, L, M>(M f(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe, Option<F> ff, Option<G> fg, Option<H> fh, Option<I> fi, Option<J> fj, Option<K> fk, Option<L> fl) => map12(fa, fb, fc, fd, fe, ff, fg, fh, fi, fj, fk, fl, f);
  static Function13<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>, Option<G>, Option<H>, Option<I>, Option<J>, Option<K>, Option<L>, Option<M>, Option<N>> lift13<A, B, C, D, E, F, G, H, I, J, K, L, M, N>(N f(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l, M m)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe, Option<F> ff, Option<G> fg, Option<H> fh, Option<I> fi, Option<J> fj, Option<K> fk, Option<L> fl, Option<M> fm) => map13(fa, fb, fc, fd, fe, ff, fg, fh, fi, fj, fk, fl, fm, f);
  static Function14<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>, Option<G>, Option<H>, Option<I>, Option<J>, Option<K>, Option<L>, Option<M>, Option<N>, Option<O>> lift14<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>(O f(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l, M m, N n)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe, Option<F> ff, Option<G> fg, Option<H> fh, Option<I> fi, Option<J> fj, Option<K> fk, Option<L> fl, Option<M> fm, Option<N> fn) => map14(fa, fb, fc, fd, fe, ff, fg, fh, fi, fj, fk, fl, fm, fn, f);
  static Function15<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>, Option<G>, Option<H>, Option<I>, Option<J>, Option<K>, Option<L>, Option<M>, Option<N>, Option<O>, Option<P>> lift15<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>(P f(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l, M m, N n, O o)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe, Option<F> ff, Option<G> fg, Option<H> fh, Option<I> fi, Option<J> fj, Option<K> fk, Option<L> fl, Option<M> fm, Option<N> fn, Option<O> fo) => map15(fa, fb, fc, fd, fe, ff, fg, fh, fi, fj, fk, fl, fm, fn, fo, f);
  static Function16<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>, Option<G>, Option<H>, Option<I>, Option<J>, Option<K>, Option<L>, Option<M>, Option<N>, Option<O>, Option<P>, Option<Q>> lift16<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q>(Q f(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l, M m, N n, O o, P p)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe, Option<F> ff, Option<G> fg, Option<H> fh, Option<I> fi, Option<J> fj, Option<K> fk, Option<L> fl, Option<M> fm, Option<N> fn, Option<O> fo, Option<P> fp) => map16(fa, fb, fc, fd, fe, ff, fg, fh, fi, fj, fk, fl, fm, fn, fo, fp, f);
  static Function17<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>, Option<G>, Option<H>, Option<I>, Option<J>, Option<K>, Option<L>, Option<M>, Option<N>, Option<O>, Option<P>, Option<Q>, Option<R>> lift17<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R>(R f(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l, M m, N n, O o, P p, Q q)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe, Option<F> ff, Option<G> fg, Option<H> fh, Option<I> fi, Option<J> fj, Option<K> fk, Option<L> fl, Option<M> fm, Option<N> fn, Option<O> fo, Option<P> fp, Option<Q> fq) => map17(fa, fb, fc, fd, fe, ff, fg, fh, fi, fj, fk, fl, fm, fn, fo, fp, fq, f);
  static Function18<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>, Option<G>, Option<H>, Option<I>, Option<J>, Option<K>, Option<L>, Option<M>, Option<N>, Option<O>, Option<P>, Option<Q>, Option<R>, Option<S>> lift18<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S>(S f(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l, M m, N n, O o, P p, Q q, R r)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe, Option<F> ff, Option<G> fg, Option<H> fh, Option<I> fi, Option<J> fj, Option<K> fk, Option<L> fl, Option<M> fm, Option<N> fn, Option<O> fo, Option<P> fp, Option<Q> fq, Option<R> fr) => map18(fa, fb, fc, fd, fe, ff, fg, fh, fi, fj, fk, fl, fm, fn, fo, fp, fq, fr, f);
  static Function19<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>, Option<G>, Option<H>, Option<I>, Option<J>, Option<K>, Option<L>, Option<M>, Option<N>, Option<O>, Option<P>, Option<Q>, Option<R>, Option<S>, Option<T>> lift19<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T>(T f(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l, M m, N n, O o, P p, Q q, R r, S s)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe, Option<F> ff, Option<G> fg, Option<H> fh, Option<I> fi, Option<J> fj, Option<K> fk, Option<L> fl, Option<M> fm, Option<N> fn, Option<O> fo, Option<P> fp, Option<Q> fq, Option<R> fr, Option<S> fs) => map19(fa, fb, fc, fd, fe, ff, fg, fh, fi, fj, fk, fl, fm, fn, fo, fp, fq, fr, fs, f);
  static Function20<Option<A>, Option<B>, Option<C>, Option<D>, Option<E>, Option<F>, Option<G>, Option<H>, Option<I>, Option<J>, Option<K>, Option<L>, Option<M>, Option<N>, Option<O>, Option<P>, Option<Q>, Option<R>, Option<S>, Option<T>, Option<U>> lift20<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U>(U f(A a, B b, C c, D d, E e, F f, G g, H h, I i, J j, K k, L l, M m, N n, O o, P p, Q q, R r, S s, T t)) => (Option<A> fa, Option<B> fb, Option<C> fc, Option<D> fd, Option<E> fe, Option<F> ff, Option<G> fg, Option<H> fh, Option<I> fi, Option<J> fj, Option<K> fk, Option<L> fl, Option<M> fm, Option<N> fn, Option<O> fo, Option<P> fp, Option<Q> fq, Option<R> fr, Option<S> fs, Option<T> ft) => map20(fa, fb, fc, fd, fe, ff, fg, fh, fi, fj, fk, fl, fm, fn, fo, fp, fq, fr, fs, ft, f);

  @override String toString() => fold(() => 'None', (a) => 'Some($a)');

  // PURISTS BEWARE: side effecty stuff below -- proceed with caution!

  Iterable<A> toIterable() => fold(() => const Iterable.empty(), (a) => new _SingletonIterable(a));
  Iterator<A> iterator() => toIterable().iterator;

  void forEach(void sideEffect(A a)) => fold(() => null, sideEffect);
}

class Some<A> extends Option<A> {
  final A _a;
  const Some(this._a);
  A get value => _a;
  @override B fold<B>(B ifNone(), B ifSome(A a)) => ifSome(_a);
  @override bool operator ==(other) => other is Some && other._a == _a;
  @override int get hashCode => _a.hashCode;
}

class None<A> extends Option<A> {
  const None();
  @override B fold<B>(B ifNone(), B ifSome(A a)) => ifNone();
  @override bool operator ==(other) => other is None;
  @override int get hashCode => 0;
}

Option<A> none<A>() => new None();
Option<A> some<A>(A a) => new Some(a);
Option<A> option<A>(bool test, A value) => test ? some(value) : none();
Option<A> optionOf<A>(A value) => value != null ? some(value) : none();

class OptionMonadPlus extends MonadPlus<Option> with Monad<Option>, ApplicativePlus<Option>, Applicative<Option>, Functor<Option>, PlusEmpty<Option>, Plus<Option> {
  @override Option<B> map<A, B>(covariant Option<A> fa, B f(A a)) => fa.map(f);
  @override Option<B> ap<A, B>(covariant Option<A> fa, covariant Option<Function1<A, B>> ff) => fa.ap(ff);
  @override Option<B> bind<A, B>(covariant Option<A> fa, covariant Function1<A, Option<B>> f) => fa.bind(f);
  @override Option<A> empty<A>() => none();
  @override Option<A> plus<A>(covariant Option<A> f1, covariant Option<A> f2) => f1.plus(f2);
  @override Option<A> pure<A>(A a) => some(a);
}

class OptionTraversable extends Traversable<Option> {
  @override B foldMap<A, B>(Monoid<B> bMonoid, covariant Option<A> fa, B f(A a)) => fa.foldMap(bMonoid, f);
  @override Option<B> map<A, B>(covariant Option<A> fa, B f(A a)) => fa.map(f);
}

class OptionMonoid<A> extends Monoid<Option<A>> {
  final Semigroup<A> _tSemigroup;

  OptionMonoid(this._tSemigroup);

  @override Option<A> zero() => none();

  @override Option<A> append(Option<A> oa1, Option<A> oa2) => oa1.fold(() => oa2, (a1) => oa2.fold(() => oa1, (a2) => some(_tSemigroup.append(a1, a2))));
}
Monoid<Option<A>> optionMi<A>(Semigroup<A> si) => new OptionMonoid(si);

class _SingletonIterable<A> extends Iterable<A> {
  final A _singleton;
  _SingletonIterable(this._singleton);
  @override Iterator<A> get iterator => new _SingletonIterator(_singleton);
}

class _SingletonIterator<A> extends Iterator<A> {
  final A _singleton;
  int _moves = 0;
  _SingletonIterator(this._singleton);
  @override A get current => _moves == 1 ? _singleton : null!; // ignore: null_check_always_fails
  @override bool moveNext() => ++_moves == 1;
}