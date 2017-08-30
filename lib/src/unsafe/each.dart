part of dartz_unsafe;

void forEach<A>(FoldableOps<dynamic, A> foldable, void sideEffect(A a)) =>
    foldable.foldLeft(null, (_, a) => sideEffect(a));
