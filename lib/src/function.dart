part of dartz;

typedef A Function0<A>();
typedef B Function1<A, B>(A a);
typedef C Function2<A, B, C>(A a, B b);
typedef D Function3<A, B, C, D>(A a, B b, C c);
typedef E Function4<A, B, C, D, E>(A a, B b, C c, D d);
typedef F Function5<A, B, C, D, E, F>(A a, B b, C c, D d, E e);
typedef G Function6<A, B, C, D, E, F, G>(A a, B b, C c, D d, E e, F f);


Function1/*<A, Function1<B, C>>*/ curry2/*<A, B, C>*/(Function2/*<A, B, C>*/ fun) => (a) => (b) => fun(a, b);

Function1/*<A, Function1<B, Function1<C, D>>>*/ curry3/*<A, B, C, D>*/(Function3/*<A, B, C, D>*/ fun) => (a) => (b) => (c) => fun(a, b, c);

Function1/*<A, Function1<B, Function1<C, Function1<D, E>>>>*/ curry4/*<A, B, C, D, E>*/(Function4/*<A, B, C, D, E>*/ fun) => (a) => (b) => (c) => (d) => fun(a, b, c, d);

Function1/*<A, Function1<B, Function1<C, Function1<D, Function1<E, F>>>>>*/ curry5/*<A, B, C, D, E, F>*/(Function5/*<A, B, C, D, E, F>*/ fun) => (a) => (b) => (c) => (d) => (e) => fun(a, b, c, d, e);

Function1/*<A, Function1<B, Function1<C, Function1<D, Function1<E, Function1<F, G>>>>>>*/ curry6/*<A, B, C, D, E, F, G>*/(Function6/*<A, B, C, D, E, F, G>*/ fun) => (a) => (b) => (c) => (d) => (e) => (f) => fun(a, b, c, d, e, f);

Function2/*<A, B, C>*/ uncurry2/*<A, B, C>*/(Function1/*<A, Function1<B, C>>*/ fun) => (a, b) => fun(a)(b);

Function3/*<A, B, C, D>*/ uncurry3/*<A, B, C, D>*/(Function1/*<A, Function1<B, Function1<C, D>>>*/ fun) => (a, b, c) => fun(a)(b)(c);

Function4/*<A, B, C, D, E>*/ uncurry4/*<A, B, C, D, E>*/(Function1/*<A, Function1<B, Function1<C, Function1<D, E>>>>*/ fun) => (a, b, c, d) => fun(a)(b)(c)(d);

Function5/*<A, B, C, D, E, F>*/ uncurry5/*<A, B, C, D, E, F>*/(Function1/*<A, Function1<B, Function1<C, Function1<D, Function1<E, F>>>>>*/ fun) => (a, b, c, d, e) => fun(a)(b)(c)(d)(e);

Function6/*<A, B, C, D, E, F, G>*/ uncurry6/*<A, B, C, D, E, F, G>*/(Function1/*<A, Function1<B, Function1<C, Function1<D, Function1<E, Function1<F, G>>>>>>*/ fun) => (a, b, c, d, e, f) => fun(a)(b)(c)(d)(e)(f);

Function1/*<Tuple2<A, B>, C>*/ tuplize2/*<A, B, C>*/(Function2/*<A, B, C>*/ fun) => (Tuple2/*<A, B>*/ t2) => fun(t2.value1, t2.value2);

Function1/*<Tuple3<A, B, C>, D>*/ tuplize3/*<A, B, C, D>*/(Function3/*<A, B, C, D>*/ fun) => (Tuple3/*<A, B, C>*/ t3) => fun(t3.value1, t3.value2, t3.value3);

Function1/*<Tuple4<A, B, C, D>, E>*/ tuplize4/*<A, B, C, D, E>*/(Function4/*<A, B, C, D, E>*/ fun) => (Tuple4/*<A, B, C, D>*/ t4) => fun(t4.value1, t4.value2, t4.value3, t4.value4);

Function2/*<B, A, C>*/ flip/*<A, B, C>*/(Function2/*<A, B, C>*/ f) => (b, a) => f(a, b);

Function1/*<A, C>*/ composeF/*<A, B, C>*/(Function1/*<B, C>*/ f, Function1/*<A, B>*/ g) => (a) => f(g(a));

Function1/*<A, B>*/ constF/*<A, B>*/(/*=B*/ b) => (/*=A*/ a) => b;


class Function0TraversableMonad extends Traversable<Function0> with Applicative<Function0>, Monad<Function0>, TraversableMonad<Function0> {
  @override Function0 bind/*<A, B>*/(Function0/*<A>*/ fa, Function0/*<B>*/ f(/*=A*/ a)) => () => f(fa())();
  @override Function0 pure/*<A>*/(/*=A*/ a) => () => a;
  @override /*=G*/ traverse/*<G>*/(Applicative/*<G>*/ gApplicative, Function0 fa, /*=G*/ f(a)) => gApplicative.map(f(fa()), (b) => () => b);
}

final Function0TraversableMonad Function0TrM = new Function0TraversableMonad();
TraversableMonad<Function0/*<A>*/> function0TrM/*<A>*/() => Function0TrM as dynamic/*=TraversableMonad<Function0<A>>*/;
