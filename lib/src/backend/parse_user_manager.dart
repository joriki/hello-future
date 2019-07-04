import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:hello_future/src/backend/error_codes.dart';
import 'package:hello_future/src/backend/user_manager.dart';
import 'package:flutter/services.dart';

class ParseUserManager extends UserManagerImplementation<ParseUser> {
  static const keyApplicationId = "x2XdVYT3lsW6lqBofmePL9TNI5Yg4z1sAXzmd2Cf";
  static const keyParseServerUrl = "https://parseapi.back4app.com";
  static const masterKey = "o0hiEDiZ6TbN056hLIFIFWc6FApgHf5FiMVeTGBJ";

  static const _unknownError        = "-1";
  static const _objectNotFound      = "101";
  static const _invalidEmailAddress = "125";
  static const _usernameTaken       = "202";
  static const _emailNotFound       = "205";

  Future<void> initialize () => Parse ().initialize (keyApplicationId,keyParseServerUrl,masterKey: masterKey,debug:true);

  Future<ParseUser> apply (Future<ParseResponse> responder (ParseUser user),String email,String password) {
    ParseUser user = ParseUser(email,password,email); // use email as username
    return mapErrors (responder (user).then((response) {
      return response.success ? user : Future<ParseUser>.error(PlatformException(code: response.error.code.toString(),message: response.error.message));
    }),{
      _objectNotFound      : invalidLoginOrPassword,
      _emailNotFound       : unknownEmailAddress,
      _invalidEmailAddress : wrongEmailFormat,
      _usernameTaken       : emailInUse,
    });
  }

  Future<ParseUser> signUp (email,password) => apply ((user) => user.signUp (),email,password);
  Future<ParseUser> logIn (email,password) => apply ((user) => user.login (),email,password).then((user) =>
    user.emailVerified ? user : Future<ParseUser>.error(PlatformException(code: emailNotVerified)));
  Future<ParseUser> resetPassword (email) => apply ((user) => user.requestPasswordReset(),email,null);
  Future<ParseUser> resendVerificationEmail (email,password) => apply ((user) => user.verificationEmailRequest(),email,password).catchError((error) {
    throw error is PlatformException && error.code == _unknownError && error.message == "Email $email is already verified." ?
    PlatformException(code: emailAlreadyVerified) : error;
  });
}