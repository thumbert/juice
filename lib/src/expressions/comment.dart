library src.expressions.comment;

import 'package:petitparser/petitparser.dart';
import 'expression.dart';

Parser<List> singleLineComment() =>
    string('//').trim() & ref0(any).star() & ref0(newline).optional();

final comment1 = (string('//').trim() & any().star() & newline().optional())
    .map((value) => CommentExpression());


class CommentExpression extends Expression {
  @override
  void eval(Map<String, dynamic> variables) {}

  @override
  String toString() => 'Comment';
}



