import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:flutter_test/flutter_test.dart';
//import 'package:dio/dio.dart';
//import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  /*late Dio dio;
  late DioAdapter dioAdapter;
  Response<dynamic> response;

  group('RestApi Tests', () {
    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dioAdapter = DioAdapter(
        dio: dio,
        matcher: const FullHttpRequestMatcher(),
      );
    });
    tearDown(() {
      dioAdapter.close();
      dio.close(force: true);
    });
    test('Testing getUser', () async {
      const route = '/api/users?query=user1@test.com';
      const userInformation = <String, dynamic>{
        "userName": "user1",
        "email": "user1@test.com",
        "role": "user"
      };

      dioAdapter.onGet(route, (server) {
        server.reply(200, userInformation);
      });
      response = await dio.get(route);
      print(response.data);
      expect(response.statusCode, 200);
      expect(response.data, userInformation);
    });
  });*/

  late String apiUrl;
  late String userName;

  group('RestAPI Test: ', () {
    setUpAll(() {
      HttpOverrides.global = null;
      apiUrl = 'http://localhost:3000';
      userName = 'test@test.com';
    });

    test('Testing signup', () async {
      var userInformation = <String, dynamic>{
        "userName": "test",
        "email": userName,
        "password": "string",
        "role": "user"
      };
      var client = Client();
      await client.delete(Uri.parse('$apiUrl/api/users/$userName'));
      var response = await client.post(
        Uri.parse('$apiUrl/api/users/signup'),
        body: userInformation,
      );
      client.close();
      final extractedData = json.decode(response.body);
      expect(response.statusCode, 200);
      expect(extractedData['email'], userName);
      await Future.delayed(const Duration(seconds: 2));
    });

    test('Testing getUser', () async {
      var client = Client();
      var response =
          await client.get(Uri.parse('$apiUrl/api/users?query=$userName'));
      client.close();
      final extractedData = json.decode(response.body);
      expect(response.statusCode, 200);
      expect(extractedData['email'], userName);
      await Future.delayed(const Duration(seconds: 5));
    });

    test('Testing delete user', () async {
      var client = Client();
      var response =
          await client.delete(Uri.parse('$apiUrl/api/users/$userName'));
      client.close();
      expect(response.statusCode, 200);
      expect(response.body, 'OK');
      await Future.delayed(const Duration(seconds: 1));
    });
  });
}
