library src.parser.dart;

import 'dart:math' as math;

import 'package:juice/src/expressions/binary.dart';
import 'package:juice/src/expressions/callable.dart';
import 'package:juice/src/expressions/comment.dart';
import 'package:juice/src/expressions/expression.dart';
import 'package:juice/src/expressions/unary.dart';
import 'package:juice/src/expressions/value.dart';
import 'package:juice/src/expressions/variable.dart';
import 'package:petitparser/petitparser.dart';

final parser = () {
  final builder = ExpressionBuilder<Expression>();
  builder
    ..primitive(comment1)
    ..primitive(number)
    // ..primitive(hourlyScheduleFun)
    // ..primitive(maFun)
    ..primitive(callable)
    ..primitive(variable);

  /// parentheses just return the value
  builder.group().wrapper(
      char('(').trim(), char(')').trim(), (left, value, right) => value);

  /// Simple math ops
  builder.group()
    ..prefix(char('+').trim(), (op, a) => a)
    ..prefix(char('-').trim(), (op, a) => UnaryNegation(a));
  builder.group().right(char('^').trim(),
          (a, op, b) => Binary('^', a, b, (a, b) => math.pow(a, b)));
  builder.group()
    ..left(char('*').trim(), (a, op, b) => BinaryMultiply(a, b))
    ..left(char('/').trim(), (a, op, b) => BinaryDivide(a, b));
  builder.group()
    ..left(char('+').trim(), (a, op, b) => BinaryAdd(a, b))
    ..left(string('.+').trim(), (a, op, b) => BinaryDotAddition(a, b))
    ..left(char('-').trim(), (a, op, b) => BinarySubtract(a, b));
  builder.group()
    ..left(char('>').trim(), (a, op, b) => BinaryGreaterThan(a, b))
    ..left(string('>=').trim(), (a, op, b) => BinaryGreaterThanEqual(a, b))
    ..left(char('<').trim(), (a, op, b) => BinaryLessThan(a, b))
    ..left(string('<=').trim(), (a, op, b) => BinaryLessThanEqual(a, b));

  return builder.build().end();
}();
