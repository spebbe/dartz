part of dartz;

class Task<A> extends FunctorOps<Task, A> with ApplicativeOps<Task, A>, MonadOps<Task, A>, MonadCatchOps<Task, A> {
  final Function0<Future<A>> _run;

  Task(this._run);

  static Task<A> delay<A>(Function0<A> f) => new Task(() => new Future(f));

  Future<A> run() => _run();

  @override Task<B> bind<B>(Task<B> f(A a)) => new Task(() => _run().then((a) => f(a).run()));

  @override Task<B> pure<B>(B b) => new Task(() => new Future.value(b));

  @override Task<Either<Object, A>> attempt() => new Task(() => run().then(right).catchError(left));

  @override Task<A> fail(Object err) => new Task(() => new Future.error(err));
}

class TaskMonadCatch extends Functor<Task> with Applicative<Task>, Monad<Task>, MonadCatch<Task> {

  @override Task<Either<Object, A>> attempt<A>(Task<A> fa) => fa.attempt();

  @override Task<B> bind<A, B>(Task<A> fa, Task<B> f(A a)) => fa.bind(f);

  @override Task<A> fail<A>(Object err) => new Task(() => new Future.error(err));

  @override Task<A> pure<A>(A a) => new Task(() => new Future.value(a));
}

final MonadCatch<Task> TaskMC = new TaskMonadCatch();
MonadCatch<Task<A>> taskMC<A>() => cast(TaskMC);
