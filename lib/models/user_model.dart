// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ModelClass {
  String? userName;
  String? email;
  String? password;
  String? userId;
  ModelClass({
    this.userName,
    this.email,
    this.password,
    this.userId,
  });

  ModelClass copyWith({
    String? userName,
    String? email,
    String? password,
    String? userId,
  }) {
    return ModelClass(
      userName: userName ?? this.userName,
      email: email ?? this.email,
      password: password ?? this.password,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userName': userName,
      'email': email,
      'password': password,
      'userId': userId,
    };
  }

  factory ModelClass.fromMap(Map<String, dynamic> map) {
    return ModelClass(
      userName: map['userName'] != null ? map['userName'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      userId: map['userId'] != null ? map['userId'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ModelClass.fromJson(String source) =>
      ModelClass.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ModelClass(userName: $userName, email: $email, password: $password, userId: $userId)';
  }

  @override
  bool operator ==(covariant ModelClass other) {
    if (identical(this, other)) return true;

    return other.userName == userName &&
        other.email == email &&
        other.password == password &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return userName.hashCode ^
        email.hashCode ^
        password.hashCode ^
        userId.hashCode;
  }
}
