import 'package:timezone/data/latest.dart';

import 'arithmetic_test.dart' as arithmetic;
import 'basic_test.dart' as basic;
import 'functions/window_test.dart' as window;

void main() {
  initializeTimeZones();
  arithmetic.tests();
  basic.tests();
  window.tests();
}
