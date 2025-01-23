/*
 * File name: custom_pages_view.dart
 * Last modified: 2022.02.18 at 19:24:11
 * Author: SmarterVision - https://codecanyon.net/user/smartervision
 * Copyright (c) 2022
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/ui.dart';
import '../../../providers/laravel_provider.dart';
import '../controllers/custom_pages_controller.dart';
import '../widgets/custom_page_loading_widget.dart';

class CustomPagesView extends GetView<CustomPagesController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          return Text(
            controller.customPage.value.title?.tr ?? '',
            style: Get.textTheme.titleLarge?.copyWith(color: Colors.white), // Set title color to white
          );
        }),
        centerTitle: true,
        backgroundColor: Color(0xFF5C6BC0), // Set background color using the hex code
        elevation: 0, // Remove AppBar shadow
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white), // Set back icon color to white
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          Get.find<LaravelApiClient>().forceRefresh();
          controller.refreshCustomPage(showMessage: true);
          Get.find<LaravelApiClient>().unForceRefresh();
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Obx(() {
                if (controller.customPage.value.content?.isEmpty ?? true) {
                  return CustomPageLoadingWidget();
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(0.5),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth, // Constrain content width
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Ui.applyHtml(
                            controller.customPage.value.content,
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }),
            );
          },
        ),
      ),
    );
  }
}
