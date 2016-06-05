library evaluation_example;

import 'package:dartz/dartz.dart';
import 'minilanguage.dart';

main() async {
  final env = new IMap<String, Value>.empty();

  final fib = lambda("fib", lambda("n",
      conditional(plus(variable("n"), literal(-1)),
          plus(apply(apply(variable("fib"), variable("fib")), plus(variable("n"), literal(-1))),
              apply(apply(variable("fib"), variable("fib")), plus(variable("n"), literal(-2)))),
          variable("n"))));

  final exp = apply(apply(fib, fib), literal(10));

  final evaluated = evaluate(exp);

  final result = await evaluated.run(env, 0);
  result.fold((error) {
    print("Failed... error is: $error");
  }, (values) {
    print("fib(10) evaluated to ${values.value3}");
    print("${values.value2} operations were performed");
    print("Variables resolved: ${values.value1.intercalate(StringMi, ", ")}");
  });
}