part of dartz;

// TODO: Monoids over floating point types tend to be law breakers... use with care!

class NumSumMonoid extends Monoid<num> {
  @override num zero() => 0;
  @override num append(num n1, num n2) => n1+n2;
}

final Monoid<num> NumSumMi = new NumSumMonoid();

class IntSumMonoid extends Monoid<int> {
  @override int zero() => 0;
  @override int append(int n1, int n2) => n1+n2;
}

final Monoid<int> IntSumMi = new IntSumMonoid();


class NumProductMonoid extends Monoid<num> {
  @override num zero() => 1;
  @override num append(num n1, num n2) => n1*n2;
}

final Monoid<num> NumProductMi = new NumProductMonoid();

class NumMaxSemigroup extends Semigroup<num> {
  @override num append(num n1, num n2) => n1 > n2 ? n1 : n2;
}

final Semigroup<num> NumMaxSi = new NumMaxSemigroup();

class NumMinSemigroup extends Semigroup<num> {
  @override num append(num n1, num n2) => n1 < n2 ? n1 : n2;
}

final Semigroup<num> NumMinSi = new NumMinSemigroup();

class StringMonoid extends Monoid<String> {
  @override String zero() => "";
  @override String append(String s1, String s2) => s1 + s2;
}

final Monoid<String> StringMi = new StringMonoid();

class BooleanDisjunctionMonoid extends Monoid<bool> {
  @override bool zero() => false;
  @override bool append(bool b1, bool b2) => b1 || b2;
}

final Monoid<bool> BoolOrMi = new BooleanDisjunctionMonoid();

class BooleanConjunctionMonoid extends Monoid<bool> {
  @override bool zero() => true;
  @override bool append(bool b1, bool b2) => b1 && b2;
}

final Monoid<bool> BoolAndMi = new BooleanConjunctionMonoid();

final Order<num> NumOrder = new ComparableOrder<num>();

class _IntOrder extends Order<int> {
  @override  Ordering order(int i1, int i2) => i1 < i2 ? Ordering.LT : (i1 > i2 ? Ordering.GT : Ordering.EQ);
}

final Order<int> IntOrder = new _IntOrder();

final Order<double> DoubleOrder = new ComparableOrder<double>();

final Order<String> StringOrder = new ComparableOrder<String>();

A cast<A>(dynamic a) => a as A;
