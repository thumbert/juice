import 'package:juice/juice.dart';

import 'dart:io';

void main(List<String> args) {
  if (args.length > 1) {
    stderr.writeln('Usage: juice [script]');
    exit(64);
  } else if (args.length == 1) {
    _runFile(args[0]);
  } else {
    _runPrompt();
  }
}

void _runFile(String path) {
  Juice().run(File(path).readAsStringSync().replaceAll('\\n', '\n'));
}

void _runPrompt() {
  var juice = Juice();
  while (true) {
    stdout.write('> ');
    var line = stdin.readLineSync();
    if (line == null) {
      stdout.writeln();
      break;
    }
    juice.run(line.replaceAll('\\n', '\n'));
  }
}
