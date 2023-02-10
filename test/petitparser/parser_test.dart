
import 'dart:math';

import 'package:juice/src/petitparser/ast.dart';
import 'package:juice/src/petitparser/parser.dart';
import 'package:test/test.dart';

void main() {

  var env = <String,num>{};

  test('argument list, 1 numeric', (){
    var aux = argList.parse('3 ');
    expect(aux.isSuccess, true);
    expect(aux.value.length, 1);
    expect((aux.value[0] as Value).value, 3);
  });

  test('argument list, 3 numeric', (){
    var aux = argList.parse('3, 1.2,  5');
    expect(aux.isSuccess, true);
    expect(aux.value.length, 3);
    expect((aux.value[0] as Value).value, 3);
    expect((aux.value[1] as Value).value, 1.2);
    expect((aux.value[2] as Value).value, 5);
  });

  test('argument list with simple expressions', () async {
    var aux = argList.parse('pi,  pi/6, 2+3');
    expect(aux.isSuccess, true);
    expect(aux.value.length, 3);
    expect((aux.value[0] as Value).value, pi);
    expect(await (aux.value[1] as Binary).eval(env), pi/6);
    expect(await (aux.value[2] as Binary).eval(env), 5);
  });

  test('argument list, variable name', (){
    var aux = argList.parse('x, y,  z');
    expect(aux.isSuccess, true);
    expect(aux.value.length, 3);
    expect((aux.value[0] as Variable).name, 'x');
    expect((aux.value[1] as Variable).name, 'y');
    expect((aux.value[2] as Variable).name, 'z');
  });
  
  test('simple math', () async {
    expect(await parser.parse('2.2 + 3').value.eval(env), 5.2);
  });

  test('built-in function', () async {
    expect((await parser.parse('sin(pi/6)').value.eval(env)).toStringAsFixed(3), '0.500');
  });

  test('user-defined function', () async {
    expect(await parser.parse('get(42)').value.eval(env), 42);
    expect(await parser.parse('get((42))').value.eval(env), 42);
    expect(await parser.parse('get(42 + 10)').value.eval(env), 52);
    env['x'] = 5;
    expect(await parser.parse('get(42 + x)').value.eval(env), 47);
  });

  test('user-defined async function', () async {
    expect(await parser.parse('aget(42)').value.eval(env), 42);
    expect(await parser.parse('aget(42) + aget(10)').value.eval(env), 52);
    expect(await parser.parse('aget(42) + get(5)').value.eval(env), 47);
  });

  test('callable with 1 argument', () async {
    expect((await callable.parse('sin(0)').value.eval(env)).toStringAsFixed(3), '0.000');
    expect((await callable.parse('sin(pi/6)').value.eval(env)).toStringAsFixed(3), '0.500');
  });

  test('callable with 2 arguments', () async {
    expect(await callable.parse('sum2(5,7)').value.eval(env), 12);
    env['x'] = 10;
    expect(await callable.parse('sum2(5, x)').value.eval(env), 15);
  });


  // test('functions with 2 arguments', () async {
  //   expect(await parser.parse('sum2(5,7)').value.eval(env), 12);
  // }, solo: true);

  // test('variable.dart definition', () {
  //   expect(parser.parse('input'), matcher)
  // });


}