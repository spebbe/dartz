// Fake enumerators until a Dart 2 compatible version is released

import 'dart:async';

import 'package:dartz/dartz.dart';

class Enumeration<A> {
  final Function0<Stream<A>> _stream;

  Enumeration(this._stream);

  Enumeration<B> map<B>(B f(A a)) => new Enumeration(() => _stream().map(f));
  Enumeration<B> flatMap<B>(Enumeration<B> f(A a)) => new Enumeration(() => _stream().asyncExpand((a) => f(a)._stream()));
  Future<bool> forall(bool predicate(A a)) => _stream().take(100).every(predicate);
}

Enumeration<C> apply2<A, B, C>(Function2<A, B, C> f, Enumeration<A> ea, Enumeration<B> eb) => ea.flatMap((a) => eb.map((b) => f(a, b)));

Enumeration<D> apply3<A, B, C, D>(Function3<A, B, C, D> f, Enumeration<A> ea, Enumeration<B> eb, Enumeration<C> ec) => ea.flatMap((a) => eb.flatMap((b) => ec.map((c) => f(a, b, c))));

Enumeration<E> apply4<A, B, C, D, E>(Function4<A, B, C, D, E> f, Enumeration<A> ea, Enumeration<B> eb, Enumeration<C> ec, Enumeration<D> ed) => ea.flatMap((a) => eb.flatMap((b) => ec.flatMap((c) => ed.map((d) => f(a, b, c, d)))));
