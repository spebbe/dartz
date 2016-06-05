library huffman_codec;

import 'package:dartz/dartz.dart';

/*
  NOTE:
    This is an example of how to use immutable collections and functional programming techniques to solve a problem,
    _NOT_ an industrial strength, production ready huffman codec! (IList<Bit> is kind of a giveaway here)
 */

abstract class _HuffmanNode {
  final num frequency;
  final String char;
  _HuffmanNode(this.frequency, this.char);
  /*=A*/ fold/*<A>*/(/*=A*/ ifInternal(_InternalHuffmanNode node), /*=A*/ ifLeaf(_LeafHuffmanNode node));
  // Technique: Composing Order instances into two level Order
  static final order = orderBy(NumOrder, (_HuffmanNode node) => node.frequency).andThen(orderBy(StringOrder, (_HuffmanNode node) => node.char));
}
class _InternalHuffmanNode extends _HuffmanNode {
  final _HuffmanNode left;
  final _HuffmanNode right;
  _InternalHuffmanNode(num frequency, String char, this.left, this.right): super(frequency, char);
  @override /*=A*/fold/*<A>*/(/*=A*/ ifInternal(_InternalHuffmanNode node), /*=A*/ ifLeaf(_LeafHuffmanNode node)) => ifInternal(this);
}
class _LeafHuffmanNode extends _HuffmanNode {
  _LeafHuffmanNode(num frequency, String char): super(frequency, char);
  @override /*=A*/ fold/*<A>*/(/*=A*/ ifInternal(_InternalHuffmanNode node), /*=A*/ ifLeaf(_LeafHuffmanNode node)) => ifLeaf(this);
}

enum Bit { ZERO, ONE }

class HuffmanCodec {

  final _HuffmanNode _tree;
  final IMap<String, IList<Bit>> _codeBook;

  HuffmanCodec._internal(this._tree, this._codeBook);

  // Technique: Folding an IList of characters into an IMap of character frequencies using a monoid
  static Option<HuffmanCodec> fromSource(String source) => fromCharacterFrequencies(ilist(source.split("")).foldMap(imapMonoid(NumSumMi), (s) => imap({s: 1})));

  // Technique: Returning Option instead of null/exception for computations that might fail
  static Option<HuffmanCodec> fromCharacterFrequencies(IMap<String, num> characterFrequencies) {
    if (characterFrequencies.length() < 2) {
      return none();
    } else {
      // Technique: Folding an IMap into an AVLTree of leaf nodes, for use as a priority queue
      final AVLTree<_HuffmanNode> leafNodes = characterFrequencies
          .foldLeftKV(new AVLTree(_HuffmanNode.order, emptyAVLNode()), (t, char, freq) => t.insert(new _LeafHuffmanNode(freq, char)));
      return _buildTree(leafNodes).map((tree) {
        final codeBook = _buildCodeBook(tree);
        return new HuffmanCodec._internal(tree, codeBook);
      });
    }
  }

  // Technique: Juggling Options using map, bind and |
  // Technique: Using AVL tree as a priority queue
  static Option<_HuffmanNode> _buildTree(AVLTree<_HuffmanNode> nodes) => nodes.min().map((l) {
    final withoutL = nodes.remove(l);
    return withoutL.min().bind((r) {
      final withoutR = withoutL.remove(r);
      return _buildTree(withoutR.insert(new _InternalHuffmanNode(l.frequency+r.frequency, l.char+r.char, l, r)));
    }) | l;
  });

  // Technique: Recursively building ILists using cons
  static IMap<String, IList<Bit>> _buildCodeBook(_HuffmanNode tree) {
    IMap<String, IList<Bit>> buildCodes(_HuffmanNode node, IMap<String, IList<Bit>> codes, IList<Bit> code) => node.fold(
        (internalNode) {
          final leftCodes =  buildCodes(internalNode.left, codes, cons(Bit.ZERO, code));
          return buildCodes(internalNode.right, leftCodes, cons(Bit.ONE, code));
        }, (leafNode) {
          return codes.put(leafNode.char, code.reverse());
        }
    );
    return buildCodes(tree, imap({}), nil());
  }

  // Technique: Monadic traversal over IList with Option as applicative effect
  Option<IList<Bit>> encode(String plainText) => ilist(plainText.split("")).traverseM(optionMP(), _codeBook.get);

  // Technique: Deep recursion without fear, using Trampoline primitives tcall and treturn
  // Technique: Applicative mapping over multiple Options
  String decode(IList<Bit> compressed) {
    Trampoline<String> loop(_HuffmanNode tree, _HuffmanNode current, IList<Bit> compressed, String decompressed) => current.fold(
        (internalNode) {
          return OptionMP.map2(compressed.headOption, compressed.tailOption, (Bit bit, IList<Bit> bits) {
            final nextNode = (bit == Bit.ONE ? internalNode.right : internalNode.left);
            return tcall(() => loop(tree, nextNode, bits, decompressed));
          }) | treturn(decompressed);
        }, (leafNode) {
          return tcall(() => loop(tree, tree, compressed, decompressed+leafNode.char));
        }
    );
    return loop(_tree, _tree, compressed, "").run();
  }

}
