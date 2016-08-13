# Changelog

## 0.3.0

- Conveyor, an experimental implementation of functional streams, based on work by Chiusano/Bjarnason (chapter 15 in FPIS)
- Clarified Free IO example
- Added Streaming IO example, based on Free IO and Conveyor

## 0.2.5

- MonadCatch type class
- Simplistic Task implementation, with MonadCatch instance

## 0.2.4

- Fixed incompatibilities with dart2js

## 0.2.3

- New TraversableMonadPlus type class, with partition operation
- TraversableMonadPlus instances for IList, List, IVector and Option
- prependElement and appendElement operations for ApplicativePlus
- better type inference for applicative mapX operations on Option and Either
- uncons, unconsO and sort operations for IList

## 0.2.2

- Added Free IO example

## 0.2.1

- Added two examples
- Foldable instance for ISet
- liftOption operation for Evaluation
- foldMapM operation for Foldable
- More type annotations and convenience functions

## 0.2.0

- New TraversableMonad and TraversableMonadOps
- Moved traverseM operation to TraversableMonadOps
- Removed IO stuff
- Removed redundant type class instance aliases. Use IListMP instead of IListA, and so on
- Gave up on mixin inheritance chains, since dart2js still doesn't implement them properly

## 0.1.3

- Inspire dart2js to insert fewer cast checks and other runtime type paranoia, leading to significant performance improvements all over the place
- Type parameters for Option mapX operations
- traverseM operation for Traversable

## 0.1.2

- IHashMap, an immutable and persistent map that, unlike IMap, doesn't require a total ordering of keys, but instead relies on hashCode and equality of keys
- Even more method/function type parameters added
- More efficient primitives for State and Evaluation

## 0.1.1

- A lot more method/function type parameters for better type safety/inference
- find and specialized filter operations for IList
- Modified all tests for strong mode compliance
- orElse and eager getOrElse operator '|' for Either
- orElse and getOrElse operations on Option and Either take thunks instead of values
- Faster IMap modify
- Various cleanups

## 0.1.0

- Dart [Strong Mode](https://github.com/dart-lang/dev_compiler/blob/master/STRONG_MODE.md) compliance. This forced a couple of breaking changes:
  - Use `Option<A> none<A>()` instead of `Option<dynamic> none`
  - Prefer `IList<A> nil<A>()` to `IList<dynamic> Nil`
  - ...and so on for emptyVector, IMapMi, etc.
- Much improved type safety through type parameterization of commonly used methods/functions, using the [prototype syntax](https://github.com/dart-lang/dev_compiler/blob/master/doc/GENERIC_METHODS.md). More type annotations to come!

## 0.0.10

- Fixed embarrassing bug in IMap#set. Let's never mention it again.

## 0.0.9

- IVector, an immutable and persistent indexed sequence with O(log n) prepend, append, get and set operations
- MonadPlus, Traversable and Monoid instances for IVector
- Faster List monoid
- Faster map and new set operation for IMap
- strengthL and strengthR operations for Functor
- foldLeftM and foldRightM operations for Foldable

## 0.0.8

- Improved compatibility with dart2js, Dartium and dart strong mode
- Proper type parameters for Tuple semigroups and monoids

## 0.0.7

- Much faster and leaner IMap
- Significantly faster and leaner ISet and AVLTree
- Slightly faster IList

## 0.0.6

- Significantly faster and lighter AVLTree, IMap and ISet
- Corrected a couple of type annotations in IList and Evaluation

## 0.0.5

- toIterable and iterator operations for IList
- Faster, stack safe equality checks for IList, IMap, ISet and AVLTree
- Tighter types for id and Endo

## 0.0.4

- Bind Evaluation and Future through microtask queue by default
- Optimized map implementations for Evaluation and Future
- Retain more type information in Evaluation and EvaluationMonad operations
- Added liftEither and handleError operations to Evaluation/EvaluationMonad

## 0.0.3

- Default foldMap for Traversable is now trampolined
- Moved State primitives to StateMonad
- MonadPlus instance for List
- reverse operation for Order
- modify, foldLeftKV, foldRightKV, foldMapKV, mapWithKey and optimized Foldable operations for IMap
- Curried appendC for Semigroup

## 0.0.2

- Order constructs (order, orderBy, min and max semigroups)
- length, any, all, minimum and maximum operations for Foldable
- Plus, PlusEmpty, ApplicativePlus and MonadPlus type classes
- MonadPlus instances for Option and IList
- ISet monoid and operations for union, intersection and difference
- Option and Either utils (cata, toOption, catching)
- StateT
- Trampoline
- mapWithIndex and zipWithIndex for Traversable

## 0.0.1

- The immutable conception
