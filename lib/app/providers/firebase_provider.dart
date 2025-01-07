import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';

class FirebaseProvider extends GetxService {
  fba.FirebaseAuth _auth = fba.FirebaseAuth.instance;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<FirebaseProvider> init() async {
    return this;
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      fba.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user != null;
    } on fba.FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = "Invalid email address. Please enter a valid email.";
          break;
        case 'user-disabled':
          errorMessage = "This account has been disabled. Please contact support.";
          break;
        case 'user-not-found':
          errorMessage = "No account found with this email. Please sign up first.";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password. Please try again.";
          break;
        case 'too-many-requests':
          errorMessage = "Too many login attempts. Please try again later.";
          break;
        case 'network-request-failed':
          errorMessage = "Network error. Please check your internet connection and try again.";
          break;
        default:
          errorMessage = "An unexpected error occurred. Please try again.";
      }

      // Use the global key to show the snackbar
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return false;
    } catch (e) {
      print('Login failed: ${e.toString()}');
      return false;
    }
  }


  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    try {
      // 1. Create the user with email and password
      fba.UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // 2. Immediately send the OTP to the user's phone (placeholder for OTP logic)
        // Example: await _sendOtpToPhone(result.user.phoneNumber);

        return true;
      } else {
        return false;
      }
    } on fba.FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = "This email is already registered. Please log in instead.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address. Please enter a valid email.";
          break;
        case 'weak-password':
          errorMessage = "The password is too weak. Please choose a stronger password.";
          break;
        case 'operation-not-allowed':
          errorMessage = "Email/password sign-up is not enabled. Please contact support.";
          break;
        case 'network-request-failed':
          errorMessage = "Network error. Please check your connection and try again.";
          break;
        default:
          errorMessage = "An unexpected error occurred. Please try again.";
      }

      // Show snackbar using a global key
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return false;
    } catch (e) {
      print('Sign-up failed: ${e.toString()}');
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
