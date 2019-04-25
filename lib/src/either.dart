part of dartz;

abstract class Either<L, R> implements TraversableMonadOps<Either<L, dynamic>, R> {
  const Either();

  B fold<B>(B ifLeft(L l), B ifRight(R r));

  Either<L, R> orElse(Either<L, R> other()) => fold((_) => other(), (_) => this);
  R getOrElse(R dflt()) => fold((_) => dflt(), id);
  R operator |(R dflt) => getOrElse(() => dflt);
  Either<L2, R> leftMap<L2>(L2 f(L l)) => fold((L l) => left(f(l)), right);
  Option<R> toOption() => fold((_) => none(), some);
  bool isLeft() => fold((_) => true, (_) => false);
  bool isRight() => fold((_) => false, (_) => true);
  Either<R, L> swap() => fold(right, left);

  @override Either<L, R2> map<R2>(R2 f(R r)) => fold(left, (R r) => right(f(r)));
  @override Either<L, R2> bind<R2>(Either<L, R2> f(R r)) => fold(left, f);
  @override Either<L, R2> flatMap<R2>(Either<L, R2> f(R r)) => fold(left, f);
  @override Either<L, R2> andThen<R2>(Either<L, R2> next) => fold(left, (_) => next);

  IList<Either<L, R2>> traverseIList<R2>(IList<R2> f(R r)) => fold((l) => cons(left(l), nil()), (R r) => f(r).map(right));

  IVector<Either<L, R2>> traverseIVector<R2>(IVector<R2> f(R r)) => fold((l) => emptyVector<Either<L, R2>>().appendElement(left(l)), (R r) => f(r).map(right));

  Future<Either<L, R2>> traverseFuture<R2>(Future<R2> f(R r)) => fold((l) => new Future.microtask(() => left(l)), (R r) => f(r).then(right));

  State<S, Either<L, R2>> traverseState<S, R2>(State<S, R2> f(R r)) => fold((l) => new State((s) => tuple2(left(l), s)), (r) => f(r).map(right));

  static IList<Either<L, R>> sequenceIList<L, R>(Either<L, IList<R>> elr) => elr.traverseIList(id);

  static IVector<Either<L, R>> sequenceIVector<L, R>(Either<L, IVector<R>> evr) => evr.traverseIVector(id);

  static Future<Either<L, R>> sequenceFuture<L, R>(Either<L, Future<R>> efr) => efr.traverseFuture(id);

  static State<S, Either<L, R>> sequenceState<S, L, R>(Either<L, State<S, R>> esr) => esr.traverseState(id);

  Either<L, R> filter(bool predicate(R r), L fallback()) => fold((_) => this, (r) => predicate(r) ? this : left(fallback()));
  Either<L, R> where(bool predicate(R r), L fallback()) => filter(predicate, fallback);

  static Either<L, C> map2<L, A, A2 extends A, B, B2 extends B, C>(Either<L, A2> fa, Either<L, B2> fb, C fun(A a, B b)) =>
    fa.fold(left, (a) => fb.fold(left, (b) => right(fun(a, b))));

  static Either<L, D> map3<L, A, A2 extends A, B, B2 extends B, C, C2 extends C, D>(Either<L, A2> fa, Either<L, B2> fb, Either<L, C2> fc, D fun(A a, B b, C c)) =>
    fa.fold(left, (a) => fb.fold(left, (b) => fc.fold(left, (c) => right(fun(a, b, c)))));

  static Either<L, E> map4<L, A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E>(Either<L, A2> fa, Either<L, B2> fb, Either<L, C2> fc, Either<L, D2> fd, E fun(A a, B b, C c, D d)) =>
    fa.fold(left, (a) => fb.fold(left, (b) => fc.fold(left, (c) => fd.fold(left, (d) => right(fun(a, b, c, d))))));

  static Either<L, F> map5<L, A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F>(Either<L, A2> fa, Either<L, B2> fb, Either<L, C2> fc, Either<L, D2> fd, Either<L, E2> fe, F fun(A a, B b, C c, D d, E e)) =>
    fa.fold(left, (a) => fb.fold(left, (b) => fc.fold(left, (c) => fd.fold(left, (d) => fe.fold(left, (e) => right(fun(a, b, c, d, e)))))));

  static Either<L, G> map6<L, A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, F, F2 extends F, G>(Either<L, A2> fa, Either<L, B2> fb, Either<L, C2> fc, Either<L, D2> fd, Either<L, E2> fe, Either<L, F2> ff, G fun(A a, B b, C c, D d, E e, F f)) =>
    fa.fold(left, (a) => fb.fold(left, (b) => fc.fold(left, (c) => fd.fold(left, (d) => fe.fold(left, (e) => ff.fold(left, (f) => right(fun(a, b, c, d, e, f))))))));

  static Either<L, C> mapM2<L, A, A2 extends A, B, B2 extends B, C>(Either<L, A2> fa, Either<L, B2> fb, Either<L, C> f(A a, B b)) => fa.bind((a) => fb.bind((b) => f(a, b)));

  static Function1<Either<L, A>, Either<L, B>> lift<L, A, B>(B f(A a)) => ((Either<L, A> oa) => oa.map(f));
  static Function2<Either<L, A>, Either<L, B>, Either<L, C>> lift2<L, A, B, C>(C f(A a, B b)) => (Either<L, A> fa, Either<L, B> fb) => map2(fa, fb, f);
  static Function3<Either<L, A>, Either<L, B>, Either<L, C>, Either<L, D>> lift3<L, A, B, C, D>(D f(A a, B b, C c)) => (Either<L, A> fa, Either<L, B> fb, Either<L, C> fc) => map3(fa, fb, fc, f);
  static Function4<Either<L, A>, Either<L, B>, Either<L, C>, Either<L, D>, Either<L, E>> lift4<L, A, B, C, D, E>(E f(A a, B b, C c, D d)) => (Either<L, A> fa, Either<L, B> fb, Either<L, C> fc, Either<L, D> fd) => map4(fa, fb, fc, fd, f);
  static Function5<Either<L, A>, Either<L, B>, Either<L, C>, Either<L, D>, Either<L, E>, Either<L, F>> lift5<L, A, B, C, D, E, F>(F f(A a, B b, C c, D d, E e)) => (Either<L, A> fa, Either<L, B> fb, Either<L, C> fc, Either<L, D> fd, Either<L, E> fe) => map5(fa, fb, fc, fd, fe, f);
  static Function6<Either<L, A>, Either<L, B>, Either<L, C>, Either<L, D>, Either<L, E>, Either<L, F>, Either<L, G>> lift6<L, A, B, C, D, E, F, G>(G f(A a, B b, C c, D d, E e, F f)) => (Either<L, A> fa, Either<L, B> fb, Either<L, C> fc, Either<L, D> fd, Either<L, E> fe, Either<L, F> ff) => map6(fa, fb, fc, fd, fe, ff, f);

  @override String toString() => fold((l) => 'Left($l)', (r) => 'Right($r)');

  @override B foldMap<B>(Monoid<B> bMonoid, B f(R r)) => fold((_) => bMonoid.zero(), f);

  @override Either<L, B> mapWithIndex<B>(B f(int i, R r)) => map((r) => f(0, r));

  @override Either<L, Tuple2<int, R>> zipWithIndex() => map((r) => tuple2(0, r));

  @override bool all(bool f(R r)) => map(f)|true;
  @override bool every(bool f(R r)) => all(f);

  @override bool any(bool f(R r)) => map(f)|false;

  @override R concatenate(Monoid<R> mi) => getOrElse(mi.zero);

  @override Option<R> concatenateO(Semigroup<R> si) => toOption();

  @override B foldLeft<B>(B z, B f(B previous, R r)) => fold((_) => z, (a) => f(z, a));

  @override B foldLeftWithIndex<B>(B z, B f(B previous, int i, R r)) => fold((_) => z, (a) => f(z, 0, a));

  @override Option<B> foldMapO<B>(Semigroup<B> si, B f(R r)) => map(f).toOption();

  @override B foldRight<B>(B z, B f(R r, B previous)) => fold((_) => z, (a) => f(a, z));

  @override B foldRightWithIndex<B>(B z, B f(int i, R r, B previous))=> fold((_) => z, (a) => f(0, a, z));

  @override R intercalate(Monoid<R> mi, R r) => fold((_) => mi.zero(), id);

  @override int length() => fold((_) => 0, (_) => 1);

  @override Option<R> maximum(Order<R> or) => toOption();

  @override Option<R> minimum(Order<R> or) => toOption();

  @override Either<L, B> replace<B>(B replacement) => map((_) => replacement);

  Either<L, R> reverse() => this;

  @override Either<L, Tuple2<B, R>> strengthL<B>(B b) => map((a) => tuple2(b, a));

  @override Either<L, Tuple2<R, B>> strengthR<B>(B b) => map((a) => tuple2(a, b));

  @override Either<L, B> ap<B>(Either<L, Function1<R, B>> ff) => ff.bind((f) => map(f));

  // PURISTS BEWARE: side effecty stuff below -- proceed with caution!

  Iterable<R> toIterable() => fold((_) => const Iterable.empty(), (r) => new _SingletonIterable(r));
  Iterator<R> iterator() => toIterable().iterator;

  void forEach(void sideEffect(R r)) => fold((_) => null, sideEffect);
}

class Left<L, R> extends Either<L, R> {
  final L _l;
  const Left(this._l);
  L get value => _l;
  @override B fold<B>(B ifLeft(L l), B ifRight(R r)) => ifLeft(_l);
  @override bool operator ==(other) => other is Left && other._l == _l;
  @override int get hashCode => _l.hashCode;
}

class Right<L, R> extends Either<L, R> {
  final R _r;
  const Right(this._r);
  R get value => _r;
  @override B fold<B>(B ifLeft(L l), B ifRight(R r)) => ifRight(_r);
  @override bool operator ==(other) => other is Right && other._r == _r;
  @override int get hashCode => _r.hashCode;
}


Either<L, R> left<L, R>(L l) => new Left(l);
Either<L, R> right<L, R>(R r) => new Right(r);
Either<dynamic, A> catching<A>(Function0<A> thunk) {
  try {
    return right(thunk());
  } catch(e) {
    return left(e);
  }
}

class EitherMonad<L> extends MonadOpsMonad<Either<L, dynamic>> {
  EitherMonad(): super(right);
}

final EitherMonad EitherM = new EitherMonad();
EitherMonad<L> eitherM<L>() => new EitherMonad();
final Traversable<Either> EitherTr = new TraversableOpsTraversable<Either>();
Traversable<Either<L, R>> eitherTr<L, R>() => new TraversableOpsTraversable();
/*
class EitherTMonad<M> extends Functor<M> with Applicative<M>, Monad<M> {
  Monad _stackedM;
  EitherTMonad(this._stackedM);
  Monad underlying() => EitherM;

  @override M pure<A>(A a) => cast(_stackedM.pure(right(a)));
  @override M bind<A, B>(M mea, M f(A a)) => cast(_stackedM.bind(mea, (Either e) => e.fold((l) => _stackedM.pure(left(l)), cast(f))));
}

Monad eitherTMonad(Monad mmonad) => new EitherTMonad(mmonad);
*/