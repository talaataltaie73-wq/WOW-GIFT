import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Simple Either type for use case results
class Either<L, R> {
  final L? _left;
  final R? _right;
  final bool _isRight;

  const Either._(this._left, this._right, this._isRight);

  factory Either.left(L value) => Either._(value, null, false);
  factory Either.right(R value) => Either._(null, value, true);

  bool get isLeft => !_isRight;
  bool get isRight => _isRight;

  L get left => _left as L;
  R get right => _right as R;

  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    if (_isRight) {
      return onRight(_right as R);
    } else {
      return onLeft(_left as L);
    }
  }

  Either<L, T> map<T>(T Function(R) f) {
    if (_isRight) {
      return Either.right(f(_right as R));
    }
    return Either.left(_left as L);
  }
}
