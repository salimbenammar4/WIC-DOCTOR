/*
 * Copyright (c) 2020 .
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../profile/controllers/profile_controller.dart';
import 'block_button_widget.dart';
import 'text_field_widget.dart';

class PhoneVerificationBottomSheetWidget extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.primaryColor,
        borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Get.theme.focusColor.withOpacity(0.4), blurRadius: 30, offset: Offset(0, -30)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 30,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 13, horizontal: (Get.width / 2) - 30),
            decoration: BoxDecoration(
              color: Get.theme.focusColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
            ),
          ),
          Text(
            "We sent the OTP code to your phone, please check it and enter below".tr,
            style: Get.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ).paddingSymmetric(horizontal: 20, vertical: 10),
          TextFieldWidget(
            labelText: "OTP Code".tr,
            hintText: "- - - - - -".tr,
            style: Get.textTheme.headlineMedium?.merge(TextStyle(letterSpacing: 8)),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (input) {
              controller.smsSent.value = input;
              // Automatically update the button state based on OTP length
            },
          ),
          Obx(() {
            bool isButtonDisabled = controller.smsSent.value.length != 6; // Disable if OTP is not 6 digits
            return BlockButtonWidget(
              onPressed: isButtonDisabled || controller.isVerifying.value
                  ? null
                  : () async {
                controller.isVerifying.value = true;  // Disable button after pressing
                await controller.verifyPhone();
                controller.isVerifying.value = false;  // Re-enable after verification
              },
              color: Get.theme.colorScheme.secondary,
              text: Text(
                "Verify".tr,
                style: Get.textTheme.titleLarge?.merge(TextStyle(color: Get.theme.primaryColor)),
              ),
            ).paddingSymmetric(vertical: 30, horizontal: 20);
          }),
        ],
      ),
    );
  }
}
