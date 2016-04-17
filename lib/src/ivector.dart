part of dartz;

class IVector<A> extends TraversableOps<IVector, A> with FunctorOps<IVector, A>, ApplicativeOps<IVector, A>, MonadOps<IVector, A>, MonadPlusOps<IVector, A> {
  final IMap<int, A> _elementsByIndex;
  final int _prepended;
  final int _appended;

  IVector._internal(this._elementsByIndex, this._prepended, this._appended);

  factory IVector.emptyVector() => new IVector._internal(new IMap<int, A>.emptyWithOrder(IntOrder), 0, 0);

  factory IVector.from(Iterable<A> iterable) => iterable.fold(emptyVector, (IVector<A> p, A a) => p.appendElement(a));

  IVector<A> prependElement(A a) => new IVector._internal(_elementsByIndex.put(-(_prepended+1), a), _prepended+1, _appended);

  IVector<A> appendElement(A a) => new IVector._internal(_elementsByIndex.put(_appended, a), _prepended, _appended+1);

  Option<A> get(int index) => _elementsByIndex.get(index - _prepended);

  Option<IVector<A>> set(int i, A a) => _elementsByIndex.set(i, a).map((newElements) => new IVector._internal(newElements, _prepended, _appended));

  @override IVector bind(IVector f(A a)) => foldLeft(emptyVector, (IVector p, A a) => p.plus(f(a)));

  @override IVector map(f(A a)) => new IVector._internal(_elementsByIndex.map(f), _prepended, _appended);

  @override IVector<A> empty() => emptyVector;

  @override IVector<A> plus(IVector<A> fa2) {
    final int l = length();
    if (l == 0) {
      return fa2;
    } else {
      final int fa2l = fa2.length();
      if (fa2l == 0) {
        return this;
      } else if (l < fa2l) {
        return foldRight(fa2, (A a, IVector<A> p) => p.prependElement(a));
      } else {
        return fa2.foldLeft(this, (IVector<A> p, A a) => p.appendElement(a));
      }
    }
  }

  @override IVector pure(a) => emptyVector.appendElement(a);

  @override traverse(Applicative gApplicative, f(A a)) =>
      _elementsByIndex.foldLeft(gApplicative.pure(emptyVector),
          (prev, a) => gApplicative.map2(prev, f(a), (IVector p, a2) => p.appendElement(a2)));

  @override foldLeft(z, f(previous, A a)) => _elementsByIndex.foldLeft(z, f);

  @override foldRight(z, f(A a, previous)) => _elementsByIndex.foldRight(z, f);

  @override int length() => _prepended + _appended;

  @override bool operator ==(other) => identical(this, other) || (other is IVector && _elementsByIndex.values() == other._elementsByIndex.values());

  @override String toString() => "ivector[${map((A a) => a.toString()).intercalate(StringMi, ', ')}]";
}

IVector ivector(Iterable iterable) => new IVector.from(iterable);

final IVector emptyVector = new IVector.emptyVector();

final MonadPlus<IVector> IVectorMP = new MonadPlusOpsMonad((a) => emptyVector.appendElement(a), () => emptyVector);
final Monad<IVector> IVectorM = IVectorMP;
final ApplicativePlus<IVector> IVectorAP = IVectorMP;
final Applicative<IVector> IVectorA = IVectorMP;
final Functor<IVector> IVectorF = IVectorMP;
final Traversable<IVector> IVectorTr = new TraversableOpsTraversable<IVector>();
final Foldable<IVector> IVectorFo = IVectorTr;

class IVectorMonoid extends Monoid<IVector> {
  @override IVector zero() => emptyVector;
  @override IVector append(IVector a1, IVector a2) => a1.plus(a2);
}

final Monoid<IVector> IVectorMi = new IVectorMonoid();
