import 'dart:async';
import 'dart:math';

/// Common mathematical constants.
final constants = {
  'e': e,
  'pi': pi,
};

/// Functions of arity 1.
final functions1 = <String, FutureOr<num> Function(num)>{
  'exp': exp,
  'log': log,
  'sin': sin,
  'asin': asin,
  'cos': cos,
  'acos': acos,
  'tan': tan,
  'atan': atan,
  'sqrt': sqrt,

  /// custom functions
  'get': (num x) => x,
  'aget': (num x) => Future.value(x),
};

/// Functions of arity 2
final functions2 = <String, FutureOr<num> Function(num, num)>{
  'sum2': (num x, num y) => x + y,
};

