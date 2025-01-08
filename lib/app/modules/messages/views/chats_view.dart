import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../common/ui.dart';
import '../../../models/chat_model.dart';
import '../../../models/media_model.dart';
import '../../../models/message_model.dart';
import '../../../models/user_model.dart';
import '../../global_widgets/circular_loading_widget.dart';
import '../controllers/messages_controller.dart';
import '../widgets/chat_message_item_widget.dart';

// ignore: must_be_immutable
class ChatsView extends GetView<MessagesController> {
  final _myListKey = GlobalKey<AnimatedListState>();

  Widget chatList() {
    return Obx(
          () {
        if (controller.chats.isEmpty) {
          return CircularLoadingWidget(
            height: Get.height,
            onCompleteText: "Type a message to start chat!".tr,
          );
        } else {
          return ListView.builder(
              key: _myListKey,
              reverse: true,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              itemCount: controller.chats.length,
              shrinkWrap: false,
              primary: true,
              itemBuilder: (context, index) {
                Chat _chat = controller.chats.elementAt(index);
                _chat.user = controller.message.value.users.firstWhere(
                      (_user) => _user.id == _chat.userId,
                  orElse: () => User(name: "-", avatar: Media()),
                );
                return ChatMessageItem(
                  chat: _chat,
                );
              });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.message.value = Get.arguments as Message;
    if (controller.message.value.hasData) {
      controller.listenForChats();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Get.theme.hintColor),
          onPressed: () async {
            controller.message.value = Message([]);
            controller.chats.clear();
            await controller.refreshMessages();
            Get.back();
          },
        ),
        automaticallyImplyLeading: false,
        title: Obx(() {
          return Text(
            controller.message.value.name,
            overflow: TextOverflow.fade,
            maxLines: 1,
            style: Get.textTheme.titleLarge?.merge(TextStyle(letterSpacing: 1.3)),
          );
        }),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: chatList(),
          ),
          Obx(() {
            if (controller.uploading.isTrue)
              return Container(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: CircularProgressIndicator(),
              );
            else
              return SizedBox();
          }),
          Container(
            decoration: BoxDecoration(
              color: Get.theme.primaryColor,
              boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, -4), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Wrap(
                  children: [
                    SizedBox(width: 10),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        var imageUrl = await controller.getImage(ImageSource.gallery, controller.message.value);
                        if (imageUrl != null && imageUrl.trim() != '') {
                          controller.addMessage(controller.message.value, imageUrl); // Remove 'await'
                        }
                        Timer(Duration(milliseconds: 100), () {
                          controller.chatTextController.clear();
                        });
                      },
                      icon: Icon(
                        Icons.photo_outlined,
                        color: Get.theme.colorScheme.secondary,
                        size: 30,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        var imageUrl = await controller.getImage(ImageSource.camera, controller.message.value);
                        if (imageUrl != null && imageUrl.trim() != '') {
                          controller.addMessage(controller.message.value, imageUrl); // Remove 'await'
                        }
                        Timer(Duration(milliseconds: 100), () {
                          controller.chatTextController.clear();
                        });
                      },
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: Get.theme.colorScheme.secondary,
                        size: 30,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        try {
                          await controller.pickAndUploadFile(controller.message.value);
                        } catch (e) {
                          Get.showSnackbar(Ui.ErrorSnackBar(message: "Failed to upload file. Please try again."));
                        }
                        Timer(Duration(milliseconds: 100), () {
                          controller.chatTextController.clear();
                        });
                      },
                      icon: Icon(
                        Icons.attach_file_outlined,
                        color: Get.theme.colorScheme.secondary,
                        size: 30,
                      ),
                    ),

                  ],
                ),
                Expanded(
                  child: TextField(
                    controller: controller.chatTextController,
                    onChanged: (text) {
                      controller.isMessageEmpty.value = text.trim().isEmpty; // Update reactive variable
                    },
                    style: Get.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      hintText: "Start chatting!".tr,
                      hintStyle: TextStyle(color: Get.theme.focusColor.withOpacity(0.8)),
                      suffixIcon: Obx(() => IconButton(
                        padding: EdgeInsetsDirectional.only(end: 20, start: 10),
                        onPressed: controller.isMessageEmpty.value
                            ? null // Disable if message is empty
                            : () {
                          controller.addMessage(controller.message.value, controller.chatTextController.text);
                          Timer(Duration(milliseconds: 100), () {
                            controller.chatTextController.clear();
                            controller.isMessageEmpty.value = true; // Reset to true after sending
                          });
                        },
                        icon: Icon(
                          Icons.send_outlined,
                          color: controller.isMessageEmpty.value
                              ? Colors.grey // Color when disabled
                              : Get.theme.colorScheme.secondary,
                          size: 30,
                        ),
                      )),
                      border: UnderlineInputBorder(borderSide: BorderSide.none),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
