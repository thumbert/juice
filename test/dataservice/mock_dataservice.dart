import 'package:juice/src/dataservice/dataservice.dart';
import 'package:timeseries/timeseries.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:date/date.dart';
import 'package:timezone/timezone.dart';

class MockDataservice extends DataService {
  @override
  Future<TimeSeries<num>> get(String id, {required Location location}) {
    if (id == 'noaa_bos_temp') {
      var aux = _getBostonTemperature();
      return aux;
    }
    throw UnimplementedError();
  }
}

Future<TimeSeries<num>> _getBostonTemperature() async {
  var converter = CsvToListConverter();
  var lines = await File('test/datastore/USW00014739.csv').readAsLines();

  var out = TimeSeries<num>();
  for (var line in lines.skip(1)) {
    var data = converter.convert(line).first;
    var tMin = num.tryParse(data[3]);
    var tMax = num.tryParse(data[2]);
    if (tMin != null && tMax != null) {
      out.add(IntervalTuple(Date.parse(data[1] as String), (tMin + tMax) / 2));
    }
  }
  return out;
}
