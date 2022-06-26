library test.dataservice.mock_dataservice;

import 'dart:async';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:date/date.dart';

import 'package:juice/src/dataservice/dataservice.dart';
import 'package:juice/src/juice.dart';
import 'package:timeseries/timeseries.dart';
import 'package:elec/elec.dart';
import 'package:juice/src/timeseries/ts.dart' as ts;
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/timezone.dart';

void tests() {
  var log = <String>[];
  group('Datastore tests:', () {
    // var location = getLocation('America/New_York');
    var juice = Juice(runMode: RunMode.production);
    // void captureOutput(String printStatement) {
    //   log.clear();
    //   runZoned(() => juice.run(printStatement), zoneSpecification:
    //       ZoneSpecification(print: (self, parent, zone, line) {
    //     log.add(line);
    //   }));
    // }

    test('get boston temperature series', () async {
      // juice.run('setDomain("Jan91-Jun22", "America/New_York");');

      /// TODO: define a 'setDatastore' command
      // juice.interpreter.dataService = MockDataservice();
      juice.run('print clock();');
      // juice.run('var temp = get42();');
      // juice.run('print temp;');

      // await Future.delayed(Duration(seconds: 5), () {
      //   print('after waiting 5s in tests');
      //   juice.run('print temp;');
      // });
      // captureOutput('print temp;');
      // print(log);
      // var domain = Term.parse('Jan22', location);
      // expect(ts.filledForBucket(domain, Bucket.b5x16, 1).length, 21);
      // expect(ts.filledForBucket(domain, Bucket.b2x16H, 1).length, 10);
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  tests();
}
