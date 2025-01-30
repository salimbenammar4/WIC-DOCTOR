import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/privacy_controller.dart';

class PrivacyView extends GetView<PrivacyController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Privacy Policy".tr,
            style: Get.textTheme.titleLarge?.copyWith(color: Colors.white), // Set title color to white
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF18167A), // Set background color using the hex code
          elevation: 0, // Remove AppBar shadow
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white), // Set back icon color to white
            onPressed: () => Get.back(),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {},
          child: WebViewWidget(controller: controller.webView),
        ));
  }
}
