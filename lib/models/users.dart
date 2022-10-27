// Transfer JSON to Dart file, please try online tool: https://app.quicktype.io/
// https://pub.dev/packages/json_annotation

import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'users.g.dart';

List<Users> usersFromJson(String str) =>
    List<Users>.from(json.decode(str).map((x) => Users.fromJson(x)));

String usersToJson(List<Users> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@JsonSerializable()
class Users {
  Users({
    required this.id,
    required this.userName,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String userName;
  String email;
  String role;
  DateTime createdAt;
  DateTime updatedAt;

  factory Users.fromJson(Map<String, dynamic> json) => _$UsersFromJson(json);

  Map<String, dynamic> toJson() => _$UsersToJson(this);

  @override
  String toString() {
    return '{id: $id, userName: $userName, email: $email, role: $role, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
