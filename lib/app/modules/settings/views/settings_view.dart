/*
*     Redesigned by:
*     SALIM BEN AMMAR
* */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../global_widgets/tab_bar_widget.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  final _navigatorKey = Get.nestedKey(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings".tr,
          style: context.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF18167A),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        bottom: TabBarWidget(
          initialSelectedId: 0,
          tag: 'settings',
          tabs: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the chips horizontally
              children: [
                ChipWidget(
                  tag: 'settings',
                  text: "Languages".tr,
                  id: 0,
                  onSelected: (id) {
                    controller.changePage(id);
                  },
                ),
                SizedBox(width: 10), // Add spacing between chips
                ChipWidget(
                  tag: 'settings',
                  text: "Profile".tr,
                  id: 1,
                  onSelected: (id) {
                    controller.changePage(id);
                  },
                ),
                SizedBox(width: 10), // Add spacing between chips
                ChipWidget(
                  tag: 'settings',
                  text: "Theme Mode".tr,
                  id: 2,
                  onSelected: (id) {
                    controller.changePage(id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (_navigatorKey?.currentState?.canPop() ?? false) {
            _navigatorKey?.currentState!.pop();
            return false;
          }
          return true;
        },
        child: Navigator(
          key: _navigatorKey,
          initialRoute: Routes.SETTINGS_LANGUAGE,
          onGenerateRoute: controller.onGenerateRoute,
        ),
      ),
    );
  }
}
