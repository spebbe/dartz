dartz
-----

Functional programming in Dart

* Type class hierarchy in the spirit of [scalaz](https://github.com/scalaz/scalaz) and [the standard Haskell libraries](https://wiki.haskell.org/Typeclassopedia)
* Immutable, persistent collections, including IVector, IList, IMap, IHashMap, ISet and AVLTree
* Option, Either, State, Tuple, Free and other tools for programming in a functional style
* Evaluation, a Reader+Writer+State+Either+Future swiss army knife monad
* Type class instances (Monoids, Traversable Functors, Monads and so on) for included types, as well as for several standard Dart types
* Conveyor, an implementation of pure functional streaming
* [Examples](https://github.com/spebbe/dartz/tree/master/example), showcasing core concepts


##### New to functional programming?

A good place to start learning is the excellent [Functional Programming in Scala](https://www.manning.com/books/functional-programming-in-scala) by Paul Chiusano and Rúnar Bjarnason. I can not recommend this book highly enough.

##### Status

* Basic type class structure and collection classes are relatively stable
* Optimized for dart2js/node/v8, with performance on the dart vm being of distant secondary concern
* Most things are stack safe and reasonably efficient, but there are a couple of exceptions and plenty of room for further optimizations
* The streaming/conveyor stuff is highly experimental

##### License/Disclaimer

See [LICENSE](https://github.com/spebbe/dartz/blob/master/LICENSE)
