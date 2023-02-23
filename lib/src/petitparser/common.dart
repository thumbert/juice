import 'dart:async';
import 'dart:math';

/// Common mathematical constants.
final constants = {
  'e': e,
  'pi': pi,
};

/// Functions of arity 1.
final functions1 = <String, FutureOr<dynamic> Function(dynamic)>{
  'exp': (x) => exp(x),
  'log': (x) => log(x),
  'sin': (x) => sin(x),
  'asin': (x) => asin(x),
  'cos': (x) => cos(x),
  'acos': (x) => acos(x),
  'tan': (x) => tan(x),
  'atan': (x) => atan(x),
  'sqrt': (x) => sqrt(x),

  /// custom functions
  'get': (x) => x,
  'aget': (x) => Future.value(x),
};

/// Functions of arity 2
final functions2 = <String, FutureOr<dynamic> Function(dynamic, dynamic)>{
  'sum2': (x, y) => x + y,
};

