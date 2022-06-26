library timeseries.ts;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

/// Construct a timeseries with a given [value] for all time intervals belonging
/// to [bucket].
/// Note: it doesn't return an hourly curve.
TimeSeries<num> filledForBucket(Term domain, Bucket bucket, num value) {
  var out = TimeSeries<num>();
  var hours = domain.hours();
  TZDateTime? start;
  for (var hour in hours) {
    if (bucket.containsHour(hour)) {
      start ??= hour.start;
    } else {
      if (start != null) {
        out.add(IntervalTuple(Interval(start, hour.start), value));
        start = null;
      }
    }
  }

  return out;
}

/// Add two timeseries.  It is an outer join add, as the returned
/// timeseries contains the union of the intervals of [x] and [y].
/// Missing intervals are treated as having a value of 0.
///
/// If the intervals do not match exactly, throw an error.
///
TimeSeries<num> tsAdd(TimeSeries<num> x, TimeSeries<num> y) {
  var z = x.merge(y, joinType: JoinType.Outer, f: (x, y) {
    if (x == null) return y as num;
    if (y == null) return x;
    return x + (y as num);
  });
  return z;
}
