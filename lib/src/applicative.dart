part of dartz;

abstract class Applicative<F> implements Functor<F> {
  F pure<A>(A a);
  F ap<A, B>(covariant F fa, covariant F ff);

  F get nothing => pure(unit);

  @override F map<A, B>(covariant F fa, B f(A a)) => ap(fa, pure(f));

  F traverseA(Traversable g, ga, F f(_)) => g.traverse<F>(this, ga, f);

  F traverseA_(Traversable g, ga, F f(_)) => g.traverse_<F>(this, ga, f);

  F sequenceA(Traversable g, ga) => g.sequence(this, ga);

  F sequenceA_(Traversable g, ga) => g.sequence_(this, ga);

  F traverseL(IList<F> fas, F f(_)) => traverseA(IListTr, fas, f);

  F traverseL_(IList<F> fas, F f(_)) => traverseA_(IListTr, fas, f);

  F sequenceL(IList<F> fas) => sequenceA(IListTr, fas);

  F sequenceL_(IList<F> fas) => sequenceA_(IListTr, fas);

  F unsafeTraverseL(List fas, F f(_)) => traverseA(ListTr, fas, f);

  F unsafeTraverseL_(List<F> fas, F f(_)) => traverseA_(ListTr, fas, f);

  F unsafeSequenceL(List<F> fas) =>  sequenceA(ListTr, fas);

  F unsafeSequenceL_(List<F> fas) =>  sequenceA_(ListTr, fas);

  F replicate<A>(int n, covariant F fa) => sequenceL(new IList.from(new List.filled(n, fa)));

  F replicate_(int n, F fa) => sequenceL_(new IList.from(new List.filled(n, fa)));

  // Workaround: Seriously messed up tricks in liftX and mapX to confuse the 1.22 VM enough not to crash but still type in a somewhat useful way...

  Function1<F2, F2> lift<F2 extends F>(f(a)) => (F2 fa) => cast(map(fa, f));
  Function2<F2, F2, F2> lift2<F2 extends F>(f(a, b)) => cast((F2 fa, F2 fb) => ap(fb, map(fa, curry2(f))));
  Function3<F2, F2, F2, F2> lift3<F2 extends F>(f(a, b, c)) => cast((F2 fa, F2 fb, F2 fc) => ap(fc, ap(fb, map(fa, curry3(f)))));
  Function4<F2, F2, F2, F2, F2> lift4<F2 extends F>(f(a, b, c, d)) => (F2 fa, F2 fb, F2 fc, F2 fd) => cast(ap(fd, ap(fc, ap(fb, map(fa, curry4(f))))));
  Function5<F2, F2, F2, F2, F2, F2> lift5<F2 extends F>(f(a, b, c, d, e)) => (F2 fa, F2 fb, F2 fc, F2 fd, F2 fe) => cast(ap(fe, ap(fd, ap(fc, ap(fb, map(fa, curry5(f)))))));
  Function6<F2, F2, F2, F2, F2, F2, F2> lift6<F2 extends F>(f(a, b, c, d, e, f)) => (F2 fa, F2 fb, F2 fc, F2 fd, F2 fe, F2 ff) => cast(ap(ff, ap(fe, ap(fd, ap(fc, ap(fb, map(fa, curry6(f))))))));

  F map2<A, A2 extends A, B, B2 extends B, C>(covariant F fa, covariant F fb, C f(A a, B b)) => lift2(f)(fa, fb);
  F map3<A, A2 extends A, B, B2 extends B, C, C2 extends C, D>(covariant F fa, covariant F fb, covariant F fc, D f(A a, B b, C c)) => lift3(f)(fa, fb, fc);
  F map4<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E>(covariant F fa, covariant F fb, covariant F fc, covariant F fd, E f(A a, B b, C c, D d)) => lift4(f)(fa, fb, fc, fd);
  F map5<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, EFF>(covariant F fa, covariant F fb, covariant F fc, covariant F fd, covariant F fe, EFF f(A a, B b, C c, D d, E e)) => lift5(f)(fa, fb, fc, fd, fe);
  F map6<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, EFF, EFF2 extends EFF, G>(covariant F fa, covariant F fb, covariant F fc, covariant F fd, covariant F fe, covariant F ff, G f(A a, B b, C c, D d, E e, EFF fff)) => lift6(f)(fa, fb, fc, fd, fe, ff);

  Applicative<F> /** Applicative<F<G<_>>> **/ composeA(Applicative G) => new ComposedApplicative(this, G);
}

// Compose Applicative<F<_>> with Applicative<G<_>>, yielding Applicative<F<G<_>>>
class ComposedApplicative<F, G> extends Functor<F> with Applicative<F> {
  final Applicative<F> _F;
  final Applicative<G> _G;

  ComposedApplicative(this._F, this._G);

  @override F pure<A>(A a) => _F.pure(_G.pure(a));

  @override F ap<A, B>(F fga, F fgf) => _F.map2(fga, fgf, _G.ap);

  @override F map<A, B>(F fga, B f(_)) => _F.map(fga, (G ga) => _G.map(ga, f));
}

abstract class ApplicativeOps<F, A> implements FunctorOps<F, A> {
  F pure<B>(B b);
  F ap<B>(F ff);

  @override F map<B>(B f(A a)) => ap(pure(f));
}
