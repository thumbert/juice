import 'expression.dart';


/// A value expression.
class Value extends Expression {
  Value(this.value);

  final num value;

  @override
  Future<num> eval(Map<String, num> variables) => Future.value(value);

  @override
  String toString() => 'Value{$value}';
}