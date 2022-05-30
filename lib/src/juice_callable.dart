import 'interpreter.dart';

abstract class JuiceCallable {
  int get arity;

  Object? call(Interpreter interpreter, List<Object?> arguments);

  factory JuiceCallable(int arity,
      Object? Function(Interpreter interpreter, List<Object?> arguments) fn) {
    return _Callable(arity, fn);
  }
}

class _Callable implements JuiceCallable {
  @override
  final int arity;
  final Object? Function(Interpreter interpreter, List<Object?> arguments) fn;

  _Callable(this.arity, this.fn);

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    return fn(interpreter, arguments);
  }

  @override
  String toString() => '<native fn>';
}
