import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../controllers/controllers.dart';

class Login extends StatefulWidget {
  final VoidCallback onLogin;
  const Login({Key? key, required this.onLogin}) : super(key: key);

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
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value,
          textAlign: TextAlign.center,
        ),
        duration: const Duration(milliseconds: 2000),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _loginSubmitted() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      var userBaseProvider =
          Provider.of<UserBaseProvider>(context, listen: false);
      var userController = userBaseProvider.userBaseController;
      try {
        await userController.login(
            LoginRequest(usernameController.text, passwordController.text));
        widget.onLogin();
      } catch (e, s) {
        print('Error: $e');
        print('Stack: $s');
        showInSnackBar('Invalid username or password');
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
      decoration: const BoxDecoration(
          image: DecorationImage(
        alignment: Alignment.center,
        image: AssetImage('assets/images/welcome_bg.png'),
        fit: BoxFit.fill,
      )),
      child: Scaffold(
        key: _scaffoldMessengerKey,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          title: Text(AppLocalizations.of(context)!.loginAppBarTitle),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 0,
              color: const Color.fromARGB(195, 255, 255, 255),
              margin: const EdgeInsets.fromLTRB(20, 60, 20, 20), // L,T,R,B
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.white70, width: 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context)!.welcomeHomePage,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    buildTextField('Username(email)'),
                    const SizedBox(height: 20.0),
                    buildTextField('Password'),
                    const SizedBox(height: 10.0),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        // Foreground color
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Colors.blueAccent,
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
                      icon: const Icon(Icons.login, size: 20),
                      label:
                          Text(AppLocalizations.of(context)!.loginAppBarTitle),
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
        prefixIcon: hintText == "Password"
            ? const Icon(Icons.lock)
            : const Icon(Icons.account_box),
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
                    ? const Icon(Icons.visibility_off)
                    : const Icon(Icons.visibility),
              )
            : null,
        counterText: hintText == "Password"
            ? '${passwordController.text.length.toString()} character(s)'
            : null,
      ),
      obscureText: hintText == "Password" ? _isHidden : false,
      validator: (String? value) {
        if (value != null && value.isEmpty) {
          return hintText == "Password"
              ? 'Password is required'
              : 'Username is required';
        } else if (value != null &&
            hintText == "Password" &&
            value.length < 6) {
          return 'Minimum character length is 6';
        } else if (value != null &&
            hintText == "Username(email)" &&
            !(value.contains("@"))) {
          return 'Username(email) need @ character';
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
