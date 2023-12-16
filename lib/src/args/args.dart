library src.functions.args;

import 'package:elec/elec.dart';
import 'package:juice/src/expressions/expression.dart';
import 'package:petitparser/petitparser.dart';
import 'int_list.dart';

/// Comma separated list of expressions
final argList =
(expression & (char(',').trim() & expression).star()).map((values) {
  return <Expression>[values[0], ...(values[1] as List).map((e) => e[1])];
});



/// Parse a bucket argument for a function.
/// For example, `bucket = '7x24'`, or `bucket = 'offpeak'`, etc.
final bucketArg = (string('bucket').trim() &
        char('=').trim() &
        char("'") &
        word().plus() &
        char("'"))
    .trim()
    .map((value) {
  return Bucket.parse((value[3] as List).join());
});

/// Parse a months argument for a function.  Allowed values are between [1, 12].
/// For example, parse `months = [1-2, 7-8]`, or `months = [3, 4-5, 12]`
final monthsArg =
    (string('months').trim() & char('=').trim() & intList).map((value) {
  var xs = (value[2] as IntListExpr).value;
  if (xs.any((e) => e < 1 || e > 12)) {
    throw const ParserException(Failure(
        '', 0, 'Invalid month value.  Value must be between 1 and 12.'));
  }
  return MonthsListExpr(xs);
});

/// Parse the hours argument for a function.  Allowed values are between [0, 23].
/// For example, parse `hours = [1-2, 7-8]`, or `hours = [3, 4-5, 12]`
final hoursArg =
    (string('hours').trim() & char('=').trim() & intList).map((value) {
  var xs = (value[2] as IntListExpr).value;
  if (xs.any((e) => e < 0 || e > 23)) {
    throw const ParserException(
        Failure('', 0, 'Invalid hour value.  Value must be between 0 and 23.'));
  }
  return HoursListExpr(xs);
});
