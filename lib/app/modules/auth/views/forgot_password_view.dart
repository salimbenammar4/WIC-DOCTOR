import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/helper.dart';
import '../../../../common/ui.dart';
import '../../../models/setting_model.dart';
import '../../../services/settings_service.dart';
import '../../global_widgets/block_button_widget.dart';
import '../../global_widgets/circular_loading_widget.dart';
import '../../global_widgets/text_field_widget.dart';
import '../controllers/auth_controller.dart';

class PasswordResetView extends GetView<AuthController> {
  final Setting _settings = Get.find<SettingsService>().setting.value;

  @override
  Widget build(BuildContext context) {
    controller.resetPassFormKey = new GlobalKey<FormState>();
    return WillPopScope(
        onWillPop: Helper().onWillPop,
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                "Réinitialisation de mot de passe".tr,
                style: Get.textTheme.titleLarge?.merge(TextStyle(color: context.theme.primaryColor)),
              ),
              centerTitle: true,
              backgroundColor: Get.theme.colorScheme.secondary,
              automaticallyImplyLeading: false,
              elevation: 0,
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back_ios, color: Get.theme.primaryColor),
                onPressed: () => {Get.back()},
              ),
            ),
            body: Form(
              key: controller.resetPassFormKey, // Add form key for validation
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
                                _settings.appName ?? "",
                                style: Get.textTheme.titleLarge?.merge(TextStyle(color: Get.theme.primaryColor, fontSize: 24)),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Tapez votre nouveau mot de passe!".tr,
                                style: Get.textTheme.bodySmall?.merge(TextStyle(color: Get.theme.primaryColor)),
                                textAlign: TextAlign.center,
                              ),
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
                    if (controller.loading.isTrue) {
                      return CircularLoadingWidget(height: 300);
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFieldWidget(
                            labelText: "Nouveau Mot de passe".tr,
                            hintText: "".tr,
                            initialValue: controller.password.value,
                            onSaved: (input) => controller.password.value = input!,
                            validator: (input) => input!.length < 3 ? "Should be more than 3 characters".tr : null,
                            obscureText: controller.hidePassword.value,
                            iconData: Icons.lock_outline,
                            keyboardType: TextInputType.visiblePassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                controller.hidePassword.value = !controller.hidePassword.value;
                              },
                              color: Theme.of(context).focusColor,
                              icon: Icon(controller.hidePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            ),
                          ),
                          TextFieldWidget(
                            labelText: "Retaper Nouveau Mot de passe".tr,
                            hintText: "".tr,
                            initialValue: controller.passwordConfirmation.value,
                            onSaved: (input) => controller.passwordConfirmation.value = input!,
                            validator: (input) => input!.length < 3 ? "Should be more than 3 characters".tr : null,
                            obscureText: controller.hidePasswordConfirmation.value,
                            iconData: Icons.lock_reset,
                            keyboardType: TextInputType.visiblePassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                controller.hidePasswordConfirmation.value = !controller.hidePasswordConfirmation.value;
                              },
                              color: Theme.of(context).focusColor,
                              icon: Icon(controller.hidePasswordConfirmation.value ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            ),
                          ),
                          BlockButtonWidget(
                            onPressed: () {
                              if (controller.resetPassFormKey.currentState!.validate()) {
                                controller.resetPassword();
                              }
                            },
                            color: Get.theme.colorScheme.secondary,
                            text: Text(
                              "Reset Password".tr,
                              style: Get.textTheme.titleLarge?.merge(TextStyle(color: Get.theme.primaryColor)),
                            ),
                          ).paddingSymmetric(vertical: 30, horizontal: 20),
                        ],
                      );
                    }
                  })
                ],
              ),
            )
        ));
  }
}
