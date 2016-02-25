part of dartz;

abstract class Applicative<F> extends Functor<F> {
  F pure(a);
  F ap(F fa, F ff);

  F get nothing => pure(unit);

  @override F map(F fa, f(_)) => ap(fa, pure(f));

  F traverseA(Traversable g, ga, f(_)) => g.traverse(this, ga, f);

  F traverseA_(Traversable g, ga, f(_)) => g.traverse_(this, ga, f);

  F sequenceA(Traversable g, ga) => g.sequence(this, ga);

  F sequenceA_(Traversable g, ga) => g.sequence_(this, ga);

  F traverseL(IList<F> fas, f(_)) => traverseA(IListTr, fas, f);

  F traverseL_(IList<F> fas, f(_)) => traverseA_(IListTr, fas, f);

  F sequenceL(IList<F> fas) => sequenceA(IListTr, fas);

  F sequenceL_(IList<F> fas) => sequenceA_(IListTr, fas);

  F unsafeTraverseL(List fas, f(_)) => traverseA(ListTr, fas, f);

  F unsafeTraverseL_(List<F> fas, f(_)) => traverseA_(ListTr, fas, f);

  F unsafeSequenceL(List<F> fas) =>  sequenceA(ListTr, fas);

  F unsafeSequenceL_(List<F> fas) =>  sequenceA_(ListTr, fas);

  F replicate(int n, F fa) => sequenceL(new IList.from(new List.filled(n, fa)));

  F replicate_(int n, F fa) => sequenceL_(new IList.from(new List.filled(n, fa)));

  lift(f(a)) => (fa) => map(fa, f);
  lift2(f(a, b)) => (F fa, F fb) => ap(fb, map(fa, curry2(f)));
  lift3(f(a, b, c)) => (F fa, F fb, F fc) => ap(fc, ap(fb, map(fa, curry3(f))));
  lift4(f(a, b, c, d)) => (F fa, F fb, F fc, F fd) => ap(fd, ap(fc, ap(fb, map(fa, curry4(f)))));
  lift5(f(a, b, c, d, e)) => (F fa, F fb, F fc, F fd, F fe) => ap(fe, ap(fd, ap(fc, ap(fb, map(fa, curry5(f))))));
  lift6(f(a, b, c, d, e, f)) => (F fa, F fb, F fc, F fd, F fe, F ff) => ap(ff, ap(fe, ap(fd, ap(fc, ap(fb, map(fa, curry6(f)))))));

  F map2(F fa, F fb, f(a, b)) => lift2(f)(fa, fb);
  F map3(F fa, F fb, F fc, f(a, b, c)) => lift3(f)(fa, fb, fc);
  F map4(F fa, F fb, F fc, F fd, f(a, b, c, d)) => lift4(f)(fa, fb, fc, fd);
  F map5(F fa, F fb, F fc, F fd, F fe, f(a, b, c, d, e)) => lift5(f)(fa, fb, fc, fd, fe);
  F map6(F fa, F fb, F fc, F fd, F fe, F ff, f(a, b, c, d, e, fff)) => lift6(f)(fa, fb, fc, fd, fe, ff);

  Applicative<F> /* Applicative<F<G<_>>> */ composeA(Applicative G) => new ComposedApplicative(this, G);
}

// Compose Applicative<F<_>> with Applicative<G<_>>, yielding Applicative<F<G<_>>>
class ComposedApplicative<F, G> extends Applicative<F> {
  final Applicative<F> _F;
  final Applicative<G> _G;

  ComposedApplicative(this._F, this._G);

  @override F pure(a) => _F.pure(_G.pure(a));

  @override F ap(F fga, F fgf) => _F.map2(fga, fgf, _G.ap);

  @override F map(F fga, f(_)) => _F.map(fga, (G ga) => _G.map(ga, f));
}

abstract class ApplicativeOps<F, A> extends FunctorOps<F, A> {
  F pure(a);
  F ap(F ff);

  @override F map(f(A a)) => ap(pure(f));
}
