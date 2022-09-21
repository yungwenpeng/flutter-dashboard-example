// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    // CircularProgressIndicator :
    // for both determinate and indeterminate progresses
    // a material widget which indicates that the application is busy.
    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
          alignment: Alignment.center,
          image: AssetImage('assets/images/welcome_bg.png'),
          fit: BoxFit.fill,
        )),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: CircularProgressIndicator(),
            )));
  }
}
