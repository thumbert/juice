import 'runtime_error.dart';
import 'token.dart';

class Environment {
  final Environment? enclosing;
  final _values = <String, Object?>{};

  Environment([this.enclosing]);

  Object? get(Token name) {
    if (_values.containsKey(name.lexeme)) {
      return _values[name.lexeme];
    }

    if (enclosing != null) return enclosing!.get(name);

    throw RuntimeError(name, "Undefined variable '${name.lexeme}'.");
  }

  /// Used only for internal debugging -- AAD
  Object? getName(String name) {
    if (_values.containsKey(name)) {
      return _values[name];
    }

    if (enclosing != null) return enclosing!.getName(name);

    throw ArgumentError("Undefined variable '$name'.");
  }

  void assign(Token name, Object? value) {
    if (_values.containsKey(name.lexeme)) {
      _values[name.lexeme] = value;
      return;
    }

    if (enclosing != null) {
      enclosing!.assign(name, value);
      return;
    }

    throw RuntimeError(name, "Undefined variable '${name.lexeme}'.");
  }

  /// backdoor assign
  void assignName(String name, Object? value) {
    _values[name] = value;
    return;
  }

  void define(String name, Object? value) {
    _values[name] = value;
  }

  Environment _ancestor(int distance) {
    var environment = this;
    for (var i = 0; i < distance; i++) {
      environment = environment.enclosing!;
    }

    return environment;
  }

  Object? getAt(int distance, String name) {
    return _ancestor(distance)._values[name];
  }

  void assignAt(int distance, Token name, Object? value) {
    _ancestor(distance)._values[name.lexeme] = value;
  }
}
