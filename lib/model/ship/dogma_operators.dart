import 'dart:math';
// ignore_for_file: constant_identifier_names

// This is OK - as these will all be refactored in the new package
enum DogmaOperators {
  PreAdd,
  PreMul,
  PreAssignment,
  ModPercent,
  ModAdd,
  ModSub,
  PostPercent,
  PostMul,
  PostAssignment,
}

extension DogmaOperatorsExtenstion on DogmaOperators {
  // Unsure what 'ret' is at this point
  double performOperation({
    required double ret,
    required double value,
  }) {
    switch (this) {
      case DogmaOperators.PreAdd:
        return ret + value;
      case DogmaOperators.PreMul:
        return ret * value;
      case DogmaOperators.PreAssignment:
        return value;
      case DogmaOperators.ModPercent:
        return ret * (1 + value);
      case DogmaOperators.ModAdd:
        return ret + value;
      case DogmaOperators.ModSub:
        return ret - value;
      case DogmaOperators.PostPercent:
        return ret * (1 + value);
      case DogmaOperators.PostMul:
        return ret * value;
      case DogmaOperators.PostAssignment:
        return value;
    }
  }

  double performAggregation({
    bool highIsGood = true,
    required double a,
    required double b,
  }) {
    switch (this) {
      case DogmaOperators.PreAdd:
        return a + b;
      case DogmaOperators.PreMul:
        return a * b;
      case DogmaOperators.PreAssignment:
        return highIsGood ? max(a, b) : min(a, b);
      case DogmaOperators.ModPercent:
        return a + b;
      case DogmaOperators.ModAdd:
        return a + b;
      case DogmaOperators.ModSub:
        return a + b;
      case DogmaOperators.PostPercent:
        return (1 + a) * (1 + b) - 1;
      case DogmaOperators.PostMul:
        return a * b;
      case DogmaOperators.PostAssignment:
        return highIsGood ? max(a, b) : min(a, b);
    }
  }
}
