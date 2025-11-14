import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FacebookSignInService {
  static Future<User?> signInWithFacebook() async {
    try {
      // Trigger the Facebook Login flow
      final LoginResult fbResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (fbResult.status == LoginStatus.success) {
        final AccessToken? accessToken = fbResult.accessToken;

        // Convert to Firebase credential
        final OAuthCredential credential =
        FacebookAuthProvider.credential(accessToken!.tokenString);

        // Login to Firebase
        final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

        return userCredential.user;
      } else {
        print("Facebook login failed: ${fbResult.status}");
        return null;
      }
    } catch (e) {
      print("Facebook login error: $e");
      return null;
    }
  }

  static Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
    await FirebaseAuth.instance.signOut();
  }
}
