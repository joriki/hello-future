import 'package:flutter/services.dart';

abstract class UserManagerImplementation<T> {
  Future<void> initialize ();
  Future<void> signUp (String email, String password);
  Future<void> logIn (String email, String password);
  Future<void> resendVerificationEmail (String email, String password);
  Future<void> resetPassword (String email);
  Future<S> mapErrors<S> (Future<S> future,Map<String,String> errorMap) {
    return future.catchError ((error) {
      return Future<S>.error(
          error is PlatformException && errorMap.containsKey (error.code) ?
          PlatformException (code: errorMap [error.code]) : error);
    });
  }
}

class UserManager {
  UserManagerImplementation _implementation;

  UserManager (this._implementation);

  Future<void> initialize () => _implementation.initialize();

  Future<void> signUp (String email, String password) => _implementation.signUp (email,password);
  Future<void> logIn (String email, String password) => _implementation.logIn (email,password);
  Future<void> resendVerificationEmail (String email, String password) => _implementation.resendVerificationEmail (email,password);
  Future<void> resetPassword (String email) => _implementation.resetPassword (email);
}
