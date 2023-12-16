library test.functions.window_test;

import 'package:date/date.dart';
import 'package:test/test.dart';
import 'package:timeseries/timeseries.dart';

import 'package:juice/src/functions/window.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

void tests() {
  group('Parse window function', () {
    final tz = getLocation('America/New_York');
    test('months filter', () {
      var x = TimeSeries<num>.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 2, 1), 3.0),
        IntervalTuple(Date.utc(2022, 2, 4), 8.0),
        IntervalTuple(Date.utc(2022, 3, 3), 8.0),
        IntervalTuple(Date.utc(2022, 3, 19), 5.0),
      ]);
      expect(
          windowFun.parse('window(x, months=[1,2])').value.eval({'x': x}),
          TimeSeries<num>.fromIterable([
            IntervalTuple(Date.utc(2022, 1, 1), 1.0),
            IntervalTuple(Date.utc(2022, 1, 2), 2.0),
            IntervalTuple(Date.utc(2022, 2, 1), 3.0),
            IntervalTuple(Date.utc(2022, 2, 4), 8.0),
          ]));
    });
    test('bucket filter', () {
      var x = TimeSeries<num>.fill(Date(2022, 1, 1, location: tz).hours(), 1.0);
      var ts = windowFun.parse("window(x, bucket='7x8')").value.eval({'x': x}) as TimeSeries;
      expect(ts.length, 8);
    });
    test('filter combo: bucket + months', () {
      var x = TimeSeries.fromIterable([
        ...TimeSeries<num>.fill(Date(2022, 1, 1, location: tz).hours(), 1.0),
        ...TimeSeries<num>.fill(Date(2022, 3, 1, location: tz).hours(), 3.0),
      ]);
      var ts = windowFun.parse("window(x, bucket='7x8', months=[3])").value.eval({'x': x}) as TimeSeries;
      expect(ts.length, 8);
    });
    test('filter combo: months + bucket (different order)', () {
      var x = TimeSeries.fromIterable([
        ...TimeSeries<num>.fill(Date(2022, 1, 1, location: tz).hours(), 1.0),
        ...TimeSeries<num>.fill(Date(2022, 3, 1, location: tz).hours(), 3.0),
      ]);
      var ts = windowFun.parse("window(x, months=[3], bucket='7x8')").value.eval({'x': x}) as TimeSeries;
      expect(ts.length, 8);
    });
  });

}

void main() {
  initializeTimeZones();
  tests();
}