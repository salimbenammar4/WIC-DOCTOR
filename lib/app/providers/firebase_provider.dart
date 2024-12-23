import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:get/get.dart';

import '../services/auth_service.dart';

class FirebaseProvider extends GetxService {
  fba.FirebaseAuth _auth = fba.FirebaseAuth.instance;

  Future<FirebaseProvider> init() async {
    return this;
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Attempt to sign in with email and password
      fba.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user != null;
    } catch (e) {
      // Log error and avoid signup fallback
      print('Login failed: ${e.toString()}');
      return false; // Return false instead of signing up
    }
  }

  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    // 1. Create the user with email and password
    fba.UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (result.user != null) {
      // 2. Immediately send the OTP to the user's phone

      return true;
    } else {
      return false;
    }
  }

  Future<void> verifyPhone(String smsCode) async {
    try {
      final fba.AuthCredential credential = fba.PhoneAuthProvider.credential(verificationId: Get.find<AuthService>().user.value.verificationId, smsCode: smsCode);
      await fba.FirebaseAuth.instance.signInWithCredential(credential);
      Get.find<AuthService>().user.value.verifiedPhone = true;
    } catch (e) {
      Get.find<AuthService>().user.value.verifiedPhone = false;
      throw Exception(e.toString());
    }
  }

  Future<void> sendCodeToPhone() async {
    try {
      print('Sending OTP to: ${Get.find<AuthService>().user.value.phoneNumber}');
      Get.find<AuthService>().user.value.verificationId = '';
      final fba.PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {};
      final fba.PhoneCodeSent smsCodeSent = (String verId, int? forceCodeResent) {
        print('OTP Sent! Verification ID: $verId');
        Get.find<AuthService>().user.value.verificationId = verId;
      };
      final fba.PhoneVerificationCompleted _verifiedSuccess = (fba.AuthCredential auth) async {};
      final fba.PhoneVerificationFailed _verifyFailed = (fba.FirebaseAuthException e) {
        print('Verification Failed: ${e.message}');
        throw Exception(e.message);
      };
      await _auth.verifyPhoneNumber(
        phoneNumber: Get.find<AuthService>().user.value.phoneNumber,
        timeout: const Duration(seconds: 30),
        verificationCompleted: _verifiedSuccess,
        verificationFailed: _verifyFailed,
        codeSent: smsCodeSent,
        codeAutoRetrievalTimeout: autoRetrieve,
      );
      print(smsCodeSent);
    } catch (e) {
      print('Error sending OTP: $e');
    }
  }

  Future signOut() async {
    return await _auth.signOut();
  }

  Future<void> deleteCurrentUser() async {
    return await _auth.currentUser?.delete();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent successfully!');
    } catch (e) {
      print('Error sending password reset email: ${e.toString()}');
      throw Exception(e.toString());
    }
  }

}
