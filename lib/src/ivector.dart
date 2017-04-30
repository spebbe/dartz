part of dartz;

class IVector<A> extends TraversableOps<IVector, A> with FunctorOps<IVector, A>, ApplicativeOps<IVector, A>, ApplicativePlusOps<IVector, A>, MonadOps<IVector, A>, MonadPlusOps<IVector, A>, TraversableMonadOps<IVector, A>, TraversableMonadPlusOps<IVector, A> {
  final IMap<int, A> _elementsByIndex;
  final int _offset;
  final int _length;

  IVector._internal(this._elementsByIndex, this._offset, this._length);

  factory IVector.emptyVector() => new IVector._internal(new IMap<int, A>.emptyWithOrder(IntOrder), 0, 0);

  factory IVector.from(Iterable<A> iterable) => iterable.fold(emptyVector(), (IVector<A> p, A a) => p.appendElement(a));

  IVector<A> prependElement(A a) => new IVector._internal(_elementsByIndex.put(_offset-1, a), _offset-1, _length+1);

  IVector<A> appendElement(A a) => new IVector._internal(_elementsByIndex.put(_offset+_length, a), _offset, _length+1);

  Option<Tuple2<A, IVector<A>>> removeFirst() => get(0).map((first) => tuple2(first, new IVector._internal(_elementsByIndex.remove(_offset), _offset+1, _length-1)));

  IVector<A> dropFirst() => new IVector._internal(_elementsByIndex.remove(_offset), _offset+1, _length-1);

  Option<Tuple2<A, IVector<A>>> removeLast() => get(_length-1).map((last) => tuple2(last, new IVector._internal(_elementsByIndex.remove(_offset+(_length-1)), _offset, _length-1)));

  IVector<A> dropLast() => new IVector._internal(_elementsByIndex.remove(_offset+(_length-1)), _offset, _length-1);

  Option<A> get(int index) => _elementsByIndex.get(_offset+index);

  Option<A> operator [](int i) => get(i);

  Option<IVector<A>> set(int index, A a) => _elementsByIndex.set(_offset+index, a).map((newElements) => new IVector._internal(newElements, _offset, _length));

  IVector<A> setIfPresent(int index, A a) => new IVector._internal(_elementsByIndex.setIfPresent(_offset+index, a), _offset, _length);

  @override IVector/*<B>*/ pure/*<B>*/(/*=B*/ b) => emptyVector/*<B>*/().appendElement(b);

  @override IVector/*<B>*/ map/*<B>*/(/*=B*/ f(A a)) => new IVector._internal(_elementsByIndex.map(f), _offset, _length);

  @override IVector/*<B>*/ bind/*<B>*/(IVector/*<B>*/ f(A a)) => foldLeft(emptyVector(), (IVector/*<B>*/ p, A a) => p.plus(f(a)));

  @override IVector<A> empty() => emptyVector();

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

  @override /*=G*/ traverse/*<G>*/(Applicative/*<G>*/ gApplicative, /*=G*/ f(A a)) =>
      _elementsByIndex.foldLeft(gApplicative.pure(emptyVector()),
          (prev, a) => gApplicative.map2(prev, f(a), (IVector p, a2) => p.appendElement(a2)));

  @override /*=B*/ foldLeft/*<B>*/(/*=B*/ z, /*=B*/ f(/*=B*/ previous, A a)) => _elementsByIndex.foldLeft(z, f);

  @override /*=B*/ foldLeftWithIndex/*<B>*/(/*=B*/ z, /*=B*/ f(/*=B*/ previous, int i, A a)) => _elementsByIndex.foldLeftKV(z, (previous, i, a) => f(previous, _offset+i, a));

  @override /*=B*/ foldRight/*<B>*/(/*=B*/ z, /*=B*/ f(A a, /*=B*/ previous)) => _elementsByIndex.foldRight(z, f);

  @override /*=B*/ foldRightWithIndex/*<B>*/(/*=B*/ z, /*=B*/ f(int i, A a, /*=B*/ previous)) => _elementsByIndex.foldRightKV(z, (i, a, previous) => f(_offset+i, a, previous));

  @override int length() => _length;

  @override bool operator ==(other) => identical(this, other) || (other is IVector && _elementsByIndex.values() == other._elementsByIndex.values());

  @override int get hashCode => _elementsByIndex.values().hashCode;

  @override String toString() => "ivector[${map((A a) => a.toString()).intercalate(StringMi, ', ')}]";

  // PURISTS BEWARE: mutable Iterable/Iterator integrations below -- proceed with caution!

  Iterable<A> toIterable() => _elementsByIndex.valueIterable();

  Iterator<A> iterator() => _elementsByIndex.valueIterator();
}

IVector/*<A>*/ ivector/*<A>*/(Iterable/*<A>*/ iterable) => new IVector.from(iterable);

final IVector _emptyVector = new IVector.emptyVector();
IVector/*<A>*/ emptyVector/*<A>*/() => _emptyVector as dynamic/*=IVector<A>*/;

final MonadPlus<IVector> IVectorMP = new MonadPlusOpsMonadPlus<IVector>((a) => emptyVector().appendElement(a), emptyVector);
MonadPlus<IVector/*<A>*/> ivectorMP/*<A>*/() => IVectorMP as dynamic/*=MonadPlus<IVector<A>>*/;
final Traversable<IVector> IVectorTr = new TraversableOpsTraversable<IVector>();

class IVectorMonoid<A> extends Monoid<IVector<A>> {
  @override IVector<A> zero() => emptyVector();
  @override IVector<A> append(IVector<A> a1, IVector<A> a2) => a1.plus(a2);
}

final Monoid<IVector> IVectorMi = new IVectorMonoid();
Monoid<IVector/*<A>*/> ivectorMi/*<A>*/() => IVectorMi as dynamic/*=Monoid<IVector<A>>*/;
