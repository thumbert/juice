library ast.binary;

import 'dart:async';
import 'expression.dart';

/// A binary expression.
class Binary extends Expression {
  Binary(this.name, this.left, this.right, this.function);

  final String name;
  final Expression left;
  final Expression right;
  final FutureOr<num> Function(num, num) function;

  @override
  Future<num> eval(Map<String, num> variables) async {
    return function(await left.eval(variables), await right.eval(variables));
  }

  @override
  String toString() => 'Binary{$name}';
}