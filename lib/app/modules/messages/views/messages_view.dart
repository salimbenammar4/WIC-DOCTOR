import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chats".tr,
          style: Get.textTheme.titleLarge,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.sort, color: Get.theme.hintColor),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [NotificationsButtonWidget()],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.lastDocument.value = null; // reset last document for fresh load
          await controller.listenForMessages(); // reload messages
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
    );
  }
}
