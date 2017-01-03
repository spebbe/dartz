part of dartz;

class FreeOps<F, O> {
  final FreeComposer<F, O> composer;
  FreeOps(this.composer);

  Free<F, dynamic/*=A*/> liftOp/*<A>*/(O o) => composer.lift(o);
}

abstract class FreeComposer<F, C> {
  Free<F, dynamic/*=A*/> lift/*<A>*/(C c) => liftF(embed(c));
  F embed(C c);
}

class IdFreeComposer<F> extends FreeComposer<F, F> {
  @override F embed(F f) => f;
}

class LeftFreeComposer<LL, L, R> extends FreeComposer<Either<L, R>, LL> {
  final FreeComposer<L, LL> _subComposer;
  LeftFreeComposer(this._subComposer);
  @override Either<L, R> embed(LL l) => left(_subComposer.embed(l));
}

class RightFreeComposer<RR, L, R> extends FreeComposer<Either<L, R>, RR> {
  final FreeComposer<R, RR> _subComposer;
  RightFreeComposer(this._subComposer);
  @override Either<L, R> embed(RR r) => right(_subComposer.embed(r));
}

Function1<Either/*<L, R>*/, dynamic> composeInterpreters/*<L, R>*/(lInterpreter(/*=L*/ l), rInterpreter(/*=R*/ r)) => (Either/*<L, R>*/ op) => op.fold(lInterpreter, rInterpreter);

class Free2<First, Second> {
  final FreeComposer<Either<First, Second>, First> firstComposer = new LeftFreeComposer(new IdFreeComposer());
  final FreeComposer<Either<First, Second>, Second> secondComposer = new RightFreeComposer(new IdFreeComposer());

  Free<Either<First, Second>, dynamic/*=A*/> liftFirst/*<A>*/(Free<First, dynamic/*=A*/> first) => first.foldMap(FreeM, firstComposer.lift);
  Free<Either<First, Second>, dynamic/*=A*/> liftSecond/*<A>*/(Free<Second, dynamic/*=A*/> second) => second.foldMap(FreeM, secondComposer.lift);

  Function1/*<Free<Either<First, Second>, dynamic>, F>*/ interpreter/*<F>*/(Monad/*<F>*/ M, /*=F*/ firstInterpreter(First first), /*=F*/ secondInterpreter(Second second)) {
    final interpreter = composeInterpreters(firstInterpreter, secondInterpreter);
    return (fa) => fa.foldMap(M, interpreter);
  }
}

class Free3<First, Second, Third> {
  final FreeComposer<Either<Either<First, Second>, Third>, First> firstComposer = new LeftFreeComposer(new LeftFreeComposer(new IdFreeComposer()));
  final FreeComposer<Either<Either<First, Second>, Third>, Second> secondComposer = new LeftFreeComposer(new RightFreeComposer(new IdFreeComposer()));
  final FreeComposer<Either<Either<First, Second>, Third>, Third> thirdComposer = new RightFreeComposer(new IdFreeComposer());

  Free<Either<Either<First, Second>, Third>, dynamic/*=A*/> liftFirst/*<A>*/(Free<First, dynamic/*=A*/> first) => first.foldMap(FreeM, firstComposer.lift);
  Free<Either<Either<First, Second>, Third>, dynamic/*=A*/> liftSecond/*<A>*/(Free<Second, dynamic/*=A*/> second) => second.foldMap(FreeM, secondComposer.lift);
  Free<Either<Either<First, Second>, Third>, dynamic/*=A*/> liftThird/*<A>*/(Free<Third, dynamic/*=A*/> third) => third.foldMap(FreeM, thirdComposer.lift);

  Function1/*<Free<Either<Either<First, Second>, Third>, dynamic>, F>*/ interpreter/*<F>*/(Monad/*<F>*/ M, firstInterpreter(First op), secondInterpreter(Second op), thirdInterpreter(Third op)) {
    final interpreter = composeInterpreters(composeInterpreters(firstInterpreter, secondInterpreter), thirdInterpreter);
    return (fa) => fa.foldMap(M, interpreter);
  }
}
