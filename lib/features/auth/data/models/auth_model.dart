import '../../domain/entities/auth_entity.dart';
import 'user_model.dart';

class AuthModel extends AuthEntity {
  const AuthModel({
    required super.token,
    required super.user,
    required super.id,
    super.hasAccess,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'] ?? '',
      id: json['id']?.toString() ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
      hasAccess: json['hasAccess'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'id': id,
      'user': (user as UserModel).toJson(),
      'hasAccess': hasAccess,
    };
  }

  AuthEntity toEntity() {
    return AuthEntity(token: token, user: user, id: id, hasAccess: hasAccess);
  }

  factory AuthModel.fromEntity(AuthEntity entity) {
    return AuthModel(
      token: entity.token,
      user: entity.user,
      id: entity.id,
      hasAccess: entity.hasAccess,
    );
  }
}
