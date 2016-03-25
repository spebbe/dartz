# Changelog

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
- curried appendC for Semigroup

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
