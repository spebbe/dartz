// ignore_for_file: unnecessary_new

part of dartz;

class Task<A> implements MonadCatchOps<Task, A> {
  final Function0<Future<A>> _run;

  Task(this._run);

  static Task<A> delay<A>(Function0<A> f) => new Task(() => new Future.microtask(f));

  static Task<A> failed<A>(Object err) => new Task(() => new Future.error(err));

  static Task<void> sleep(Duration duration) => Task(() => Future.delayed(duration));

  static Task<void> print(String s) => Task.delay(() => _consolePrint(s));

  static Task<void> get unit => Task.value(null);

  static Task<A> value<A>(A a) => new Task(() => new Future.value(a));

  Future<A> run() => _run();

  @override Task<B> bind<B>(Function1<A, Task<B>> f) => new Task(() => _run().then((a) => f(a).run()));

  Task<B> pure<B>(B b) => new Task(() => new Future.value(b));

  @override Task<Either<Object, A>> attempt() => new Task(() => run().then((a) => right<Object, A>(a)).catchError((err) => left<Object, A>(cast(err))));

  @override Task<A> fail(Object err) => new Task(() => new Future.error(err));

  @override Task<B> map<B>(B f(A a)) => new Task(() => _run().then(f));

  @override Task<Tuple2<B, A>> strengthL<B>(B b) => map((a) => tuple2(b, a));

  @override Task<Tuple2<A, B>> strengthR<B>(B b) => map((a) => tuple2(a, b));

  @override Task<B> andThen<B>(Task<B> next) => bind((_) => next);

  @override Task<B> ap<B>(Task<Function1<A, B>> ff) => ff.bind(map); // TODO: optimize

  @override Task<B> flatMap<B>(Function1<A, Task<B>> f) => new Task(() => _run().then((a) => f(a).run()));

  @override Task<B> replace<B>(B replacement) => map((_) => replacement);

  Task<Tuple2<A, B>> both<B>(Task<B> that) => Task(() =>
    Future.wait([_run(), that._run()])
      .then((value) => tuple2(cast(value[0]), cast(value[1])))
  );

  Task<B> bracket<B>(Function1<A,Task<B>> use, Function1<A, Task<void>> release) => flatMap((a) => use(a).guarantee(release(a)));

  Task<A> delayBy(Duration duration) => sleep(duration).productR(this);

  Task<A> flatTap<B>(Task<B> that) => productL(that);

  Task<A> guarantee(Task<void> finalizer) => Task(() => _run().whenComplete(() => finalizer._run()));

  Task<A> handleError(Function1<Object, A> f) => attempt().map((a) => a.fold(f, id));

  Task<A> handleErrorWith(Function1<Object, Task<A>> f) => attempt().flatMap((a) => a.fold(f, Task.value));

  Task<Option<A>> get option => redeem((_) => none(), (a) => some(a));

  Task<Tuple2<A, B>> product<B>(Task<B> that) => flatMap((a) => that.map((b) => tuple2(a, b)));

  Task<A> productL<B>(Task<B> that) => flatMap((a) => that.replace(a));

  Task<B> productR<B>(Task<B> that) => andThen(that);

  Task<Either<A, B>> race<B>(Task<B> that) => Task(() async {
    final f = await Future.any([
      _run().then((value) => tuple2(0, value)),
      that._run().then((value) => tuple2(1, value)),
    ]);

    if(f is Tuple2<int, A> && f.value1 == 0) {
      return left(cast(f.value2));
    } 
    else if(f is Tuple2<int, B> && f.value1 == 1) {
      return right(cast(f.value2));
    } else {
      throw TypeError();
    }
  });

  Task<B> redeem<B>(Function1<Object, B> recover, Function1<A, B> map) => attempt().map((a) => a.fold(recover, map));

  Task<B> redeemWith<B>(Function1<Object, Task<B>> recover, Function1<A, Task<B>> bind) => attempt().flatMap((a) => a.fold(recover, bind));

  Task<IList<A>> replicate(int n) => IList.sequenceTask(IList.generate(n, (_) => this));

  Task<Tuple2<Duration, A>> get timed => Task(() {
    final sw = Stopwatch()..start();
    return _run().then((a) => tuple2(sw.elapsed, a));
  });

  Task<A> timeout(Duration timeLimit) => Task(() => _run().timeout(timeLimit));

  Task<A> timeoutTo(Duration timeLimit, Task<A> fallback) => timeout(timeLimit).redeemWith((err) => err is TimeoutException ? fallback : Task.failed(err), Task.value);

  Task<void> get voided => replace(null);
}

class TaskMonadCatch extends Functor<Task> with Applicative<Task>, Monad<Task>, MonadCatch<Task> {

  @override Task<Either<Object, A>> attempt<A>(covariant Task<A> fa) => fa.attempt();

  @override Task<B> bind<A, B>(covariant Task<A> fa, covariant Function1<A,  Task<B>> f) => fa.bind(f);

  @override Task<A> fail<A>(Object err) => new Task(() => new Future.error(err));

  @override Task<A> pure<A>(A a) => new Task(() => new Future.microtask(() => a));
}

final MonadCatch<Task> TaskMC = new TaskMonadCatch();
MonadCatch<Task<A>> taskMC<A>() => cast(TaskMC);

extension TaskFlattenOps<A> on Task<Task<A>> {
  Task<A> get flatten => flatMap(id);
}

extension TaskBoolOps on Task<bool> {
  Task<B> ifM<B>(Task<B> ifTrue, Task<B> ifFalse) => flatMap((pred) => pred ? ifTrue : ifFalse);
}

Function _consolePrint = print;