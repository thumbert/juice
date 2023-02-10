library ast.unary;

import 'dart:async';
import 'expression.dart';

/// An unary expression.
class Unary extends Expression {
  Unary(this.name, this.value, this.function);

  final String name;
  final Expression value;
  final FutureOr<num> Function(num value) function;

  @override
  // num eval(Map<String, num> variables) => function(value.eval(variables));
  Future<num> eval(Map<String, num> variables) async {
    var res = function(await value.eval(variables));
    return res;
  }

  @override
  String toString() => 'Unary{$name}';
}
