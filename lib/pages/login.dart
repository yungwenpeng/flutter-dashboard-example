// ignore_for_file: prefer_const_constructors, unused_field, unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  bool _autovalidate = false;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isHidden = true;

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    usernameController.addListener(onUsernameValueChange);
    passwordController.addListener(onPasswordValueChange);
  }

  void onUsernameValueChange() {
    setState(() {
      usernameController.text;
    });
  }

  void onPasswordValueChange() {
    setState(() {
      passwordController.text;
    });
  }

  void showInSnackBar(String value) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(value, textAlign: TextAlign.center),
        duration: Duration(milliseconds: 2000),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _loginSubmitted() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      _autovalidate = true; // Start validating on every change.
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      if (passwordController.text == "password") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("username", usernameController.text);
        // ignore: use_build_context_synchronously
        Navigator.pushNamedAndRemoveUntil(
            context, '/home', ModalRoute.withName('/home'));
      } else {
        showInSnackBar('Incorrect credentials');
      }
    }
  }

  void _toggleVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        alignment: Alignment.center,
        image: AssetImage('assets/images/welcome_bg.png'),
        fit: BoxFit.fill,
      )),
      child: Scaffold(
        key: _scaffoldMessengerKey,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Login"),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 0,
              color: Color.fromARGB(195, 255, 255, 255),
              margin: const EdgeInsets.fromLTRB(20, 60, 20, 20), // L,T,R,B
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white70, width: 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Welcome to Demo Homepage!',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    buildTextField('Username'),
                    SizedBox(
                      height: 20.0,
                    ),
                    buildTextField('Password'),
                    SizedBox(height: 10.0),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        // Foreground color
                        onPrimary: Theme.of(context).colorScheme.onPrimary,
                        // Background color
                        primary: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        minimumSize: const Size.fromHeight(50),
                        //fixedSize: const Size(300, 100),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                      onPressed: () {
                        _loginSubmitted(); // Respond to button press
                      },
                      icon: Icon(Icons.login, size: 20),
                      label: Text("Login"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hintText) {
    return TextFormField(
      style: const TextStyle(
          color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      autofocus: true,
      controller:
          hintText == "Password" ? passwordController : usernameController,
      decoration: InputDecoration(
        hintText: 'Enter $hintText',
        hintStyle: TextStyle(color: Colors.blueGrey[400]),
        prefixIcon:
            hintText == "Password" ? Icon(Icons.lock) : Icon(Icons.account_box),
        labelText: hintText,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 22,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.indigoAccent, width: 3.0),
          borderRadius: BorderRadius.circular(20.0),
        ),
        suffixIcon: hintText == "Password"
            ? IconButton(
                onPressed: _toggleVisibility,
                icon: _isHidden
                    ? Icon(Icons.visibility_off)
                    : Icon(Icons.visibility),
              )
            : null,
        counterText: hintText == "Password"
            ? '${passwordController.text.length.toString()} character(s)'
            : '${usernameController.text.length.toString()} character(s)',
      ),
      obscureText: hintText == "Password" ? _isHidden : false,
      validator: (String? value) {
        if (value != null && value.isEmpty) {
          return hintText == "Password"
              ? 'Password is required'
              : 'Username is required';
        } else if (value != null &&
            hintText == "Password" &&
            value.length < 8) {
          return 'Minimum character length is 8';
        } else if (value != null &&
            hintText == "Username" &&
            !value.contains("@")) {
          return 'Username need @ character';
        } else {
          return null;
        }
      },
      inputFormatters: [
        FilteringTextInputFormatter.deny("\n"),
      ],
    );
  }
}
