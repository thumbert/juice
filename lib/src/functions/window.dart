library src.functions.args;

import 'package:elec/elec.dart';
import 'package:juice/src/args/int_list.dart';
import 'package:petitparser/parser.dart';
import 'package:timeseries/timeseries.dart';
import 'package:date/date.dart';
import '../args/args.dart';
import '../expressions/expression.dart';
import '../expressions/variable.dart';

final windowArg = seq2(char(',').trim(), bucketArg) |
    seq2(char(',').trim(), monthsArg) |
    seq2(char(',').trim(), hoursArg);

/// Parse expressions like:
/// `window(bucket='5x16', months=[1,2], hours=[8-20])`
final windowFun =
    (string('window(') & variable & windowArg.repeat(1, 3) & char(')'))
        .trim()
        .map((value) {
  Bucket? bucket;
  var months = <int>[];
  var hours = <int>[];
  var args = <int>[0, 0, 0];

  var v2 = (value[2] as List);
  for (var e in v2) {
    switch (e.$2) {
      case Bucket():
        bucket = e.$2;
        args[0]++;
      case MonthsListExpr():
        months = e.$2.value;
        args[1]++;
      case HoursListExpr():
        hours = e.$2.value;
        args[2]++;
    }
  }
  if (args.any((e) => e > 1)) {
    throw StateError('Can\'t have the same optional argument twice!');
  }

  return WindowExpr(x: value[1], bucket: bucket, months: months, hours: hours);
});

/// The window expression associated with the window function.
///
class WindowExpr extends Expression {
  WindowExpr(
      {required this.x,
      this.bucket,
      required this.months,
      required this.hours});

  final Variable x;
  final Bucket? bucket;
  final List<int> months;
  final List<int> hours;

  @override
  dynamic eval(Map<String, dynamic> variables) {
    var ts = x.eval(variables) as TimeSeries<num>;
    if (months.isNotEmpty) {
      var monthsS = months.toSet();
      ts = ts
          .where((e) => monthsS.contains(e.interval.start.month))
          .toTimeSeries();
    }

    if (hours.isNotEmpty) {
      var hoursS = hours.toSet();
      ts = ts
          .where((e) => hoursS.contains(e.interval.start.hour))
          .toTimeSeries();
    }

    if (bucket != null) {
      if (ts.first.interval is! Hour) {
        throw StateError(
            'The bucket argument is only allowed for hourly timeseries!'
            'Your timeseries is not hourly.');
      }
      ts = ts
          .where((e) => bucket!.containsHour(e.interval as Hour))
          .toTimeSeries();
    }

    return ts;
  }

  @override
  String toString() => 'window(${x.name}, bla-bla)';
}
