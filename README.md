dartz
-----

Functional programming in Dart

* Type class hierarchy in the spirit of [cats](https://typelevel.org/cats/), [scalaz](https://github.com/scalaz/scalaz) and [the standard Haskell libraries](https://wiki.haskell.org/Typeclassopedia)
* Immutable, persistent collections, including IVector, IList, IMap, IHashMap, ISet and AVLTree
* Option, Either, State, Tuple, Free, Lens and other tools for programming in a functional style
* Evaluation, a Reader+Writer+State+Either+Future swiss army knife monad
* Type class instances (Monoids, Traversable Functors, Monads and so on) for included types, as well as for several standard Dart types
* Conveyor, an implementation of pure functional streaming (Dart 1 only, for now)
* [Examples](https://github.com/spebbe/dartz/tree/master/example), showcasing core concepts

##### New to functional programming?

A good place to start learning is the excellent [Functional Programming in Scala](https://www.manning.com/books/functional-programming-in-scala) by Paul Chiusano and Rúnar Bjarnason. I can not recommend this book highly enough.

##### Transition to Dart 2

`dartz` was originally written for Dart 1, whose weak type system could be abused to simulate higher-kinded types.
Dart 2 has a much stricter type system, making it impossible to pull off the same trick without regressing to fully dynamic typing.
Therefore, the open, type class based design of older versions of `dartz` is gradually being replaced by a more closed design, with a fixed set of type class instances interacting through hard coded logic. Some things, such as monad transformers, will probably have to be completely removed.
Starting with version 0.8.0 and going forward, more and more of `dartz` will be Dart 2 compatible, at the expense of many breaking API changes. If you are developing for Dart 1, you might be happier sticking with version 0.7.5.

TODO: Document 0.9.0+

##### Status for versions >= 0.8.0

* Core design is in flux, with a lot of restructuring going on
* Basic functionality of collections, tuples, Evaluation, Option, Either, State and Free works on Dart 2
* Everything still works on Dart 1
* Conveyor is currently broken on Dart 2
* Explicit type class hierarchy is still in there, but is going away in 0.9.x

##### Status for versions < 0.8.0

* Basic type class structure and collection classes are relatively stable
* Optimized for dart2js/node/v8, with performance on the dart vm being of distant secondary concern
* Most things are stack safe and reasonably efficient, but there are a couple of exceptions and plenty of room for further optimizations
* The streaming/conveyor stuff is highly experimental
* The lens implementation is experimental and very bare bones

##### License/Disclaimer

See [LICENSE](https://github.com/spebbe/dartz/blob/master/LICENSE)
