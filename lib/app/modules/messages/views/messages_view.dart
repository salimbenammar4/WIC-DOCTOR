import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemChrome
import 'package:get/get.dart';

import '../../global_widgets/circular_loading_widget.dart';
import '../../global_widgets/notifications_button_widget.dart';
import '../controllers/messages_controller.dart';
import '../widgets/message_item_widget.dart';

class MessagesView extends GetView<MessagesController> {
  // This widget manages the list of messages and ensures optimal UI updates.
  Widget conversationsList() {
    return ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      controller: controller.scrollController,
      itemCount: controller.messages.length + 1, // +1 for loading indicator
      separatorBuilder: (context, index) => SizedBox(height: 7),
      itemBuilder: (context, index) {
        if (index == controller.messages.length) {
          // Show loading indicator at the end of the list if still loading more messages
          return Obx(() {
            return controller.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : SizedBox.shrink();
          });
        }
        return MessageItemWidget(
          message: controller.messages[index],
          onDismissed: (conversation) async {
            await controller.deleteMessage(controller.messages[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set the status bar style dynamically
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness: Brightness.dark, // Black icons
      statusBarBrightness: Brightness.light, // Ensure compatibility for iOS
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Chats".tr,
          style: Get.textTheme.titleLarge?.copyWith(color: Colors.white), // Title color to white
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF5C6BC0), // Hex color as appBar background
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.sort, color: Colors.white), // Back icon color to white
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [NotificationsButtonWidget(iconColor: Colors.white,)],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.1), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.center,
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                controller.lastDocument.value = null;
                await controller.listenForMessages();
              },
              child: Obx(
                    () => controller.messages.isNotEmpty
                    ? conversationsList()
                    : CircularLoadingWidget(
                  height: Get.height,
                  onCompleteText: "Messages List Empty".tr,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
