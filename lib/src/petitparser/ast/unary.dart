library ast.unary;

import 'dart:async';
import 'expression.dart';

/// An unary expression.
class Unary extends Expression {
  Unary(this.name, this.value, this.function);

  final String name;
  final Expression value;
  final FutureOr<dynamic> Function(dynamic) function;

  @override
  Future<dynamic> eval(Map<String, dynamic> variables) async {
    var res = function(await value.eval(variables));
    return res;
  }

  @override
  String toString() => 'Unary{$name}';
}
