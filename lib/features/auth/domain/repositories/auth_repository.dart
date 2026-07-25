import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthEntity>> getCurrentUser();

  Future<Either<Failure, bool>> logout();

  Future<Either<Failure, bool>> saveUserData(AuthEntity authEntity);
}
