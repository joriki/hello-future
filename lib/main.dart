import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hello_future/src/backend/error_codes.dart';
import 'package:hello_future/src/backend/user_manager.dart';
import 'package:hello_future/src/backend/firebase_user_manager.dart';
import 'package:hello_future/src/backend/parse_user_manager.dart';
import 'package:hello_future/src/backend/backendless_user_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'The Future of Democracy'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum BackendType {firebase, back4app, backendless}

class Dialog {
  String title;
  String message;
  String button;

  Dialog (this.title, this.message, [this.button = "OK"]);
}

class _MyHomePageState extends State<MyHomePage> {
  UserManager _userManager;
  Future<void> _userManagerInitialized;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final Map<String,Dialog> errorDialogs = {
    emailNotVerified       : Dialog ("Verification pending","Please verify your email address before logging in."),
    invalidLoginOrPassword : Dialog ("Invalid login or password","The address and password you entered don't form a valid login."),
    wrongEmailFormat       : Dialog ("Invalid address","Please enter a valid email address."),
    emailInUse             : Dialog ("User exists","There is already an account for this email address."),
    emailAlreadyVerified   : Dialog ("Already verified","This email address has already been verified; no new verification email has been sent."),
    unknownEmailAddress    : Dialog ("Unknown email address","No account is registered under this email address."),
  };

  void act<S> (Future<S> future (x),Dialog successDialog) {
    _userManagerInitialized.then(future).then ((user) {_showDialog (successDialog);}).catchError ((error) {
      if (error is PlatformException && errorDialogs.containsKey (error.code))
        _showDialog(errorDialogs [error.code]);
      else
        Future.error(error);
    });
  }

  void _logIn() {
    act ((x) => _userManager.logIn (_emailController.text,_passwordController.text),
      Dialog("Login successful","You have successfully logged in to the future of democracy."));
    }

  void _signUp() {
    act ((x) => _userManager.signUp (_emailController.text,_passwordController.text),
        Dialog("Signup complete","You have successfully signed up for the future of democracy."));
  }

  void _resendEmail() {
    act ((x) => _userManager.resendVerificationEmail (_emailController.text,_passwordController.text),
        Dialog("Verification email sent","A verification email has been sent to " + _emailController.text));
  }

  void _resetPassword() {
    act ((x) => _userManager.resetPassword(_emailController.text),
        Dialog("Password reset requested","A password reset email has been sent to " + _emailController.text));
  }

  bool _obscurePassword = true;

  void _togglePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  BackendType _backend;
  void _setBackend(BackendType backend) {
    setState (() {
      _backend = backend;
      _userManager = UserManager(() {
        switch (_backend) {
          case BackendType.firebase:    return FirebaseUserManager();
          case BackendType.back4app:    return ParseUserManager();
          case BackendType.backendless: return BackendlessUserManager();
        }
      } ());
      _userManagerInitialized = _userManager.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Radio(
                  value: BackendType.firebase,
                  groupValue: _backend,
                  onChanged: _setBackend,
                ),
                new Text(
                  'Firebase',
                  style: new TextStyle(fontSize: 14),
                ),
                new Radio(
                  value: BackendType.back4app,
                  groupValue: _backend,
                  onChanged: _setBackend,
                ),
                new Text(
                  'Back4App',
                  style: new TextStyle(fontSize: 14),
                ),
                new Radio(
                  value: BackendType.backendless,
                  groupValue: _backend,
                  onChanged: _setBackend,
                ),
                new Text(
                  'Backendless',
                  style: new TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.all(3),
              child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'email',
              ),
              controller: _emailController,
            )),
            Padding(
              padding: EdgeInsets.all(3),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'password',
                ),
                controller: _passwordController,
                obscureText: _obscurePassword,
              ),
            ),
            IconButton(icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: _togglePassword,
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 1, child: Column()),
                Expanded (
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      new RaisedButton(
                          onPressed: _userManager == null ? null : _logIn,
                          child: Text("log in")
                      ),
                      SizedBox (height: 30),
                      new RaisedButton(
                          onPressed: _userManager == null ? null : _signUp,
                          child: Text("sign up")
                      ),
                    ],
                  ),
                ),
                Expanded(flex: 1, child: Column()),
                Expanded (
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      new RaisedButton(
                          onPressed: _userManager == null ? null : _resendEmail,
                          child: Text("resend email")
                      ),
                      SizedBox (height: 30),
                      new RaisedButton(
                          onPressed: _userManager == null ? null : _resetPassword,
                          child: Text("reset password")
                      ),
                    ],
                  ),
                ),
                Expanded(flex: 1, child: Column()),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _showDialog(Dialog dialog) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(dialog.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(dialog.message),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(dialog.button),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
