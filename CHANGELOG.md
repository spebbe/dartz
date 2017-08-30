# Changelog

## 0.6.1

- Way more efficient file reads using Free IO and Conveyor
- Improved typing for Applicative liftX and mapX, with specialized overrides on Option and Either
- Added optionOf utility, for safely wrapping a possibly null value in Option
- Added forEach operation to dartz_unsafe, for performing side effects on Foldables
- Added forEach operations to Option, Either, IList, IVector, ISet, IMap, IHashMap and AVLTree
- Various small tweaks, additions and bug fixes

## 0.6.0

- Updated sdk requirement to >= 1.24.0
  - Now uses real (non-commented) generic method syntax
  - Takes advantage of improvements in strong mode type inference
  - Various workarounds for remaining strong mode quirks

## 0.5.7

- Added efficient operations related to lower/upper bounds to IMap:
  - min
  - max
  - minKey
  - maxKey
  - minGreaterThan
  - maxLessThan
  - foldLeftKVBetween
  - foldRightKVBetween
- hashCode consistent with '==' where overridden

## 0.5.6

- 'Gather' IO primitive for parallelizing IO operations
- Refined types for map2 to map6 on Free and IO monads
- Improvements to type safety/inference for Free and IO

## 0.5.5

- Slightly less efficient, but more correct/safe traverse for IList
- Better type inference for Either and Future Monad instance helpers

## 0.5.4

- Added modifyE to EvaluationMonad, for state updates that can fail
- Either, Option, Evaluation, State, StateT and Free:
  - Tightened types of various derived operations, such as flatMap, andThen and << 

## 0.5.3

- Reworked Free to be stack safe in more cases
  - Implementations more similar to the ones in scalaz and cats
  - Still a work in progress, but works for basic use cases
- Added TraversableMonad instance for Function0

## 0.5.2

- Improved performance of set operation on IMap and IVector
- Added setIfPresent to IMap
- Added setIfPresent, removeFirst, dropFirst, removeLast and dropLast to IVector
- Added window and windowAll to Pipe and Conveyor

## 0.5.1

- Added experimental Lens implementation and example!
- Added IMap.fromIterables
- Slightly faster get operations on IMap and AVLTree

## 0.5.0

- Swallowed a chunk of purist pride:
  - Added toIterable and iterator operations to Option, Either and all immutable collections
  - Added iterables/iterators for pairs, keys and values to IMap and IHashMap

## 0.4.5

- Added minSi and maxSi to Order
- Added reverse to TraversableMonadPlus
- Added zip to IList

## 0.4.4

- Tightened types of some overrides and helpers
- Added free IO primitive Delay
- Added scanWhile to Pipe
- Added foldWhile to Conveyor
- Added repeatEval and repeatEval_ to Source

## 0.4.3

- Added uniteOption to Pipe
- Added chunk to Pipe and Conveyor
- Square bracket syntax as alternative to get(K key) on IMap and IHashMap
- Got rid of all implicit down casts by disabling them in the analysis options
- Cleaner types on Pipe

## 0.4.2

- Aggressive internal optimizations in IList, for speed and memory efficiency
- Much faster map and bind/flatMap IList operations, especially on V8
- Slightly faster map operations on IMap and IVector

## 0.4.1

- Helpers for composing Free algebras and interpreters through coproduct nesting
- Free composition example
- Moved Free IO primitives into IOOps, for easy composition with other Free algebras
- emptyMap and singletonMap convenience functions for IMap
- Some more convenience functions for Conveyor

## 0.4.0

- New mini library, dartz_streaming!
- Moved Conveyor and friends to dartz_streaming
- Added lots of stream combinators for general use, IO and text processing
- Added Execute IO primitive for running external commands
- Beefed up mock IO interpreter

## 0.3.6

- foldLeftWithIndex and foldRightWithIndex on Foldable/FoldableOps
- Specialized foldLeftWithIndex/foldRightWithIndex implementations on IVector
- Source.fromStream (Conveyor) now takes a Stream thunk instead of a direct Stream
- Minor cleanups in streaming IO example

## 0.3.5

- Improved resource safety of Conveyor primitives
- repeatUntilExhausted, repeatNonEmpty, intsFrom, window2 and window2all operations for Conveyor
- Corrections for stronger strong mode

## 0.3.4

- repeatNotEmpty operation for Conveyor
- Opaque FileRefs in Free IO
- Proper type parameterization for derived Tuple Semigroups and Monoids

## 0.3.3

- Tee construct for combining Conveyors
- tee, zip, zipWith, interleave, intersperse and constant operations on Conveyor
- through and to operations for effectful sinks and channels on Conveyor
- Moved Free IO algebra back into library
- Extracted side effecting IO interpreter into "unsafe" mini library

## 0.3.2

- Updated for the improvements to strong mode in Dart 1.19.0
- Fully mockable IO type and other cleanups in examples

## 0.3.1

- Renamed Conveyor primitives (await -> consume, emit -> produce)
- Added identity, drop and dropWhile operations to Pipe and Conveyor
- Added Source#fromStream for driving Conveyors from Dart Streams
- Helpers for creating anonymous Eq instances
- ObjectEq Eq instance for comparing Objects for equality using '=='
- Beefed up mock IO interpreter in Free IO example
- Funner, faster and longer streaming IO example

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
