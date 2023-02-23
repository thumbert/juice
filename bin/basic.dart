/// This file shows an example of how to create a dart function and make it
/// available from js

@JS()
library juice_js;

import 'package:js/js.dart';

@JS('sumFunnyName')
external set _sumFunnyName(num Function(num, num) f);

num sumFunnyName(num a, num b) => a + b;

/// Run the command to create a js library
/// `dart compile js -o editor/out/basic.js bin/basic.dart`
/// This will make the sumFunnyName available in js once you add the
/// `<script src="out/basic.js"></script>` to your `index.html`
///
/// You can call it from your body
///     <script>
///         document.write(sumFunnyName(3, 4))
///     </script>

main() {
  _sumFunnyName = allowInterop(sumFunnyName);
}