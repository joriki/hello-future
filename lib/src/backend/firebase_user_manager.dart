import 'package:firebase_auth/firebase_auth.dart';
import 'package:hello_future/src/backend/error_codes.dart';
import 'package:hello_future/src/backend/user_manager.dart';

class FirebaseUserManager extends UserManagerImplementation<FirebaseUser> {
  static const _invalidEmail      = "ERROR_INVALID_EMAIL";
  static const _wrongPassword     = "ERROR_WRONG_PASSWORD";
  static const _emailAlreadyInUse = "ERROR_EMAIL_ALREADY_IN_USE";
  static const _userNotFound      = "ERROR_USER_NOT_FOUND";
  static const _tooManyRequests   = "ERROR_TOO_MANY_REQUESTS";

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize () => Future.value();

  Future<FirebaseUser> signUp (email,password) => mapErrors(_auth.createUserWithEmailAndPassword (email: email, password: password),{
    _invalidEmail  : wrongEmailFormat,
    _emailAlreadyInUse : emailInUse,
  });
  Future<FirebaseUser> logIn (email,password) => mapErrors (_auth.signInWithEmailAndPassword (email: email,password: password),{
    _invalidEmail  : wrongEmailFormat,
    // we discard the information whether the username or the password was wrong
    _wrongPassword : invalidLoginOrPassword,
    _userNotFound  : invalidLoginOrPassword,
  });
  Future<FirebaseUser> resendVerificationEmail (email,password) => logIn(email,password).then((user) {
    user.sendEmailVerification();
    return user;
  });

  Future<void> resetPassword (email) =>  mapErrors(_auth.sendPasswordResetEmail(email: email),{
    _invalidEmail  : wrongEmailFormat,
  });
}
