import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../storage/thingsboard_secure_storage.dart';

class ThingsBoardClientBaseProvider with ChangeNotifier {
  late final ThingsboardClient tbClient;

  Future<bool> init() async {
    var storage = ThingsBoardSecureStorage();
    tbClient = ThingsboardClient(dotenv.env['API_URL'] ?? '', storage: storage);
    await tbClient.init();
    return tbClient.isAuthenticated();
  }
}
