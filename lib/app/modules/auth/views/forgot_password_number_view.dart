import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/ui.dart';
import '../../../models/setting_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/settings_service.dart';
import '../../global_widgets/block_button_widget.dart';
import '../../global_widgets/circular_loading_widget.dart';
import '../../global_widgets/phone_field_widget.dart';
import '../../global_widgets/text_field_widget.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  final Setting _settings = Get.find<SettingsService>().setting.value;

  @override
  Widget build(BuildContext context) {
    controller.forgotPasswordFormKey = new GlobalKey<FormState>();
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Forgot Password".tr,
            style: Get.textTheme.titleLarge?.merge(TextStyle(color: context.theme.primaryColor)),
          ),
          centerTitle: true,
          backgroundColor: Get.theme.colorScheme.secondary,
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: Form(
          key: controller.forgotPasswordFormKey,
          child: ListView(
            primary: true,
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  Container(
                    height: 180,
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.secondary,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(color: Get.theme.focusColor.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 5)),
                      ],
                    ),
                    margin: EdgeInsets.only(bottom: 50),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            _settings.appName ?? '',
                            style: Get.textTheme.titleLarge?.merge(TextStyle(color: Get.theme.primaryColor, fontSize: 24)),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Welcome to the best doctor provider system!".tr,
                            style: Get.textTheme.bodySmall?.merge(TextStyle(color: Get.theme.primaryColor)),
                            textAlign: TextAlign.center,
                          ),
                          // Text("Fill the following credentials to login your account", style: Get.textTheme.bodySmall?.merge(TextStyle(color: Get.theme.primaryColor))),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: Ui.getBoxDecoration(
                      radius: 14,
                      border: Border.all(width: 5, color: Get.theme.primaryColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Image.asset(
                        'assets/icon/icon.png',
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                ],
              ),
              Obx(() {
                if (controller.loading.isTrue)
                  return CircularLoadingWidget(height: 300);
                else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PhoneFieldWidget(
                        labelText: "Phone Number".tr,

                        initialCountryCode: controller.currentUser.value.getPhoneNumber().countryISOCode,
                        initialValue: controller.currentUser.value.getPhoneNumber().number,
                        onSaved: (phone) {
                          controller.currentUser.value.phoneNumber = phone?.completeNumber;
                        },
                      ),
                      BlockButtonWidget(
                        onPressed: () async {
                          Get.focusScope?.unfocus();
                          if (controller.forgotPasswordFormKey.currentState!.validate()) {
                            controller.forgotPasswordFormKey.currentState!.save();
                            controller.loading.value = true;
                            try {

                              var res=await controller.checkPhoneNumber(controller.currentUser.value.phoneNumber);
                              if(res){

                              controller.loading.value = false;
                              Get.showSnackbar(Ui.SuccessSnackBar(
                                message: "OTP SENT".tr + controller.currentUser.value.phoneNumber,
                              ));
                              Timer(Duration(seconds: 1), () {
                                Get.offAndToNamed(Routes.OTP_VERIFICATION);
                              });
                              }
                              else{
                                Get.showSnackbar(Ui.ErrorSnackBar(
                                  message: "Phone number does not exist: ".tr + controller.currentUser.value.phoneNumber,
                                ));
                              }

                            } catch (e) {
                              Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
                            } finally {
                              controller.loading.value = false;
                            }
                          }
                        },
                        color: Get.theme.colorScheme.secondary,
                        text: Text(
                          "Send Code".tr,
                          style: Get.textTheme.titleLarge?.merge(TextStyle(color: Get.theme.primaryColor)),
                        ),
                      ).paddingSymmetric(vertical: 35, horizontal: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Get.offAllNamed(Routes.REGISTER);
                            },
                            child: Text("You don't have an account?".tr),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Get.offAllNamed(Routes.LOGIN);
                            },
                            child: Text("You remember my password!".tr),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              }),
            ],
          ),
        ));
  }
}
