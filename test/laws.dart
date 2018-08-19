import 'package:test/test.dart';
//import 'package:enumerators/combinators.dart' as c;
import 'combinators_stubs.dart' as c;
//import 'package:propcheck/propcheck.dart';
import 'propcheck_stubs.dart';
//import 'package:enumerators/enumerators.dart';
import 'enumerators_stubs.dart';

import 'package:dartz/dartz.dart';

bool defaultEquality(a, b) => a == b;

final defaultQC = new QuickCheck(maxSize: 300, seed: 42);

Tuple2<dynamic, String> giveDollar(dynamic something) => tuple2(something, "\$");
Tuple2<dynamic, String> giveHash(dynamic something) => tuple2(something, "#");

void checkFunctorLaws(Functor F, Enumeration enumeration, {bool equality(a, b): defaultEquality, QuickCheck qc: null}) {
  qc = qc != null ? qc : defaultQC;

  group("functor laws", () {
    test("identity", () {
        qc.check(forall(enumeration, (fa) => equality(F.map(fa, id), fa)));
    });

    test("composite", () {
      qc.check(forall(enumeration, (fa) =>
          equality(F.map(F.map(fa, giveDollar), giveHash), F.map(fa, composeF(giveHash, giveDollar)))));
    });
  });
}

void checkFoldableLaws(Foldable F, Enumeration enumeration, {bool equality(a, b): defaultEquality, QuickCheck qc: null}) {
  qc = qc != null ? qc : defaultQC;

  group("foldable laws", () {
    test("foldLeft and foldMap consistency", () {
      qc.check(forall(enumeration, (fa) =>
        equality(F.foldMap<dynamic, dynamic>(IListMi, fa, (a) => ilist([a])), F.foldLeft<dynamic, dynamic>(fa, ilist([]), (p, a) => p.plus(ilist([a]))))));
    });

    test("foldRight and foldMap consistency", () {
      qc.check(forall(enumeration, (fa) =>
        equality(F.foldMap<dynamic, dynamic>(IListMi, fa, (a) => ilist([a])), F.foldRight<dynamic, dynamic>(fa, ilist([]), (a, p) => ilist([a]).plus(cast(p))))));
    });

  });
}

void checkFoldableOpsProperties(Enumeration<FoldableOps> enumeration, {bool equality(a, b): defaultEquality, QuickCheck qc: null}) {
  qc = qc != null ? qc : defaultQC;

  group("foldable ops properties", () {
    test("foldLeftWithIndex properties", () {
      qc.check(forall(enumeration, (fa) =>
          equality(fa.foldLeftWithIndex<IList<int>>(nil<int>(), (IList<int> p, int i, _) => cons(i, p)).reverse(), iota((fa as FoldableOps).length()))));
    });

    test("foldRightWithIndex properties", () {
      qc.check(forall(enumeration, (fa) =>
          equality(fa.foldRightWithIndex<IList<int>>(nil<int>(), (int i, _, IList<int> p) => cons(i, p)), iota((fa as FoldableOps).length()))));
    });
  });
}

void checkTraversableLaws(Traversable T, Enumeration enumeration, {bool equality(a, b): defaultEquality, QuickCheck qc: null}) {
  qc = qc != null ? qc : defaultQC;

  group("traversable laws", () {
    test("identity traverse", () {
      qc.check(forall(enumeration, (fa) => equality(T.traverse<Object>(IdM, fa, giveDollar), T.map(fa, giveDollar))));
    });

    test("purity", () {
      qc.check(forall(enumeration, (fa) => equality(T.traverse(IdM, fa, id), fa)));
    });

    // TODO: check naturality
    // TODO: check sequential fusion
    // TODO: check parallel fusion
  });

  checkFunctorLaws(T, enumeration, equality: equality, qc: qc);
  checkFoldableLaws(T, enumeration, equality: equality, qc: qc);
}

void checkMonadLaws<F>(Monad<F> M, {bool equality(a, b): defaultEquality, QuickCheck qc: null}) {
  qc = qc != null ? qc : defaultQC;
  F double(dynamic i) => M.pure(i*2);
  F inc(dynamic i) => M.pure(i+1);

  group("monad laws", () {
    test("left identity", () {
      qc.check(forall(c.ints, (a) => equality(M.bind<dynamic, dynamic>(M.pure(a), double), double(a))));
    });

    test("right identity", () {
      qc.check(forall(c.ints, (a) => equality(M.bind(M.pure(a), M.pure), M.pure(a))));
    });

    test("associativity", () {
      qc.check(forall(c.ints, (a) => equality(M.bind(M.bind(M.pure(a), double), inc), M.bind(M.pure(a), (x) => M.bind(double(x), inc)))));
    });
  });

  checkFunctorLaws(M, c.ints.map((i) => M.pure(i)), equality: equality, qc: qc);
}

void checkFoldableMonadLaws(Foldable F, Monad M, {bool equality(a, b): defaultEquality, QuickCheck qc: null}) {
  qc = qc != null ? qc : defaultQC;

  group("foldable+monad laws", () {
    test("pure+concatenate identity", () {
      qc.check(forall(c.ints, (a) => equality(F.concatenate(NumSumMi, M.pure(a)), a)));
    });
  });

}

void checkSemigroupLaws(Semigroup Si, Enumeration enumeration, {bool equality(a, b): defaultEquality, QuickCheck qc: null}) {
  qc = qc != null ? qc : defaultQC;

  group("semigroup laws", () {
    test("associativity", () {
      qc.check(forall3(enumeration, enumeration, enumeration, (f1, f2, f3) => equality(Si.append(f1, Si.append(f2, f3)), Si.append(Si.append(f1, f2), f3))));
    });
  });

}


void checkMonoidLaws(Monoid Mi, Enumeration enumeration, {bool equality(a, b): defaultEquality, QuickCheck qc: null}) {
  qc = qc != null ? qc : defaultQC;

  group("monoid laws", () {
    test("left identity", () {
      qc.check(forall(enumeration, (a) => equality(a, Mi.append(Mi.zero(), a))));
    });

    test("right identity", () {
      qc.check(forall(enumeration, (a) => equality(a, Mi.append(a, Mi.zero()))));
    });
  });

  checkSemigroupLaws(Mi, enumeration, equality:equality, qc:qc);
}
