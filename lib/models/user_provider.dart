import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import '../models/models.dart';

class UserBaseProvider with ChangeNotifier {
  late final UserBaseController userBaseController;
  late final UserApiController userApiController;

  Future<bool> init() async {
    var dioClient = DioClientController();
    userBaseController = UserBaseController(dioClient: dioClient);
    userApiController = UserApiController(dioClient: dioClient);
    await userBaseController.init();
    return userBaseController.isAuthenticated();
  }

  Future<List<Users>> getAllUsers() async {
    return userApiController.getAllUsers();
  }

  Future<Users?> getUser(String email) async {
    return userApiController.getUser(email);
  }
}
