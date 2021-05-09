# Changelog

## 0.10.0-nullsafety.2

- Updating dev_dependency plugin test to 0.17.1

## 0.10.0-nullsafety.1

- Corrected signature of `optionOf` to `A? => Option<A>` (issue #74, thanks @rich-j)
- Added `toNullable()` to `Option` (issue #74, thanks @apiep)

## 0.10.0-nullsafety.0

- Basic null safety support
- Requires Dart >= 2.12. Dart 1 is no longer supported at all.

## 0.9.2

- mapXX and liftXX arities up to 20 on Option, Either and Free, courtesy of @cranst0n!

## 0.9.1

- Dart 2.8.1 compatibility

## 0.9.0

- Type class hierarchy reworked to be implemented rather than extended
- Removed monad transformers and some other stuff that can't be made type safe on Dart 2
- IList and Option has some const support
- Improved Dart 2 support
- Conveyor works on Dart 2!
- TupleXX and FunctionXX arities up to 20, courtesy of @modulovalue!
- IVector#indexOf

## 0.8.9

- Polished pana score

## 0.8.8

 - Dart 2.6.0 compatibility

## 0.8.7

- Refined types on Task, for better Dart 2 support (issue #24, thanks @rlavolee)

## 0.8.6

- Added asCons() and option to IList (issue #17, thanks @modulovalue)
- Added isEmpty to AVLTree, IList, IMap, ISet and IVector (issue #23, thanks @rich-j)
- Compatibility with Dart 2.4.0 (issue #18, thanks @xsobolx)

## 0.8.5

- Compatibility with Dart > 2.3.2 through workaround for https://github.com/dart-lang/sdk/issues/35097
  - Thanks @modulovalue and @CatherineThompson for reporting!
- Direct `value` access on Some, Left and Right
  - Thanks @modulovalue for PR #15!

## 0.8.4

- Added transform, filter, where and partition to ISet

## 0.8.3

- Preliminary Dart 2.2.0 compatibility
- 'cast' now generates "implicit" checks, causing dart2js to produce dramatically more efficient js code in some cases

## 0.8.2

- Added isLeft, isRight and swap to Either
- Fixed some type issues on 2.1.0-dev.6.0

## 0.8.1

- Massive performance improvements for many operations on IMap on Dart 2
  - Inserts and lookups are now almost as fast on Dart 2 as on Dart 1
- Fixed some tests that passed for the wrong reason...

## 0.8.0

- Bridge release with few breaking changes, full Dart 1 support and rudimentary Dart 2 support
- (0.9.0 will probably be Dart 2 only and have lots of breaking changes)
- Basic things work correctly on Dart 2 -- many other things don't...
- Started work on removing type class hierarchy, with hard coded replacements such as IList#traverseFuture being added
- Temporarily replaced propcheck with quick'n'dirty minimal replacement, while it is being updated for Dart 2
- Disabled some broken monad transformer tests, since they probably won't survive the move to Dart 2

## 0.7.5

- IMap.fromPairs and IHashMap.fromPairs, for constructing maps from sequences of Tuple2
- IList.flattenIList and IVector.flattenIVector for type safe flattening of IList/IVector
- IList.flattenOption and IVector.flattenOption for type safe flattening/uniting IList/IVector of Option

## 0.7.4

- Corrected analyzer errors on recent Dart 2 dev releases

## 0.7.3

- More useful types for eitherM()
- Declared argument type F of '>>' on MonadOps as covariant, enabling better specialization in implementations
- Specialized types for replace on StateT
- Fixed buggy foldLeftWithIndex/foldRightWithIndex on IVector


## 0.7.2

- Added curried versions of several Lens members (setC, modifyC and so on)
- Improved typing for generic methods on Evaluation
- More type information retained for filter operations on MonadPlus instances
- Added custom filter operation on Either
- Introduced 'where' as an alias to filter where applicable


## 0.7.1

- Added foldLeftWithIndexBetween and foldRightWithIndexBetween to IVector
- Added cata and order to IMap
- Exposed step operation on Free, enabling manual bind reassociation for now

## 0.7.0

- Preparations for Dart 2.0
- Improved type safety for IMap and ISet
  - Reworked and/or removed functions/constructors that implicitly assumed that keys/members implemented Comparable
  - Added replacement helpers for constructors that couldn't be saved
  - All dependencies on Comparable are now explicit and enforced by the type system
- IMap additions:
  - getKey
  - mapKV
  - traverseKV
  - traverseKV_

## 0.6.3

- Added:
  - foldLeftBetween and foldRightBetween operations to AVLTree
  - foldLeftBetween, foldRightBetween and subSetBetween operations to ISet
  - regexp pipe to Text utilities
  - IList.generate factory constructor
  - ifM combinator and some type refinements to Free
  - Eq instances for Iterators
- More memory efficient and faster equality checks for IMap, IHashMap, AVLTree, ISet and IVector
- New, slightly more advanced example for streaming IO

## 0.6.2

- I goofed up... the "efficient file reads" from 0.6.1 now actually work!

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
