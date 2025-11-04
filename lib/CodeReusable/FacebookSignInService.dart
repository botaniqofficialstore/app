import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookSignInService {
  static Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        // Get user data
        final userData = await FacebookAuth.instance.getUserData();
        return userData;
      } else {
        print("Facebook login failed: ${result.status}");
        return null;
      }
    } catch (e) {
      print("Facebook login error: $e");
      return null;
    }
  }

  static Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
  }
}
