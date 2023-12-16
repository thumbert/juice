library src.expressions.value;

import 'package:petitparser/petitparser.dart';
import 'expression.dart';

final number = (digit().plus() &
        (char('.') & digit().plus()).optional() &
        (pattern('eE') & pattern('+-').optional() & digit().plus()).optional())
    .flatten('number expected')
    .trim()
    .map(_createValue);

Value _createValue(String value) => Value(num.parse(value));

/// A value expression.
class Value extends Expression {
  Value(this.value);

  final num value;

  @override
  num eval(Map<String, dynamic> variables) => value;

  @override
  String toString() => 'Value{$value}';
}
