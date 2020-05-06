// ignore_for_file: unnecessary_new

part of dartz;

class Task<A> implements MonadCatchOps<Task, A> {
  final Function0<Future<A>> _run;

  Task(this._run);

  static Task<A> delay<A>(Function0<A> f) => new Task(() => new Future.microtask(f));

  Future<A> run() => _run();

  @override Task<B> bind<B>(Function1<A, Task<B>> f) => new Task(() => _run().then((a) => f(a).run()));

  Task<B> pure<B>(B b) => new Task(() => new Future.value(b));

  @override Task<Either<Object, A>> attempt() => new Task(() => run().then(right).catchError((err) => left<Object, A>(err)));

  @override Task<A> fail(Object err) => new Task(() => new Future.error(err));

  @override Task<B> map<B>(B f(A a)) => new Task(() => _run().then(f));

  @override Task<Tuple2<B, A>> strengthL<B>(B b) => map((a) => tuple2(b, a));

  @override Task<Tuple2<A, B>> strengthR<B>(B b) => map((a) => tuple2(a, b));

  @override Task<B> andThen<B>(Task<B> next) => bind((_) => next);

  @override Task<B> ap<B>(Task<Function1<A, B>> ff) => ff.bind(map); // TODO: optimize

  @override Task<B> flatMap<B>(Function1<A, Task<B>> f) => new Task(() => _run().then((a) => f(a).run()));

  @override Task<B> replace<B>(B replacement) => map((_) => replacement);
}

class TaskMonadCatch extends Functor<Task> with Applicative<Task>, Monad<Task>, MonadCatch<Task> {

  @override Task<Either<Object, A>> attempt<A>(covariant Task<A> fa) => fa.attempt();

  @override Task<B> bind<A, B>(covariant Task<A> fa, covariant Function1<A,  Task<B>> f) => fa.bind(f);

  @override Task<A> fail<A>(Object err) => new Task(() => new Future.error(err));

  @override Task<A> pure<A>(A a) => new Task(() => new Future.microtask(() => a));
}

final MonadCatch<Task> TaskMC = new TaskMonadCatch();
MonadCatch<Task<A>> taskMC<A>() => cast(TaskMC);
