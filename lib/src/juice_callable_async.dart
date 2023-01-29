import 'interpreter.dart';

abstract class JuiceCallableAsync {
  int get arity;

  Future<Object?> call(Interpreter interpreter, List<Object?> arguments);

  factory JuiceCallableAsync(int arity,
      Future<Object?> Function(Interpreter interpreter, List<Object?> arguments) fn) {
    return _CallableAsync(arity, fn);
  }
}

class _CallableAsync implements JuiceCallableAsync {
  @override
  final int arity;
  final Future<Object?> Function(Interpreter interpreter, List<Object?> arguments) fn;

  _CallableAsync(this.arity, this.fn);

  @override
  Future<Object?> call(Interpreter interpreter, List<Object?> arguments) async {
    return await fn(interpreter, arguments);
  }

  @override
  String toString() => '<native async fn>';
}
