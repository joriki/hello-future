import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:hello_future/src/backend/error_codes.dart';
import 'package:hello_future/src/backend/user_manager.dart';

class BackendlessUserManager extends UserManagerImplementation<BackendlessUser> {
  static const applicationId = "42ABE361-52F0-8910-FFCF-A1E5F0C8A400";
  static const androidApiKey = "0D632CB3-79F6-3257-FF4D-9E003AD35200";
  static const iosApiKey     = "30061CC6-F3AE-AB22-FFFA-52E47700F000";

  // https://backendless.com/docs/rest/backendless_error_codes.html
  static const _invalidLoginOrPassword   = "3003";
  static const _unknownIdentity          = "3020";
  static const _userExists               = "3033";
  static const _wrongEmailFormat         = "3040";
  static const _missingEmailVerification = "3087";
  static const _emailAlreadyConfirmed    = "3102";
  static const _unknownEmailAddress      = "3104";

  Future<void> initialize () => Backendless.initApp (applicationId,androidApiKey,iosApiKey);

  Future<BackendlessUser> signUp (String email,String password) =>
    mapErrors (Backendless.userService.register (BackendlessUser ()..email = email..password = password),{
      _userExists       : emailInUse,
      _wrongEmailFormat : wrongEmailFormat,
    });

  Future<BackendlessUser> logIn (String email,String password) =>
    mapErrors (Backendless.userService.login (email, password),{
      _missingEmailVerification : emailNotVerified,
      _invalidLoginOrPassword  : invalidLoginOrPassword,
    });

  Future<void> resendVerificationEmail (String email,String password) =>
    mapErrors (Backendless.userService.resendEmailConfirmation (email),{
      _emailAlreadyConfirmed : emailAlreadyVerified,
      _unknownEmailAddress   : unknownEmailAddress,
    });

  Future<void> resetPassword (String email) =>
    mapErrors(Backendless.userService.restorePassword(email),{
      _unknownIdentity : unknownEmailAddress,
    });
}
