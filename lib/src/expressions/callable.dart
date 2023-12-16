library src.expressions.callable;

import 'package:juice/src/args/args.dart';
import 'package:juice/src/expressions/common.dart';
import 'package:juice/src/expressions/expression.dart';
import 'package:juice/src/expressions/unary.dart';
import 'package:petitparser/petitparser.dart';


final callable = seq4(word().plus().flatten('function expected').trim(),
    char('(').trim(), argList, char(')').trim())
    .map((value) => _createFunctionN(value.$1, value.$3));

Expression _createFunctionN(String name, List<Expression> args) {
  if (args.length == 1) {
    if (!functions1.containsKey(name)) {
      throw 'Can\'t find function $name among list of functions with one argument.';
    }
    return Unary(name, args.first, functions1[name]!);

    ///
    ///
    ///
  // } else if (args.length == 2) {
  //   // return switch (name) {
  //   //   'max' => BinaryMax(args[0], args[1]),
  //   //   'min' => BinaryMin(args[0], args[1]),
  //   //   'toMonthly' =>
  //   //       ToMonthly(args[0], args[1].toString().replaceFirst('Variable ', '')),
  //   //   _ => throw StateError('Wah-wah-wah...  Function $name is not supported.'),
  //   // };
  //
  //   ///
  //   ///
  //   ///
  // } else if (args.length == 3) {
  //   // return switch (name) {
  //   //   'toMonthly' => ToMonthly3(
  //   //       args[0],
  //   //       args[1].toString().replaceFirst('Variable ', ''),
  //   //       args[2].toString().replaceFirst('Variable ', '')),
  //   //   _ => throw StateError('Wah-wah-wah...  Function $name is not supported.'),
  //   // };
  //
  //   ///
  //   ///
  //   ///
  } else {
    throw 'Arity ${args.length} not yet supported!';
  }
}
