part of dartz;

Function curry2(f(a, b)) => (a) => (b) => f(a, b);

Function curry3(f(a, b, c)) => (a) => (b) => (c) => f(a, b, c);

Function curry4(f(a, b, c, d)) => (a) => (b) => (c) => (d) => f(a, b, c, d);

Function curry5(f(a, b, c, d, e)) => (a) => (b) => (c) => (d) => (e) => f(a, b, c, d, e);

Function curry6(fun(a, b, c, d, e, f)) => (a) => (b) => (c) => (d) => (e) => (f) => fun(a, b, c, d, e, f);

Function uncurry2(f(_)) => (a, b) => f(a)(b);

Function uncurry3(f(_)) => (a, b, c) => f(a)(b)(c);

Function uncurry4(f(_)) => (a, b, c, d) => f(a)(b)(c)(d);

Function uncurry5(f(_)) => (a, b, c, d, e) => f(a)(b)(c)(d)(e);

Function uncurry6(fun(_)) => (a, b, c, d, e, f) => fun(a)(b)(c)(d)(e)(f);

Function tuplize2(f(a, b)) => (Tuple2 t2) => f(t2.value1, t2.value2);

Function tuplize3(f(a, b, c)) => (Tuple3 t3) => f(t3.value1, t3.value2, t3.value3);

Function tuplize4(f(a, b, c, d)) => (Tuple4 t4) => f(t4.value1, t4.value2, t4.value3, t4.value4);

Function flip(f(a, b)) => (b, a) => f(a, b);

Function composeF(f(b), g(a)) => (a) => f(g(a));

Function constF(b) => (a) => b;

typedef Thunk();
