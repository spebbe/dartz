dartz
-----

Functional programming in Dart

* Type class hierarchy in the spirit of [scalaz](https://github.com/scalaz/scalaz) and [the standard Haskell libraries](https://wiki.haskell.org/Typeclassopedia)
* Immutable, persistent collections, including IVector, IList, IMap and ISet
* Option, Either, State, Tuple, Free and other tools for programming in a functional style
* Evaluation, a crazy useful Reader+Writer+State+Either+Future monad
* Type class instances (Monoids, Traversable Functors, Monads and so on) for included types, as well as for several standard Dart types

##### Status

* Super experimental!
* Somewhat exotic structure/API, since dartz is trying to jam type classes for higher kinded types into a language that lacks support for real type classes and higher kinded types... At least we have basic [parametric polymorphism for functions/methods](https://github.com/dart-lang/dev_compiler/blob/master/doc/GENERIC_METHODS.md) now!!!
* Most things are stack safe and reasonably efficent, but there are a couple of exceptions and plenty of room for further optimizations
* Lacks documentation and examples

##### License/Disclaimer

See [LICENSE](https://github.com/spebbe/dartz/blob/master/LICENSE)
