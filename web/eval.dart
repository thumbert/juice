import 'dart:html';

import 'package:juice/juice.dart';

final input = querySelector('#input')! as TextInputElement;
final result = querySelector('#result')! as ParagraphElement;
final tree = querySelector('#tree')! as ParagraphElement;

Future<void> update() async {
  final source = input.value ?? '0';
  tree.text = '';
  try {
    final expr = parser.parse(source).value;
    tree.innerHtml = inspect(expr);
    result.text = ' = ${await expr.eval({})}';
    result.classes.clear();
  } on Object catch (exception) {
    result.text = exception.toString();
    result.classes.add('error');
  }
  window.location.hash = Uri.encodeComponent(source);
}

String inspect(Expression expr, [String indent = '']) {
  final result = StringBuffer('$indent$expr<br>');
  if (expr is Unary) {
    result.write(inspect(expr.value, '&nbsp;&nbsp;$indent'));
  } else if (expr is Binary) {
    result.write(inspect(expr.left, '&nbsp;&nbsp;$indent'));
    result.write(inspect(expr.right, '&nbsp;&nbsp;$indent'));
  }
  return result.toString();
}

void main() {
  print(window.location.hash);
  if (window.location.hash.startsWith('#')) {
    input.value = Uri.decodeComponent(window.location.hash.substring(1));
  }
  update();
  input.onInput.listen((event) => update());
}