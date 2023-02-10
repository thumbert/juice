library ast.expression;

/// An abstract expression that can be evaluated.
abstract class Expression {
  /// Evaluates the expression with the provided [variables].
  Future<num> eval(Map<String, num> variables);
}

