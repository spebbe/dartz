part of dartz_streaming;

class Nowhere {}

class Source {
  static Conveyor/*<F, A>*/ eval/*<F, A>*/(/*=F*/ fa) =>
      Conveyor.consume(fa, (ea) => ea.fold(Conveyor.halt, Conveyor.produce));

  static Conveyor/*<F, A>*/ repeatEval/*<F, A>*/(/*=F*/ fa) {
    final Conveyor/*<F, A>*/ convinceTypeSystem = eval(fa);
    return convinceTypeSystem.repeat();
  }

  static Conveyor/*<F, A>*/ eval_/*<F, A>*/(/*=F*/ fa) =>
      Conveyor.consume(fa, (ea) => ea.fold(Conveyor.halt, (_) => Conveyor.halt(Conveyor.End)));

  static Conveyor/*<F, A>*/ repeatEval_/*<F, A>*/(/*=F*/ fa) {
    final Conveyor/*<F, A>*/ convinceTypeSystem = eval_(fa);
    return convinceTypeSystem.repeat();
  }

  static Conveyor/*<F, O>*/ resource/*<F, R, O>*/(/*=F*/ acquire, Conveyor<dynamic/*=F*/, dynamic/*=O*/> use(/*=R*/ r), Conveyor<dynamic/*=F*/, dynamic/*=O*/> release(/*=R*/ r)) =>
      eval/*<F, R>*/(acquire).bind((r) => use(r).onComplete(() => release(r)));

  static Conveyor<Nowhere, dynamic/*=O*/> fromFoldable/*<F, O>*/(/*=F*/ fo, Foldable/*<F>*/ foldable) => foldable.collapse(conveyorMP(), fo);

  static dynamic/*=F*/ materialize/*<F, O>*/(Conveyor<Nowhere, dynamic/*=O*/> s, ApplicativePlus/*<F>*/ ap) =>
      s.interpret((h, t) => ap.prependElement(materialize/*<F, O>*/(t, ap), h),
          (req, recv) => materialize/*<F, O>*/(recv(left(Conveyor.End)), ap),
          (err) => err == Conveyor.End ? ap.empty() : throw err);

  static Conveyor<Nowhere, dynamic/*=O*/> fromIVector/*<F, O>*/(/*=IVector<O>*/ v) => fromFoldable(v, IVectorTr);
  static IVector/*<O>*/ toIVector/*<O>*/(Conveyor<Nowhere, dynamic/*=O*/> s) => materialize/*<IVector, O>*/(s, IVectorMP) as dynamic/*=IVector<O>*/;

  static Conveyor<Nowhere, dynamic/*=O*/> fromIList/*<F, O>*/(/*=IList<O>*/ v) => fromFoldable(v, IListTr);
  static IList/*<O>*/ toIList/*<O>*/(Conveyor<Nowhere, dynamic/*=O*/> s) => materialize/*<IList, O>*/(s, IListMP) as dynamic/*=IList<O>*/;

  static Conveyor<Task, dynamic/*=A*/> fromStream/*<A>*/(Stream/*<A>*/ s()) => Source.resource(Task.delay(() => new StreamIterator(s())),
      (StreamIterator/*<A>*/ it) => Source.eval/*<Task, bool>*/(new Task(it.moveNext)).repeat().takeWhile(id).flatMap((_) => Source.eval(Task.delay(() => it.current))),
      (StreamIterator/*<A>*/ it) => Source.eval_(new Task(() => new Future.value(unit).then((_) => it.cancel()))));

  static Conveyor/*<F, O>*/ pure/*<F, O>*/(Monad/*<F>*/ monad, /*=O*/ o) => eval/*<F, O>*/(monad.pure(o));

  static Conveyor/*<F, O>*/ constant/*<F, O>*/(Monad/*<F>*/ monad, /*=O*/ o) => pure(monad, o).repeat();

  static Conveyor/*<F, int>*/ intsFrom/*<F, O>*/(Monad/*<F>*/ monad, int from) => constant(monad, 1).pipe(Pipe.scan(from-1, (int a, int b) => a+b));
}