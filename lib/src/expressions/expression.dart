library ast.expression;

import 'dart:math' as math;

import 'package:juice/src/expressions/binary.dart';
import 'package:juice/src/expressions/unary.dart';
import 'package:juice/src/expressions/value.dart';
import 'package:juice/src/expressions/variable.dart';
import 'package:petitparser/petitparser.dart';

final expression = () {
  final builder = ExpressionBuilder<Expression>();
  builder
    ..primitive(number)
    ..primitive(variable);

  /// parentheses just return the value
  builder.group().wrapper(
      char('(').trim(), char(')').trim(), (left, value, right) => value);

  /// Simple math ops
  builder.group()
    ..prefix(char('+').trim(), (op, a) => a)
    ..prefix(char('-').trim(), (op, a) => Unary('-', a, (x) => -x));
  builder.group().right(char('^').trim(),
          (a, op, b) => Binary('^', a, b, (a, b) => math.pow(a, b)));
  builder.group()
    ..left(char('*').trim(), (a, op, b) => Binary('*', a, b, (x, y) => x * y))
    ..left(char('/').trim(), (a, op, b) => Binary('/', a, b, (x, y) => x / y));
  builder.group()
    ..left(char('+').trim(), (a, op, b) => Binary('+', a, b, (x, y) => x + y))
    ..left(char('-').trim(), (a, op, b) => Binary('-', a, b, (x, y) => x - y));
  return builder.build();
}();



/// An abstract expression that can be evaluated.
abstract class Expression {
  /// Evaluates the expression with the provided [variables].
  /// this can throw if the expression can't be evaluated, for example
  /// the [variables] don't contain what is needed.
  dynamic eval(Map<String, dynamic> variables);
}

