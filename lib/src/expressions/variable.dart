library ast.variable;

import 'package:petitparser/petitparser.dart';

import 'expression.dart';
import 'common.dart';
import 'value.dart';

final variable = (letter() & word().star())
    .flatten('variable name expected')
    .trim()
    .map(_createVariable);

Expression _createVariable(String name) =>
    constants.containsKey(name) ? Value(constants[name]!) : Variable(name);

/// A variable expression.
class Variable extends Expression {
  Variable(this.name);

  final String name;

  @override
  dynamic eval(Map<String, dynamic> variables) => variables.containsKey(name)
      ? variables[name]!
      : throw 'Unknown variable $name';

  @override
  String toString() => 'Variable $name';
}
