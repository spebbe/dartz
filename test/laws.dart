import 'dart:async';

import 'package:test/test.dart';

import 'package:dartz/dartz.dart';

import 'proptest/PropTest.dart';

Future<bool> defaultEquality(a, b) async => await a == await b;

final defaultPT = new PropTest();

Tuple2<dynamic, String> giveDollar(dynamic something) => tuple2(something, "\$");
Tuple2<dynamic, String> giveHash(dynamic something) => tuple2(something, "#");

void checkFunctorLaws(Functor F, Gen gen, {FutureOr<bool> equality(a, b): defaultEquality, PropTest pt: null}) {
  pt = pt != null ? pt : defaultPT;

  group("functor laws", () {
    test("identity", () async {
      await pt.check(forAll(gen)((fa) => equality(F.map(fa, id), fa)));
    });

    test("composite", () async {
      await pt.check(forAll(gen)((fa) =>
          equality(F.map(F.map(fa, giveDollar), giveHash), F.map(fa, composeF(giveHash, giveDollar)))));
    });
  });
}

void checkFoldableLaws(Foldable F, Gen gen, {FutureOr<bool> equality(a, b): defaultEquality, PropTest pt: null}) {
  pt = pt != null ? pt : defaultPT;

  group("foldable laws", () {
    test("foldLeft and foldMap consistency", () async {
      await pt.check(forAll(gen)((fa) =>
        equality(F.foldMap<dynamic, dynamic>(IListMi, fa, (a) => ilist([a])), F.foldLeft<dynamic, dynamic>(fa, ilist([]), (p, a) => p.plus(ilist([a]))))));
    });

    test("foldRight and foldMap consistency", () async {
      await pt.check(forAll(gen)((fa) =>
        equality(F.foldMap<dynamic, dynamic>(IListMi, fa, (a) => ilist([a])), F.foldRight<dynamic, dynamic>(fa, ilist([]), (a, p) => ilist([a]).plus(cast(p))))));
    });

  });
}

void checkFoldableOpsProperties(Gen gen, {FutureOr<bool> equality(a, b): defaultEquality, PropTest pt: null}) {
  pt = pt != null ? pt : defaultPT;

  group("foldable ops properties", () {
    test("foldLeftWithIndex properties", () async {
      await pt.check(forAll(gen)((fa) =>
          equality(fa.foldLeftWithIndex<IList<int>>(nil<int>(), (IList<int> p, int i, _) => cons(i, p)).reverse(), iota((fa as FoldableOps).length()))));
    });

    test("foldRightWithIndex properties", () async {
      await pt.check(forAll(gen)((fa) =>
          equality(fa.foldRightWithIndex<IList<int>>(nil<int>(), (int i, _, IList<int> p) => cons(i, p)), iota((fa as FoldableOps).length()))));
    });
  });
}

void checkTraversableLaws(Traversable T, Gen gen, {FutureOr<bool> equality(a, b): defaultEquality, PropTest pt: null}) {
  pt = pt != null ? pt : defaultPT;

  group("traversable laws", () {
    test("identity traverse", () {
      //qc.check(forall(enumeration, (fa) => equality(T.traverse<Object>(IdM, fa, giveDollar), T.map(fa, giveDollar))));
    });

    test("purity", () {
      //qc.check(forall(enumeration, (fa) => equality(T.traverse(IdM, fa, id), fa)));
    });

    // TODO: check naturality
    // TODO: check sequential fusion
    // TODO: check parallel fusion
  });

  checkFunctorLaws(T, gen, equality: equality, pt: pt);
  checkFoldableLaws(T, gen, equality: equality, pt: pt);
}

void checkMonadLaws<F>(Monad<F> M, {FutureOr<bool> equality(a, b): defaultEquality, PropTest pt: null}) {
  pt = pt != null ? pt : defaultPT;
  F double(dynamic i) => M.pure(i*2);
  F inc(dynamic i) => M.pure(i+1);

  group("monad laws", () {
    test("left identity", () async {
      await pt.check(forAll(Gen.ints)((a) => equality(M.bind<dynamic, dynamic>(M.pure(a), double), double(a))));
    });

    test("right identity", () async {
      await pt.check(forAll(Gen.ints)((a) => equality(M.bind(M.pure(a), M.pure), M.pure(a))));
    });

    test("associativity", () async {
      await pt.check(forAll(Gen.ints)((a) => equality(M.bind(M.bind(M.pure(a), double), inc), M.bind(M.pure(a), (x) => M.bind(double(x), inc)))));
    });
  });

  checkFunctorLaws(M, Gen.ints.map((i) => M.pure(i)), equality: equality, pt: pt);
}

void checkFoldableMonadLaws(Foldable F, Monad M, {FutureOr<bool> equality(a, b): defaultEquality, PropTest pt: null}) {
  pt = pt != null ? pt : defaultPT;

  group("foldable+monad laws", () {
    test("pure+concatenate identity", () async {
      await pt.check(forAll(Gen.ints)((int a) => equality(F.concatenate(IntSumMi, M.pure(a)), a)));
    });
  });

}

void checkSemigroupLaws(Semigroup Si, Gen gen, {FutureOr<bool> equality(a, b): defaultEquality, PropTest pt: null}) {
  pt = pt != null ? pt : defaultPT;

  group("semigroup laws", () {
    test("associativity", () async {
      await pt.check(forAll3(gen, gen, gen)((f1, f2, f3) {
        return equality(Si.append(f1, Si.append(f2, f3)), Si.append(Si.append(f1, f2), f3));
      }));
    });
  });

}


void checkMonoidLaws(Monoid Mi, Gen gen, {FutureOr<bool> equality(a, b): defaultEquality, PropTest pt: null}) {
  pt = pt != null ? pt : defaultPT;

  group("monoid laws", () {
    test("left identity", () async {
      await pt.check(forAll(gen)((a) => equality(a, Mi.append(Mi.zero(), a))));
    });

    test("right identity", () async {
      await pt.check(forAll(gen)((a) => equality(a, Mi.append(a, Mi.zero()))));
    });
  });

  checkSemigroupLaws(Mi, gen, equality:equality, pt:pt);
}
