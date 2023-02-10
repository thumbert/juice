library ast.variable;

import 'dart:async';
import 'expression.dart';

/// A variable expression.
class Variable extends Expression {
  Variable(this.name);

  final String name;

  @override
  Future<num> eval(Map<String, num> variables) => variables.containsKey(name)
      ? Future.value(variables[name]!)
      : throw 'Unknown variable $name';

  @override
  String toString() => 'Variable{$name}';
}