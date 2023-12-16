library test.basic_test;

import 'package:juice/src/expressions/comment.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'package:juice/src/parser.dart';

Function accept(Parser p) => (input) => p.parse(input) is Success;


void tests() {
  group('Basic parser tests', () {
    test('multi-line expression', () {
      var res = parser.parse('''
    2 + 
    2''').value.eval({});
      expect(res, 4);
    });
    test('stand alone comments', () {
      var res = parser.parse('// so easy!').value.eval({});
      expect(res, null);
    });
    test('end of line comments', () {
      expect('///', accept(comment1));
      expect('/// foo', accept(comment1));
      expect('/// \n', accept(comment1));
      expect('/// foo \n', accept(comment1));

      // var res = parser.parse('2 + 2 // so easy!').value.eval({});
      // expect(res, 4);
    });
    test('try to eval for a value that isn\'t there', () {
      expect(() => parser.parse('x + 2').value.eval({}), throwsA('Unknown variable x'));
    });

  });

}

void main() {
  tests();
}