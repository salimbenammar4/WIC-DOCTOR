import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/ui.dart';
import '../controllers/theme_mode_controller.dart';

class ThemeModeView extends GetView<ThemeModeController> {
  final bool hideAppBar;

  ThemeModeView({this.hideAppBar = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: hideAppBar
            ? null
            : AppBar(
                title: Text(
                  "Theme Mode".tr,
                  style: context.textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                centerTitle: true,
                backgroundColor: Color(0xFF5C6BC0),
                automaticallyImplyLeading: false,
                leading: new IconButton(
                  icon: new Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                elevation: 0,
              ),
        body: ListView(
          primary: true,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: Ui.getBoxDecoration(),
              child: Column(
                children: [
                  RadioListTile(
                    value: ThemeMode.light,
                    groupValue: controller.selectedThemeMode.value,
                    activeColor: Get.theme.colorScheme.secondary,
                    onChanged: (value) {
                      controller.changeThemeMode(value ?? ThemeMode.light);
                    },
                    title: Text("Light Theme".tr, style: Get.textTheme.bodyMedium),
                  ),
                  RadioListTile(
                    value: ThemeMode.dark,
                    groupValue: controller.selectedThemeMode.value,
                    activeColor: Get.theme.colorScheme.secondary,
                    onChanged: (value) {
                      controller.changeThemeMode(value ?? ThemeMode.dark);
                    },
                    title: Text("Dark Theme".tr, style: Get.textTheme.bodyMedium),
                  ),
                  RadioListTile(
                    value: ThemeMode.system,
                    groupValue: controller.selectedThemeMode.value,
                    activeColor: Get.theme.colorScheme.secondary,
                    onChanged: (value) {
                      controller.changeThemeMode(value ?? ThemeMode.system);
                    },
                    title: Text("System Theme".tr, style: Get.textTheme.bodyMedium),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
