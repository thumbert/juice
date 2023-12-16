library src.args.int_list;

import 'package:petitparser/petitparser.dart';

import '../expressions/expression.dart';


/// A non-empty list of positive integers, or integer ranges.
/// For example it parses the string `[3, 7, 9-11, 15, 20-24]`
/// It will parse into an ordered int list.  Overlapping values and
/// duplicates are ignored.
///
final intList = (char('[').trim() &
((digit().plus() & (char('-') & digit().plus()).optional()).trim() &
(char(',').trim() &
(digit().plus() & (char('-') & digit().plus()).optional())
    .trim())
    .star()) &
char(']'))
    .trim()
    .map(_createIntList);

/// Input list [x] can be either:
/// * list of digit characters: ['2', '1']
/// * list of digit characters separated by dash: ['2', '1', '-', '2', '4']
///
/// Return a list of sorted int values.
IntListExpr _createIntList(List x) {
  List<int> processIntListElement(List xs) {
    var i = xs.indexOf('-');
    if (i == -1) {
      // an integer
      return [int.parse(xs.join())];
    } else {
      // an integer range
      var start = int.parse(xs.sublist(0, i).join());
      var end = int.parse(xs.sublist(i + 1).join());
      if (end < start) {
        throw const ParserException(
            Failure('', 0, 'end before start in integer range'));
      }
      return List.generate(end - start + 1, (i) => start + i);
    }
  }

  /// x[0] = '[', x[2] = ']'
  var z0 = x[1][0][0] as List;
  if (x[1][0][1] != null) {
    z0 = [...z0, x[1][0][1][0], ...x[1][0][1][1]];
  }

  var z = [
    z0,
    if ((x[1] as List).length == 2)
      ...(x[1][1] as List).map((e) {
        var x1 = e[1] as List;
        if (x1[1] == null) {
          return x1[0];
        } else {
          return [...x1[0], x1[1][0], ...x1[1][1]];
        }
      })
  ];

  var y = z.expand((e) => processIntListElement(e)).toSet().toList();
  y.sort();

  return IntListExpr(y);
}


/// An int list expression.
class IntListExpr extends Expression {
  IntListExpr(this.value);
  final List<int> value;
  @override
  List<int> eval(Map<String, dynamic> variables) => value;
  @override
  String toString() => 'List<int>{$value}';
}


class MonthsListExpr extends Expression {
  MonthsListExpr(this.value);
  final List<int> value;
  @override
  List<int> eval(Map<String, dynamic> variables) => value;
  @override
  String toString() => 'MonthsList{$value}';
}


class HoursListExpr extends Expression {
  HoursListExpr(this.value);
  final List<int> value;
  @override
  List<int> eval(Map<String, dynamic> variables) => value;
  @override
  String toString() => 'HoursList{$value}';
}


