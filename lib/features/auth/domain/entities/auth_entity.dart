import 'package:equatable/equatable.dart';
import 'user_entity.dart';

class AuthEntity extends Equatable {
  final String token;
  final UserEntity user;
  final String id;
  final bool hasAccess;

  const AuthEntity({
    required this.token,
    required this.user,
    required this.id,
    this.hasAccess = true,
  });

  @override
  List<Object?> get props => [token, user, id, hasAccess];
}
