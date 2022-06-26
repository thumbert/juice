library test.interpreter_test;

import 'dart:async';
import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:juice/src/ast.dart';
import 'package:juice/src/interpreter.dart';
import 'package:juice/src/juice.dart';
import 'package:juice/src/runtime_error.dart';
import 'package:juice/src/timeseries/ts.dart' as ts;
import 'package:juice/src/token.dart';
import 'package:test/test.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/timezone.dart';

void tests() {
  var printLog = <String>[];
  group('Interpreter tests:', () {
    var location = getLocation('America/New_York');
    var juice = Juice(runMode: RunMode.debug);
    void captureOutput(String printStatement) {
      printLog.clear();
      runZoned(() => juice.run(printStatement), zoneSpecification:
          ZoneSpecification(print: (self, parent, zone, line) {
        printLog.add(line);
      }));
    }

    test('Set the domain', () {
      juice.run('setDomain("Jan22", "America/New_York");');
    });
    // test('Print the domain', () {
    //   juice.run('setDomain("Jan22", "America/New_York");');
    //   captureOutput('print domain;');
    //   print(printLog);
    //   expect(printLog.first, 'Jan22, tz="America/New_York"');
    // });

    test('Create a timeseries with one value', () {
      juice.run('var x = ts(1);');
      expect(
          juice.interpreter.globals.getName('x').runtimeType == TimeSeries<num>,
          true);
      captureOutput('print x;');
      expect(printLog.first,
          '[2022-01-01 00:00:00.000-0500, 2022-02-01 00:00:00.000-0500) -> 1.0');
    });
    test('Add two time series', () {
      juice.run('var x = ts(1); var y = ts(2);');
      juice.run('var z = x + y;');
      var z = juice.interpreter.globals.getName('z') as TimeSeries<num>;
      expect(z.first.value, 3.0);
    });
    test('Adding a number to a timeseries throws', () {
      juice.run('var x = ts(1); var y = 1;');
      expect(() => juice.run('var z = x + y;'), throwsException);
    });
    test('Get the length/head/tail of a timeseries', () {
      juice.run('setDomain("Jan22", "America/New_York");');
      juice.run('var x = tsForBucket("5x16", 1);');
      // captureOutput('print x.head(3);');
      captureOutput('print x.length;');
      expect(printLog.first, '21'); // number of peak days
      captureOutput('print x.head;');
      expect(printLog.first.split('\n').first,
          '[2022-01-03 07:00:00.000-0500, 2022-01-03 23:00:00.000-0500) -> 1.0');
      captureOutput('print x.tail;');
      expect(printLog.first.split('\n').last,
          '[2022-01-31 07:00:00.000-0500, 2022-01-31 23:00:00.000-0500) -> 1.0');
    });
    test('Time filter', () {
      juice.run('var tf = TimeFilter(bucket="5x16", hours="14-20");');
    });
  });
}

Future<void> main() async {
  initializeTimeZones();

  tests();
}
