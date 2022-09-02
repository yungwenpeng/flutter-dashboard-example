// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/thingsboard_client_base_provider.dart';

class Landing extends StatefulWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  // initState : check if a user is already logged in or not
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  _loadUserInfo() async {
    final tbClientBaseProvider =
        Provider.of<ThingsBoardClientBaseProvider>(context, listen: false);
    tbClientBaseProvider.init().then((isAuthenticated) {
      if (isAuthenticated) {
        // Don't want to give the user the ability to navigate back to the landing
        // screen from either login or home screen.
        Navigator.pushNamedAndRemoveUntil(
            context, '/home', ModalRoute.withName('/home'));
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', ModalRoute.withName('/login'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // CircularProgressIndicator :
    // for both determinate and indeterminate progresses
    // a material widget which indicates that the application is busy.
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
