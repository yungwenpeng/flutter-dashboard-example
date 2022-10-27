import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';

import '../models/users.dart';
import 'dio_base.dart';

class UserApiController {
  final DioClientController dioClient;

  UserApiController({required this.dioClient});

  Future<List<Users>> getAllUsers() async {
    try {
      final Response response = await dioClient.get('/api/users?query=all');
      final jsonStr = json.encode(response.data);
      final result = usersFromJson(jsonStr);
      //print('UserApiController - getAllUsers: $result');
      return result;
    } on DioError catch (e) {
      if (e.response != null) {
        print('getAllUsers Dio Error!\nSTATUS:${e.response?.statusCode}');
        print('DATA: ${e.response?.data}\nHEADERS: ${e.response?.headers}');
      } else {
        // Error due to setting up or sending the request
        print('getAllUsers Error sending request!');
        print(e.message);
      }
    }
    return [];
  }

  Future<Users?> getUser(String email) async {
    try {
      final response = await dioClient.get('/api/users?query=all');
      final jsonStr = json.encode(response.data);
      final result = usersFromJson(jsonStr);
      //print('UserApiController - getUser result: $result');
      for (var user in result) {
        if (user.email == email) {
          print('UserApiController - getUser: $user');
          return user;
        }
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('getUser Dio Error!\nSTATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}\nHEADERS: ${e.response?.headers}');
      } else {
        // Error due to setting up or sending the request
        print('getUser Error sending request!');
        print(e.message);
      }
    }
    return null;
  }

  Future<Users?> createUser(
      String name, String email, String password, String role) async {
    Users? retrievedUser;
    try {
      final response = await dioClient.post('/api/users/signup', data: {
        "userName": name,
        "email": email,
        "password": password,
        "role": role
      });
      retrievedUser = Users.fromJson(response.data);
      //print('createNewUser retrievedUser: $retrievedUser');
      return retrievedUser;
    } on DioError catch (e) {
      if (e.response != null) {
        print('createNewUser Dio Error!\nSTATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}\nHEADERS: ${e.response?.headers}');
      } else {
        // Error due to setting up or sending the request
        print('createNewUser Error sending request!');
        print(e.message);
      }
    }
    return null;
  }

  Future<Users?> updateUser(String oldEmail, String name, String email,
      String password, String role) async {
    Users? updateUser;
    try {
      final response = await dioClient.put('/api/users/$oldEmail', data: {
        "userName": name,
        "email": email,
        "password": password,
        "role": role
      });
      updateUser = Users.fromJson(response.data);
      print('updateUser updateUser: $updateUser');
      return updateUser;
    } on DioError catch (e) {
      if (e.response != null) {
        print('updateUser Dio Error!\nSTATUS: ${e.response?.statusCode}');
        print('DATA: ${e.response?.data}\nHEADERS: ${e.response?.headers}');
      } else {
        // Error due to setting up or sending the request
        print('updateUser Error sending request!');
        print(e.message);
      }
    }
    return null;
  }

  Future<void> deleteUser(String email) async {
    try {
      final response = await dioClient.delete('/api/users/$email');
      print('User $email deleted!');
      inspect(response);
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}
