/*
*     You can't do this. Only the guy below can:
*     SALIM BEN AMMAR
* */

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/ui.dart';
import '../../../../main.dart';
import '../../../models/user_model.dart';
import '../../../repositories/user_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/firebase_messaging_service.dart';
import '../../../services/settings_service.dart';
import '../../root/controllers/root_controller.dart';

class AuthController extends GetxController {
  final Rx<User> currentUser = Get.find<AuthService>().user;
  late GlobalKey<FormState> loginFormKey;
  late GlobalKey<FormState> registerFormKey;
  late GlobalKey<FormState> resetPassFormKey;
  late GlobalKey<FormState> forgotPasswordFormKey;
  final hidePassword = true.obs;
  final hidePasswordConfirmation = true.obs;
  final loading = false.obs;
  final smsSent = ''.obs;
  late UserRepository _userRepository;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  Rx<String> password=''.obs;
  Rx<String>passwordConfirmation=''.obs;

  AuthController() {
    loginFormKey = new GlobalKey<FormState>();
    _userRepository = UserRepository();
  }

  void login() async {
    Get.focusScope?.unfocus();
    if (loginFormKey.currentState!.validate()) {
      loginFormKey.currentState!.save();
      loading.value = true;
      try {
        // Call setDeviceToken() and retrieve the token
        String? deviceToken = await setDeviceToken(); // Call the function from main.dart
        currentUser.value.deviceToken = deviceToken;  // Set the token to currentUser

        // Perform login with the device token
        currentUser.value = await _userRepository.login(currentUser.value);

        // Call the sign-in method
        await _userRepository.signInWithEmailAndPassword(currentUser.value.email, currentUser.value.apiToken);

        // Navigate to the main page after successful login
        await Get.find<RootController>().changePage(0);
      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      } finally {
        loading.value = false;
      }
    }
  }

  void register() async {
    Get.focusScope?.unfocus();
    if (registerFormKey.currentState!.validate()) {
      registerFormKey.currentState!.save();
      loading.value = true;
      try {
        if (Get.find<SettingsService>().setting.value.enableOtp ?? false ) {
          await _userRepository.sendCodeToPhone();
          loading.value = false;
          await Get.toNamed(Routes.PHONE_VERIFICATION);
        } else {
          await Get.find<FireBaseMessagingService>().setDeviceToken();
          currentUser.value = await _userRepository.register(currentUser.value);
          await _userRepository.signUpWithEmailAndPassword(currentUser.value.email, currentUser.value.apiToken);
          await Get.find<RootController>().changePage(0);
        }
      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      } finally {
        loading.value = false;
      }
    }
  }

  void resetPassword() async {
    print("Reset password ---------------------");
    Get.focusScope?.unfocus();
    if (resetPassFormKey.currentState!.validate()) {
      resetPassFormKey.currentState!.save();
      // Check if passwords match
      if (password.value != passwordConfirmation.value) {
        Get.showSnackbar(
          Ui.ErrorSnackBar(
            message: "Passwords do not match. Please try again.".tr,
          ),
        );
        return; // Stop execution if passwords do not match
      }

      loading.value = true;
      try {
        print("password: " + password.value);
        print("passwordConfirmation: " + passwordConfirmation.value);
        _userRepository.resetPassword(currentUser.value.phoneNumber, password.value, passwordConfirmation.value);
        Get.showSnackbar(Ui.SuccessSnackBar(message: "Password changed successfully".tr));

      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      } finally {
        loading.value = false;
        await Get.toNamed(Routes.LOGIN);
      }
    }
  }

  Future<void> verifyPhone() async {
    try {
      loading.value = true;
      await _userRepository.verifyPhone(smsSent.value);
      await Get.find<FireBaseMessagingService>().setDeviceToken();
      currentUser.value = await _userRepository.register(currentUser.value);
      await _userRepository.signUpWithEmailAndPassword(currentUser.value.email, currentUser.value.apiToken);
      await Get.find<RootController>().changePage(0);
    } catch (e) {
      Get.back();
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    } finally {
      loading.value = false;
    }
  }

  Future<void> verifyOTP() async {
    try {
      loading.value = true;
      await _userRepository.verifyPhone(smsSent.value);
      await Get.find<FireBaseMessagingService>().setDeviceToken();
      currentUser.value = await _userRepository.register(currentUser.value);
      await _userRepository.signUpWithEmailAndPassword(currentUser.value.email, currentUser.value.apiToken);
      await Get.find<RootController>().changePage(0);
    } catch (e) {
      Get.back();
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    } finally {
      loading.value = false;
    }
  }

  Future<void> resendOTPCode() async {
    await _userRepository.sendCodeToPhone();
  }



  Future<void> verifyPasswordSentOTP() async {
    try {
      loading.value = true;
      await _userRepository.verifyPhone(smsSent.value);
      Get.toNamed(Routes.PASS_RESET);
    } catch (e) {
      Get.back();
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    } finally {
      loading.value = false;
    }
  }

  Future<bool> checkPhoneNumber(String phoneNumber) async {
    try{
      loading.value= true;
      var res=await _userRepository.checkPhoneNumber(phoneNumber);
      print("resultat(----------------");
      print(res);
      if (res){
        await resendOTPCode();
        loading.value= false;
        return true;
      }
      else{
        loading.value= false;
        return false;
      }
    }
    catch (e){
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      loading.value= false;
      return false;
    }
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
