import 'interpreter.dart';
import 'juice_callable.dart';
import 'juice_function.dart';
import 'juice_instance.dart';

class JuiceClass implements JuiceCallable {
  final String name;
  final JuiceClass? superclass;
  final Map<String, JuiceFunction> _methods;

  JuiceClass(this.name, this.superclass, this._methods);

  JuiceFunction? findMethod(String name) {
    if (_methods.containsKey(name)) {
      return _methods[name];
    }

    if (superclass != null) {
      return superclass!.findMethod(name);
    }

    return null;
  }

  @override
  int get arity => findMethod('init')?.arity ?? 0;

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    var instance = JuiceInstance(this);
    var initializer = findMethod('init');
    initializer?.bind(instance).call(interpreter, arguments);
    return instance;
  }

  @override
  String toString() => name;
}
