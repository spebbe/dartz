// ignore_for_file: unnecessary_new

part of dartz;

abstract class Applicative<F> implements Functor<F> {
  F pure<A>(A a);
  F ap<A, B>(covariant F fa, covariant F ff);

  F get nothing => pure(unit);

  @override F map<A, B>(covariant F fa, B f(A a)) => ap(fa, pure(f));
/*
  F traverseA(Traversable g, ga, F f(_)) => g.traverse(this, ga, f);

  F traverseA_(Traversable g, ga, F f(_)) => g.traverse_(this, ga, f);

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
*/
  // Workaround: Dumbing down types in generic liftX to give subclasses a chance to do proper typing...
  //             OMG, it just got worse... not much left of the types since 2.0.0-dev.32.0 :-(

  Function lift<A, B>(B f(A a)) => cast((F fa) => map(fa, f));
  Function lift2<A, B, C>(C f(A a, B b)) => (F fa, F fb) => ap(fb, map(fa, curry2(f)));
  Function lift3<A, B, C, D>(D f(A a, B b, C c)) => (F fa, F fb, F fc) => ap(fc, ap(fb, map(fa, curry3(f))));
  Function lift4<A, B, C, D, E>(E f(A a, B b, C c, D d)) => (F fa, F fb, F fc, F fd) => ap(fd, ap(fc, ap(fb, map(fa, curry4(f)))));
  Function lift5<A, B, C, D, E, F2>(F2 f(A a, B b, C c, D d, E e)) => (F fa, F fb, F fc, F fd, F fe) => ap(fe, ap(fd, ap(fc, ap(fb, map(fa, curry5(f))))));
  Function lift6<A, B, C, D, E, F2, G>(G f(A a, B b, C c, D d, E e, F2 f)) => (F fa, F fb, F fc, F fd, F fe, F ff) => ap(ff, ap(fe, ap(fd, ap(fc, ap(fb, map(fa, curry6(f)))))));

  F map2<A, A2 extends A, B, B2 extends B, C>(covariant F fa, covariant F fb, C f(A a, B b)) => cast(lift2(f)(fa, fb));
  F map3<A, A2 extends A, B, B2 extends B, C, C2 extends C, D>(covariant F fa, covariant F fb, covariant F fc, D f(A a, B b, C c)) => cast(lift3(f)(fa, fb, fc));
  F map4<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E>(covariant F fa, covariant F fb, covariant F fc, covariant F fd, E f(A a, B b, C c, D d)) => cast(lift4(f)(fa, fb, fc, fd));
  F map5<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, EFF>(covariant F fa, covariant F fb, covariant F fc, covariant F fd, covariant F fe, EFF f(A a, B b, C c, D d, E e)) => cast(lift5(f)(fa, fb, fc, fd, fe));
  F map6<A, A2 extends A, B, B2 extends B, C, C2 extends C, D, D2 extends D, E, E2 extends E, EFF, EFF2 extends EFF, G>(covariant F fa, covariant F fb, covariant F fc, covariant F fd, covariant F fe, covariant F ff, G f(A a, B b, C c, D d, E e, EFF fff)) => cast(lift6(f)(fa, fb, fc, fd, fe, ff));

  Applicative<F> /** Applicative<F<G<_>>> **/ composeA(Applicative G) => new ComposedApplicative(this, G);
}

// Compose Applicative<F<_>> with Applicative<G<_>>, yielding Applicative<F<G<_>>>
class ComposedApplicative<F, G> extends Functor<F> with Applicative<F> {
  final Applicative<F> _F;
  final Applicative<G> _G;

  ComposedApplicative(this._F, this._G);

  @override F pure<A>(A a) => _F.pure(_G.pure(a));

  @override F ap<A, B>(F fga, F fgf) => _F.map2(fga, fgf, _G.ap);

  @override F map<A, B>(F fga, B f(A _)) => _F.map(fga, (G ga) => _G.map(ga, f));
}

abstract class ApplicativeOps<F, A> implements FunctorOps<F, A> {
//  F pure<B>(B b);
  F ap<B>(covariant F ff);

  @override F map<B>(B f(A a));// => ap(pure(f));
}
