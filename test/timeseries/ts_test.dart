library test.timeseries.ts_test;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:juice/src/timeseries/ts.dart' as ts;
import 'package:test/test.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/timezone.dart';

void tests() {
  group('Timeseries tests:', () {
    var location = getLocation('America/New_York');
    test('timeseries for bucket', () {
      var domain = Term.parse('Jan22', location);
      expect(ts.filledForBucket(domain, Bucket.b5x16, 1).length, 21);
      expect(ts.filledForBucket(domain, Bucket.b2x16H, 1).length, 10);
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  tests();
}
