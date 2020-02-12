// ignore_for_file: unnecessary_new

part of dartz;

class IVector<A> implements TraversableMonadPlusOps<IVector, A> {
  final IMap<int, A> _elementsByIndex;
  final int _offset;
  final int _length;

  IVector._internal(this._elementsByIndex, this._offset, this._length);

  factory IVector.emptyVector() => new IVector._internal(new IMap.empty(IntOrder), 0, 0);

  factory IVector.from(Iterable<A> iterable) => iterable.fold(emptyVector(), (p, a) => p.appendElement(a));

  IVector<A> prependElement(A a) => new IVector._internal(_elementsByIndex.put(_offset-1, a), _offset-1, _length+1);

  IVector<A> appendElement(A a) => new IVector._internal(_elementsByIndex.put(_offset+_length, a), _offset, _length+1);

  Option<Tuple2<A, IVector<A>>> removeFirst() => get(0).map((first) => tuple2(first, new IVector._internal(_elementsByIndex.remove(_offset), _offset+1, _length-1)));

  IVector<A> dropFirst() => _length == 0 ? this : new IVector._internal(_elementsByIndex.remove(_offset), _offset+1, _length-1);

  Option<Tuple2<A, IVector<A>>> removeLast() => get(_length-1).map((last) => tuple2(last, new IVector._internal(_elementsByIndex.remove(_offset+(_length-1)), _offset, _length-1)));

  IVector<A> dropLast() => _length == 0 ? this : new IVector._internal(_elementsByIndex.remove(_offset+(_length-1)), _offset, _length-1);

  Option<A> get(int index) => _elementsByIndex.get(_offset+index);

  Option<A> operator [](int i) => get(i);

  Option<IVector<A>> set(int index, A a) => _elementsByIndex.set(_offset+index, a).map((newElements) => new IVector._internal(newElements, _offset, _length));

  IVector<A> setIfPresent(int index, A a) => new IVector._internal(_elementsByIndex.setIfPresent(_offset+index, a), _offset, _length);

  IVector<B> pure<B>(B b) => emptyVector<B>().appendElement(b);

  @override IVector<B> map<B>(B f(A a)) => new IVector._internal(_elementsByIndex.map(f), _offset, _length);

  @override IVector<B> mapWithIndex<B>(B f(int i, A a)) => new IVector._internal(_elementsByIndex.mapWithKey((i, a) => f(i-_offset, a)), _offset, _length);

  @override IVector<B> bind<B>(Function1<A, IVector<B>> f) => foldLeft(emptyVector(), (p, a) => p.plus(f(a)));

  @override IVector<B> flatMap<B>(Function1<A, IVector<B>> f) => bind(f);

  IVector<A> empty() => emptyVector();

  @override IVector<A> plus(IVector<A> fa2) {
    final int l = length();
    if (l == 0) {
      return fa2;
    } else {
      final int fa2l = fa2.length();
      if (fa2l == 0) {
        return this;
      } else if (l < fa2l) {
        return foldRight(fa2, (a, p) => p.prependElement(a));
      } else {
        return fa2.foldLeft(this, (p, a) => p.appendElement(a));
      }
    }
  }

  Option<IVector<B>> traverseOption<B>(Option<B> f(A a)) =>
    _elementsByIndex.foldLeft(some(emptyVector()),
        (prev, a) => prev.fold(none, (p) => f(a).fold(none, (b) => some(p.appendElement(b)))));

  Either<L, IVector<B>> traverseEither<L, B>(Either<L, B> f(A a)) =>
    _elementsByIndex.foldLeft(right(emptyVector()),
        (prev, a) => prev.fold(left, (p) => f(a).fold(left, (b) => right(p.appendElement(b)))));

  Future<IVector<B>> traverseFuture<B>(Future<B> f(A a)) =>
    _elementsByIndex.foldLeft(new Future.microtask(emptyVector),
        (prev, a) => prev.then((p) => f(a).then((b) => p.appendElement(b))));

  State<S, IVector<B>> traverseState<S, B>(State<S, B> f(A a)) =>
    _elementsByIndex.foldLeft(new State((s) => tuple2(emptyVector(), s)), (prev, a) => prev.flatMap((p) => f(a).map((b) => p.appendElement(b))));

  static Option<IVector<A>> sequenceOption<A>(IVector<Option<A>> voa) => voa.traverseOption(id);

  static Either<L, IVector<A>> sequenceEither<L, A>(IVector<Either<L, A>> vea) => vea.traverseEither(id);

  static Future<IVector<A>> sequenceFuture<A>(IVector<Future<A>> vfa) => vfa.traverseFuture(id);

  static State<S, IVector<A>> sequenceState<S, A>(IVector<State<S, A>> vsa) => vsa.traverseState(id);

  @override B foldMap<B>(Monoid<B> bMonoid, B f(A a)) => _elementsByIndex.foldMap(bMonoid, f);

  @override B foldLeft<B>(B z, B f(B previous, A a)) => _elementsByIndex.foldLeft(z, f);

  @override B foldLeftWithIndex<B>(B z, B f(B previous, int i, A a)) => _elementsByIndex.foldLeftKV(z, (previous, i, a) => f(previous, i-_offset, a));

  B foldLeftWithIndexBetween<B>(int minIndex, int maxIndex, B z, B f(B previous, int index, A a)) =>
      _elementsByIndex.foldLeftKVBetween(_offset+minIndex, _offset+maxIndex, z, (previous, i, a) => f(previous, i-_offset, a));

  @override B foldRight<B>(B z, B f(A a, B previous)) => _elementsByIndex.foldRight(z, f);

  @override B foldRightWithIndex<B>(B z, B f(int i, A a, B previous)) => _elementsByIndex.foldRightKV(z, (i, a, previous) => f(i-_offset, a, previous));

  B foldRightWithIndexBetween<B>(int minIndex, int maxIndex, B z, B f(int index, A a, B previous)) =>
      _elementsByIndex.foldRightKVBetween(_offset+minIndex, _offset+maxIndex, z, (i, a, previous) => f(i-_offset, a, previous));

  @override IVector<A> filter(bool predicate(A a)) => bind((a) => predicate(a) ? pure(a) : empty());

  @override IVector<A> where(bool predicate(A a)) => filter(predicate);

  @override int length() => _length;

  bool get isEmpty => length() == 0;

  static final Option<int> _NOT_FOUND = none();

  Option<int> indexOf(A element, {int start = 0, Eq<A> eq}) {
    final effectiveEq = eq ?? ObjectEq;
    return _elementsByIndex.cata(_NOT_FOUND, (_) => _NOT_FOUND, (result, index, v, cataLeft, cataRight) {
      if ((index-_offset) < start) {
        return cataRight(result);
      } else {
        return cataLeft(result)
          .orElse(() => effectiveEq.eq(element, v) ? some(index-_offset) : _NOT_FOUND)
          .orElse(() => cataRight(result));
      }
    });
  }

  // TODO: kill MonadOps flatten and rename in 0.8.0
  static IVector<A> flattenIVector<A>(IVector<IVector<A>> ffa) => ffa.flatMap(id);

  static IVector<A> flattenOption<A>(IVector<Option<A>> oas) => oas.foldLeft(emptyVector(), (acc, oa) => oa.fold(() => acc, (a) => acc.appendElement(a)));


  @override bool operator ==(other) => identical(this, other) || (other is IVector && ObjectIteratorEq.eq(_elementsByIndex.valueIterator(), other._elementsByIndex.valueIterator()));

  @override int get hashCode => _elementsByIndex.values().hashCode;

  @override String toString() => "ivector[${map((A a) => a.toString()).intercalate(StringMi, ', ')}]";

  @override IVector<Tuple2<int, A>> zipWithIndex() => mapWithIndex(tuple2);

  @override bool all(bool f(A a)) => foldMap(BoolAndMi, f); // TODO: optimize
  @override bool every(bool f(A a)) => all(f);

  @override bool any(bool f(A a)) => foldMap(BoolOrMi, f); // TODO: optimize

  @override A concatenate(Monoid<A> mi) => foldMap(mi, id); // TODO: optimize

  @override Option<A> concatenateO(Semigroup<A> si) => foldMapO(si, id); // TODO: optimize

  @override Option<B> foldMapO<B>(Semigroup<B> si, B f(A a)) =>
    foldMap(new OptionMonoid(si), composeF(some, f)); // TODO: optimize

  @override A intercalate(Monoid<A> mi, A a) =>
    foldRight(none<A>(), (A ca, Option<A> oa) => some(mi.append(ca, oa.fold(mi.zero, mi.appendC(a))))) | mi.zero(); // TODO: optimize

  @override Option<A> maximum(Order<A> oa) => concatenateO(oa.maxSi());

  @override Option<A> minimum(Order<A> oa) => concatenateO(oa.minSi());

  @override IVector<B> andThen<B>(IVector<B> next) => bind((_) => next);

  @override IVector<B> ap<B>(IVector<Function1<A, B>> ff) => ff.bind((f) => map(f)); // TODO: optimize

  @override IVector<B> replace<B>(B replacement) => map((_) => replacement);

  @override IVector<Tuple2<B, A>> strengthL<B>(B b) => map((a) => tuple2(b, a));

  @override IVector<Tuple2<A, B>> strengthR<B>(B b) => map((a) => tuple2(a, b));


  // PURISTS BEWARE: side effecty stuff below -- proceed with caution!

  Iterable<A> toIterable() => _elementsByIndex.valueIterable();

  Iterator<A> iterator() => _elementsByIndex.valueIterator();

  void forEach(void sideEffect(A a)) => foldLeft(null, (_, a) => sideEffect(a));
}

IVector<A> ivector<A>(Iterable<A> iterable) => new IVector.from(iterable);

IVector<A> emptyVector<A>() => new IVector.emptyVector();

final MonadPlus<IVector> IVectorMP = new MonadPlusOpsMonadPlus<IVector>((a) => emptyVector().appendElement(a), emptyVector);
MonadPlus<IVector<A>> ivectorMP<A>() => cast(IVectorMP);
final Traversable<IVector> IVectorTr = new TraversableOpsTraversable<IVector>();

class IVectorMonoid<A> extends Monoid<IVector<A>> {
  @override IVector<A> zero() => emptyVector();
  @override IVector<A> append(IVector<A> a1, IVector<A> a2) => a1.plus(a2);
}

final Monoid<IVector> IVectorMi = new IVectorMonoid();
Monoid<IVector<A>> ivectorMi<A>() => new IVectorMonoid();
