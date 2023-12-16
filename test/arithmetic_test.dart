library test.arithmetic_test;

import 'dart:math';

import 'package:date/date.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'package:juice/src/parser.dart';
import 'package:timeseries/timeseries.dart';

void tests() {
  group('Basic arithmetic tests', () {
    test('arithmetic', () {
      var res = parser.parse('2 + 2');
      expect(res is Success, true);
      var value = res.value.eval({});
      expect(value, 4);
    });
    test('arithmetic with parentheses and integers', () {
      var res = parser.parse('2 + 2 * (3 - 1)');
      expect(res is Success, true);
      var value = res.value.eval({});
      expect(value, 6);
    });
    test('arithmetic with variables', () {
      var res = parser.parse('x + 2 * y');
      expect(res is Success, true);
      var value = res.value.eval({'x': 1, 'y': 2});
      expect(value, 5);
    });
    test('sin function', () {
      // trace(parser).parse('sin(0.0)');
      expect(parser.parse('sin(0.0)') is Success, true);
      expect(parser.parse('sin(0.0)').value.eval({}), 0.0);
      expect(parser.parse('sin(pi/4)').value.eval({}), 1 / sqrt2);
      var x = TimeSeries<num>.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 0.0),
        IntervalTuple(Date.utc(2022, 1, 2), pi / 6),
        IntervalTuple(Date.utc(2022, 1, 3), pi / 2),
      ]);
      expect(parser.parse('sin(x)').value.eval({'x': x}), x.apply((e) => sin(e)));
    });
    test('linear transform of sin function ', () {
      // trace(parser).parse('sin(0.0)');
      expect(parser.parse('3 + 2*sin(x)') is Success, true);
      expect(parser.parse('3 + 2*sin(x)').value.eval({'x': pi / 6}), 4.0);
    });
  });

}

void main() {
  tests();
}