import 'dart:async';

import 'package:date/date.dart';
import 'package:juice/src/juice_callable_async.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/timezone.dart';
import 'ast.dart';
import 'environment.dart';
import 'juice_callable.dart';
import 'juice_class.dart';
import 'juice_function.dart';
import 'juice_instance.dart';
import 'juice_return.dart';
import 'runtime_error.dart';
import 'token.dart';

class Interpreter implements ExprVisitor<Object?>, StmtVisitor<void> {
  final globals = Environment();
  final locals = <Expr, int>{};
  late Environment _environment;

  late Term domain;

  Interpreter() {
    initializeTimeZones();
    globals.define(
      'get42',
      JuiceCallableAsync(0, (interpreter, arguments) {
        return Future.delayed(Duration(seconds: 5), () => 42);
      }),
    );
    globals.define(
      'clock',
      JuiceCallable(0, (interpreter, arguments) {
        return DateTime.now().millisecondsSinceEpoch / 1000;
      }),
    );
    globals.define(
        'setDomain',
        JuiceCallable(2, (interpreter, arguments) {
          late Location location;
          var tz = arguments[1] as String;
          if (tz == 'UTC') {
            location = UTC;
          } else {
            location = getLocation(tz);
          }
          domain = Term.parse(arguments[0] as String, location);
          globals.assignName('domain', domain);
          return;
        }));
    _environment = globals;
  }

  Future<void> interpret(List<Stmt> statements) async {
    print('Have to evaluate ${statements.length} statements ...');
    for (var statement in statements) {
      await execute(statement);
    }
    print('Done with evaluation.');
  }

  Future<void> execute(Stmt stmt) async {
    stmt.accept(this);
  }

  FutureOr<Object?> evaluate(Expr expr) async {
    var aux = await expr.accept(this);

    return aux;
  }

  void resolve(Expr expr, int depth) {
    locals[expr] = depth;
  }

  void executeBlock(List<Stmt> statements, Environment environment) {
    var previous = _environment;
    try {
      _environment = environment;

      for (var statement in statements) {
        execute(statement);
      }
    } finally {
      _environment = previous;
    }
  }

  @override
  void visitBlockStmt(Block stmt) {
    executeBlock(stmt.statements, Environment(_environment));
  }

  @override
  void visitClassStmt(Class stmt) {
    Object? superclass;
    if (stmt.superclass != null) {
      superclass = evaluate(stmt.superclass!);
      if (superclass is! JuiceClass) {
        throw RuntimeError(
            stmt.superclass!.name, 'Superclass must be a class.');
      }
    }

    _environment.define(stmt.name.lexeme, null);

    if (stmt.superclass != null) {
      _environment = Environment(_environment);
      _environment.define('super', superclass);
    }

    var methods = <String, JuiceFunction>{};
    for (var method in stmt.methods) {
      var function =
          JuiceFunction(method, _environment, method.name.lexeme == 'init');
      methods[method.name.lexeme] = function;
    }

    var klass =
        JuiceClass(stmt.name.lexeme, superclass as JuiceClass?, methods);

    if (superclass != null) {
      _environment = _environment.enclosing!;
    }

    _environment.assign(stmt.name, klass);
  }

  @override
  void visitExpressionStmt(Expression stmt) {
    evaluate(stmt.expression);
  }

  @override
  void visitFunktionStmt(Funktion stmt) {
    var function = JuiceFunction(stmt, _environment, false);
    _environment.define(stmt.name.lexeme, function);
  }

  @override
  void visitIfStmt(If stmt) {
    if (isTruthy(evaluate(stmt.condition))) {
      execute(stmt.thenBranch);
    } else if (stmt.elseBranch != null) {
      execute(stmt.elseBranch!);
    }
    return;
  }

  @override
  void visitPrintStmt(Print stmt) {
    var value = evaluate(stmt.expression);
    print(stringify(value));
  }

  @override
  void visitReturnStmt(Return stmt) {
    var value = stmt.value != null ? evaluate(stmt.value!) : null;
    throw JuiceReturn(value);
  }

  @override
  Future<void> visitVarStmt(Var stmt) async {
    Object? value;
    // if (stmt.initializer != null) {
    // if (stmt.initializer is CallAsync) {
    //   value = await evaluate(stmt.initializer);
    // } else {
    //   value = evaluate(stmt.initializer);
    // }
    // }
    value = await evaluate(stmt.initializer);
    print('From interpreter.dart, visitVarStmt, value = $value');
    _environment.define(stmt.name.lexeme, value);
  }

  @override
  void visitWhileStmt(While stmt) {
    while (isTruthy(evaluate(stmt.condition))) {
      execute(stmt.body);
    }
    return;
  }

  @override
  Object? visitAssignExpr(Assign expr) {
    var value = evaluate(expr.value);

    var distance = locals[expr];
    if (distance != null) {
      _environment.assignAt(distance, expr.name, value);
    } else {
      globals.assign(expr.name, value);
    }
    return value;
  }

  @override
  Object? visitBinaryExpr(Binary expr) {
    var left = evaluate(expr.left);
    var right = evaluate(expr.right);
    switch (expr.operator.type) {
      case GREATER:
        checkNumberOperands(expr.operator, left, right);
        return (left as double) > (right as double);
      case GREATER_EQUAL:
        checkNumberOperands(expr.operator, left, right);
        return (left as double) >= (right as double);
      case LESS:
        checkNumberOperands(expr.operator, left, right);
        return (left as double) < (right as double);
      case LESS_EQUAL:
        checkNumberOperands(expr.operator, left, right);
        return (left as double) <= (right as double);
      case MINUS:
        checkNumberOperands(expr.operator, left, right);
        return (left as double) - (right as double);
      case PLUS:
        if (left is double && right is double) {
          return left + right;
        }
        if (left is String && right is String) {
          return left + right;
        }
        throw RuntimeError(
            expr.operator, 'Operands must be two numbers or two strings.');
      case SLASH:
        checkNumberOperands(expr.operator, left, right);
        return (left as double) / (right as double);
      case STAR:
        checkNumberOperands(expr.operator, left, right);
        return (left as double) * (right as double);
      case BANG_EQUAL:
        return !isEqual(left, right);
      case EQUAL_EQUAL:
        return isEqual(left, right);
      default:
        return null;
    }
  }

  @override
  Object? visitCallExpr(Call expr) {
    var callee = evaluate(expr.callee);
    if (callee is JuiceCallable) {
      var arguments = <Object?>[];
      for (var argument in expr.arguments) {
        arguments.add(evaluate(argument));
      }
      if (arguments.length != callee.arity) {
        throw RuntimeError(
            expr.paren,
            'Expected ${callee.arity} arguments '
            'but got ${arguments.length}.');
      }
      var aux = callee.call(this, arguments);
      return aux;
    }
    throw RuntimeError(expr.paren, 'Can only call functions and classes.');
  }

  @override
  FutureOr<Object?> visitCallAsyncExpr(CallAsync expr) async {
    var callee = await evaluate(expr.callee);
    if (callee is JuiceCallableAsync) {
      var arguments = <Object?>[];
      for (var argument in expr.arguments) {
        arguments.add(evaluate(argument));
      }
      if (arguments.length != callee.arity) {
        throw RuntimeError(
            expr.paren,
            'Expected ${callee.arity} arguments '
            'but got ${arguments.length}.');
      }
      var aux = await callee.call(this, arguments);
      // print(aux);
      return aux;
    }
    throw RuntimeError(expr.paren, 'Can only call functions and classes.');
  }



  @override
  Object? visitGetExpr(Get expr) {
    var object = evaluate(expr.object);
    if (object is JuiceInstance) {
      return object.get(expr.name);
    }

    throw RuntimeError(expr.name, 'Only instances have properties.');
  }

  @override
  Object? visitGroupingExpr(Grouping expr) {
    return evaluate(expr.expression);
  }

  @override
  Object? visitLiteralExpr(Literal expr) {
    return expr.value;
  }

  @override
  Object? visitLogicalExpr(Logical expr) {
    var left = evaluate(expr.left);

    if (expr.operator.type == TokenType.OR) {
      if (isTruthy(left)) return left;
    } else {
      if (!isTruthy(left)) return left;
    }

    return evaluate(expr.right);
  }

  @override
  Object? visitSetExpr(Set expr) {
    var object = evaluate(expr.object);

    if (object is JuiceInstance) {
      var value = evaluate(expr.value);
      object.set(expr.name, value);
      return value;
    }
    throw RuntimeError(expr.name, 'Only instances have fields.');
  }

  @override
  Object? visitSuperExpr(Super expr) {
    var distance = locals[expr]!;
    var superclass = _environment.getAt(distance, 'super') as JuiceClass;

    // "this" is always one level nearer than "super"'s environment.
    var object = _environment.getAt(distance - 1, 'this') as JuiceInstance;

    var method = superclass.findMethod(expr.method.lexeme);

    if (method == null) {
      throw RuntimeError(
          expr.method, "Undefined property '${expr.method.lexeme}'.");
    }

    return method.bind(object);
  }

  @override
  Object? visitThisExpr(This expr) {
    return lookUpVariable(expr.keyword, expr);
  }

  @override
  Object? visitUnaryExpr(Unary expr) {
    var right = evaluate(expr.right);

    switch (expr.operator.type) {
      case BANG:
        return !isTruthy(right);
      case MINUS:
        return -checkNumberOperand(expr.operator, right);
      default:
        return null;
    }
  }

  @override
  Object? visitVariableExpr(Variable expr) {
    return lookUpVariable(expr.name, expr);
  }

  Object? lookUpVariable(Token name, Expr expr) {
    var distance = locals[expr];
    if (distance != null) {
      return _environment.getAt(distance, name.lexeme);
    } else {
      return globals.get(name);
    }
  }

  double checkNumberOperand(Token operator, Object? operand) {
    if (operand is double) return operand;
    throw RuntimeError(operator, 'Operand must be a number.');
  }

  void checkNumberOperands(Token operator, Object? left, Object? right) {
    if (left is double && right is double) return;

    throw RuntimeError(operator, 'Operands must be numbers.');
  }

  bool isTruthy(Object? object) {
    if (object == null) return false;
    if (object is bool) return object;
    return true;
  }

  bool isEqual(Object? a, Object? b) => a == b;

  String stringify(Object? object) {
    if (object == null) return 'nil';

    // Hack. Work around Dart adding ".0" to integer-valued doubles.
    if (object is double) {
      var text = object.toString();
      if (text.endsWith('.0')) {
        text = text.substring(0, text.length - 2);
      }
      return text;
    }

    return object.toString();
  }
}
