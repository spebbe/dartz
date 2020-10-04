library PropTest;

import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

/*
  NOTE: First, simplistic attempt at replacing the obsolete propcheck library.
  For now, it's more or less a dumbed down Dart version of the library presented in
  chapter 8 of "Functional Programming in Scala" by Paul Chiusano and Rúnar Bjarnason.
 */

@sealed
abstract class Result {
  bool get isFalsified => fold((_) => false, (_) => true);

  A fold<A>(A isPassed(Passed passed), A isFalsified(Falsified falsified));
}

class Passed extends Result {
  @override A fold<A>(A isPassed(Passed passed), A isFalsified(Falsified falsified)) => isPassed(this);
}

class Falsified extends Result {
  final String failure;
  final int successCount;

  Falsified(this.failure, this.successCount);

  @override A fold<A>(A isPassed(Passed passed), A isFalsified(Falsified falsified)) => isFalsified(this);
}

class RNG {
  static final int minInt = pow(-2, 31).toInt();
  static final int maxInt = pow(2, 31).toInt()-1;

  final int seed;

  RNG(this.seed);

  Tuple2<int, RNG> get nextInt {
    final r = new Random(seed);
    final newSeed = ((r.nextDouble()-0.5)*maxInt*2).round();
    final nextRNG = new RNG(newSeed);
    return tuple2(newSeed, nextRNG);
  }

  static Tuple2<bool, RNG> boolean(RNG rng) => rng.nextInt.map1((i) => i%2==0);

  static Tuple2<int, RNG> nonNegativeInt(RNG rng) =>
    rng.nextInt.map1((i) => i < 0 ? -(i+1) : i);

  static Tuple2<double,RNG> dbl(RNG rng) =>
    rng.nextInt.map1((i) => i/maxInt);

  static Tuple2<int,RNG> ints(RNG rng) => rng.nextInt;

}

typedef PropRun = Future<Result> Function(int maxSize, int testCases, RNG rng);

class Prop {
  final PropRun run;

  Prop(this.run);

  Prop operator &(Prop p) => Prop((max, n, rng) async {
    final result = await run(max, n, rng);
    return result.fold((passed) => p.run(max, n, rng), id);
  });

  Prop operator |(Prop p) => Prop((max, n, rng) async {
    final result = await run(max, n, rng);
    return result.fold(id, (falsified) => p.tag(falsified.failure).run(max, n, rng));
  });

  Prop tag(String msg) => Prop((max, n, rng) async {
    final result = await run(max, n, rng);
    return result.fold(id, (falsified) => Falsified("$msg\n${falsified.failure}", falsified.successCount));
  });

  static Iterable<Tuple2<A, int>> randomStream<A>(Gen<A> g, RNG rng, int max, int cases) sync* {
    final casesPerSize = (cases - 1) ~/ max + 1;
    RNG currentRng = rng;
    int index = 0;
    int currentMax = 0;
    for(int i = 0;i < cases;i++) {
      final current = g.sample(currentMax).run(currentRng);
      currentRng = current.value2;
      yield tuple2(current.value1, index);
      index++;
      currentMax = (i/casesPerSize).round();
    }
  }

  static String buildMsg<A>(A s, Object e, StackTrace st) =>
    "$s\n${e}\n${st}";

  static Prop apply(Result f(int, RNG)) => new Prop((_, n, rng) async => f(n, rng));
}

Function1<Function1<A, FutureOr<bool>> , Prop> forAll<A>(Gen<A> as) => (FutureOr<bool> f(A a)) => new Prop((max, n, rng) {
  Stream<Result> forAllStream() async* {
    for (final t in Prop.randomStream(as, rng, max, n)) {
      final a = t.value1;
      final i = t.value2;
      try {
        yield await f(a) ? new Passed() : new Falsified(a.toString(), i);
      } catch (e, st) {
        yield new Falsified(Prop.buildMsg(a, e, st), i);
      }
    }
  }
  return forAllStream().firstWhere((result) => result.isFalsified, orElse: () => new Passed());
});

Function1<Function2<A, B, FutureOr<bool>>, Prop> forAll2<A, B>(Gen<A> ga, Gen<B> gb) => (FutureOr<bool> f(A a, B b)) =>
  forAll(ga.product(gb))(tuplize2(f));

Function1<Function3<A, B, C, FutureOr<bool>>, Prop> forAll3<A, B, C>(Gen<A> ga, Gen<B> gb, Gen<C> gc) => (FutureOr<bool> f(A a, B b, C c)) =>
  forAll(ga.product(gb).product(gc).map((t) => tuple3(t.value1.value1, t.value1.value2, t.value2)))(tuplize3(f));

class Gen<A> {

  static final SM = stateM<RNG>();

  final Function1<int, State<RNG, A>> sample;

  Gen(this.sample);

  Gen<B> map<B>(B f(A a)) => new Gen((sz) => sample(sz).map(f));

  Gen<B> flatMap<B>(Gen<B> f(A a)) => new Gen((sz) => sample(sz).flatMap((a) => f(a).sample(sz)));

  Gen<Tuple2<A, B>> product<B>(Gen<B> gb) => flatMap((a) => gb.map((b) => tuple2(a, b)));

  static Gen<A> unit<A>(A a) => new Gen((sz) => SM.pure(a));

  static Gen<bool> bools = new Gen((sz) => new State(RNG.boolean));

  static Gen<int> choose(int start, int stopExclusive) =>
    new Gen((sz) => new State(RNG.nonNegativeInt).map((n) => start + n % (stopExclusive-start)));

  static Gen<IList<A>> ilistOfN<A>(int n, Gen<A> g) =>
    new Gen((sz) => IList.sequenceState(new IList.generate(n, (i) => g.sample(sz))));

  static Gen<IList<A>> ilistOf<A>(Gen<A> g) =>
    new Gen((sz) => ilistOfN(sz, g).sample(sz));

  static Gen<List<A>> listOf<A>(Gen<A> g) =>
    ilistOf(g).map((il) => il.toList());

  static Gen<Map<K, V>> mapOf<K, V>(Gen<K> gk, Gen<V> gv) => listOf(gk).product(listOf(gv))
    .map((kvs) => new Map.fromIterables(kvs.value1, kvs.value2));

  static Gen<IMap<K, V>> imapOf<K, V>(Gen<K> gk, Gen<V> gv, Order<K> order) => listOf(gk).product(listOf(gv))
    .map((kvs) => new IMap.fromIterables(kvs.value1, kvs.value2, order));

  static Gen<int> ints = new Gen((sz) => new State(RNG.ints));

  static Gen<int> sizedInts = new Gen((sz) => ints.map((i) => i.remainder(sz+1).toInt()).sample(sz));

  static Gen<int> sizedPositiveInts = sizedInts.map((i) => i.abs());

  static Gen<String> strings = ilistOf(choose(1, 127).map((c) => new String.fromCharCode(c))).map((chars) => chars.concatenate(StringMi));

  static Gen<double> uniform = new Gen((sz) => new State(RNG.dbl));

  static Gen<double> chooseDouble(double i, double j) =>
    new Gen((sz) => new State(RNG.dbl).map((d) => i + d*(j-i)));
}

class PropTest {
  final int seed;
  final int maxSuccesses;
  final int maxSize;

  PropTest({this.seed: 4711, this.maxSuccesses: 100, this.maxSize: 10});

  Future<Null> check(Prop property) async {
    final result = await property.run(maxSize, maxSuccesses, new RNG(seed));
    result.fold((passed) {}, (falsified) => fail("Falsified after ${falsified.successCount} attempts for input ${falsified.failure}"));
  }
}
