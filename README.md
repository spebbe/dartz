dartz
-----

Functional programming in Dart

* Type class hierarchy in the spirit of [scalaz](https://github.com/scalaz/scalaz) and [the standard Haskell libraries](https://wiki.haskell.org/Typeclassopedia)
* Immutable, persistent collections, including IList, IMap and ISet
* Option, Either, State, Tuple, Free and other tools for programming in a functional style
* Type class instances (Monoids, Traversable Functors, Monads and so on) for included types as well as for several standard Dart types

##### Status

* Super experimental and in a very early stage of development
* dartz is based on concepts from Haskell and Scala. Since Dart lacks some important language/type system features present in those languages, there are several uglies in dartz owing to compromises between type safety and general usefulness
* Several important type classes are missing
* Some things are slow memory hogs, other things are lean and mean
* Some things are stack safe, other things aren't
* Some poor decisions have been made and might be corrected in the future (possibly through new poor decisions)
* There might be a couple of bugs in there (gasp!!!)

##### License/Disclaimer

See [LICENSE](https://github.com/spebbe/dartz/blob/master/LICENSE)
