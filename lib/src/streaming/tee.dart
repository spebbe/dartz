part of dartz_streaming;

class Both<L, R> {}

class Tee {
  static final Both _getL = new Both();
  static final Both _getR = new Both();

  static Conveyor<Both/*<L, R>*/, dynamic/*=O*/> produce/*<L, R, O>*/(/*=O*/ h, [Conveyor<Both/*<L, R>*/, dynamic/*=O*/> t]) => Conveyor.produce(h, t);

  static Conveyor<Both/*<L, R>*/, dynamic/*=O*/> consumeL/*<L, R, O>*/(Function1/*<L, Conveyor<Both<L, R>, O>>*/ recv, [Function0/*<Conveyor<Both<L, R>, O>>*/ fallback]) =>
      Conveyor.consume/*<Both<L, R>, L, O>*/(_getL as dynamic/*=Both<L, R>*/, (ea) => ea.fold(
          (err) => err == Conveyor.End ? (fallback == null ? halt() : fallback()) : Conveyor.halt(err)
      ,(/*=L*/ l) => Conveyor.Try(() => recv(l))));

  static Conveyor<Both/*<L, R>*/, dynamic/*=O*/> consumeR/*<L, R, O>*/(Function1/*<R, Conveyor<Both<L, R>, O>>*/ recv, [Function0/*<Conveyor<Both<L, R>, O>>*/ fallback]) =>
      Conveyor.consume/*<Both<L, R>, R, O>*/(_getR as dynamic/*=Both<L, R>*/, (ea) => ea.fold(
          (err) => err == Conveyor.End ? (fallback == null ? halt() : fallback()) : Conveyor.halt(err)
      ,(/*=R*/ r) => Conveyor.Try(() => recv(r))));

  static Conveyor<Both/*<L, R>*/, dynamic/*=O*/> halt/*<L, R, O>*/() => Conveyor.halt(Conveyor.End);

  static Conveyor<Both/*<L, R>*/, dynamic/*=O*/> zipWith/*<L, R, O>*/(Function2/*<L, R, O>*/ f) =>
      consumeL/*<L, R, O>*/((/*=L*/ l) => consumeR((/*=R*/ r) => produce(f(l, r)))).repeatUntilExhausted();

  static Conveyor<Both/*<L, R>*/, Tuple2/*<L, R>*/> zip/*<L, R>*/() => zipWith(tuple2);

  static Conveyor<Both/*<I, I>*/, dynamic/*=I*/> interleave/*<I>*/() =>
      consumeL/*<I, I, I>*/((/*=I*/ i1) => consumeR((/*=I*/ i2) => produce(i1, produce(i2)))).repeatUntilExhausted();

}
