import 'juice_class.dart';
import 'runtime_error.dart';
import 'token.dart';

class JuiceInstance {
  final JuiceClass _klass;
  final Map<String, Object?> _fields = {};

  JuiceInstance(this._klass);

  Object? get(Token name) {
    if (_fields.containsKey(name.lexeme)) {
      return _fields[name.lexeme];
    }

    var method = _klass.findMethod(name.lexeme);
    if (method != null) return method.bind(this);

    throw RuntimeError(name, "Undefined property '${name.lexeme}'.");
  }

  void set(Token token, Object? value) {
    _fields[token.lexeme] = value;
  }

  @override
  String toString() {
    return '${_klass.name} instance';
  }
}
