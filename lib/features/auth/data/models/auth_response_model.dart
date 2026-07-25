class AuthResponseModel {
  final String? message;
  final int? status;
  final dynamic data;

  AuthResponseModel({this.message, this.status, this.data});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      message: json['message'],
      status: json['status'],
      data: json['data'],
    );
  }
}
