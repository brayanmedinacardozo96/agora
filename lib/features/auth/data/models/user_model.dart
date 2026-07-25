import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({required super.name, required super.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(name: json['name'] ?? '', email: json['email'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email};
  }

  UserEntity toEntity() {
    return UserEntity(name: name, email: email);
  }
}
