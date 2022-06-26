library dataservice;

import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

abstract class DataService {
  Future<TimeSeries<num>> get(String id, {required Location location});
}
