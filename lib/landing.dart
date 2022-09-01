// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
// https://pub.dev/packages/shared_preferences
// The package shared_preferences is being used here to access the persistent store for simple data.
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Landing extends StatefulWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  //late SharedPreferences _logindprefs;
  final storage = FlutterSecureStorage();
  String? _username;

  // initState : check if a user is already logged in or not
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  _loadUserInfo() async {
    //_logindprefs = await SharedPreferences.getInstance();
    //_username = (_logindprefs.getString('username') ?? "");
    _username = await storage.read(key: "username");
    // Don't want to give the user the ability to navigate back to the landing
    // screen from either login or home screen.
    if (_username == null || _username == '') {
      Navigator.pushNamedAndRemoveUntil(
          context, '/login', ModalRoute.withName('/login'));
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, '/home', ModalRoute.withName('/home'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // CircularProgressIndicator :
    // for both determinate and indeterminate progresses
    // a material widget which indicates that the application is busy.
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
