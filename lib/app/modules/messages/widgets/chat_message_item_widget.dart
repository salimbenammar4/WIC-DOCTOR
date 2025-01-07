import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:url_launcher/url_launcher.dart';

import '../../../models/chat_model.dart';
import '../../../models/media_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

class ChatMessageItem extends StatelessWidget {
  final Chat chat;

  ChatMessageItem({required this.chat});

  @override
  Widget build(BuildContext context) {
    if (Get.find<AuthService>().user.value.id == this.chat.userId) {
      if (chat.text.isURL) {
        return getSentMessageImageLayout(context);
      } else {
        return getSentMessageTextLayout(context);
      }
    } else {
      if (chat.text.isURL) {
        return getReceivedMessageImageLayout(context);
      } else {
        return getReceivedMessageTextLayout(context);
      }
    }
  }

  Widget getSentMessageTextLayout(context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Get.theme.focusColor.withOpacity(0.2),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Flexible(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      new Text(this.chat.user.name, style: Get.textTheme.bodyMedium?.merge(TextStyle(fontWeight: FontWeight.w600))),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: new Text(chat.text, style: Get.textTheme.bodyLarge),
                      ),
                    ],
                  ),
                ),
                new Container(
                  margin: const EdgeInsets.only(left: 8.0),
                  width: 42,
                  height: 42,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(42)),
                    child: CachedNetworkImage(
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: this.chat.user.avatar.thumb,
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error_outline),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              DateFormat('d, MMMM y | HH:mm', Get.locale.toString()).format(DateTime.fromMillisecondsSinceEpoch(this.chat.time)),
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Get.textTheme.bodySmall,
            ),
          )
        ],
      ),
    );
  }

  // Sent image layout (URL)
  Widget getSentMessageImageLayout(context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Get.theme.focusColor.withOpacity(0.2),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Flexible(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      new Text(this.chat.user.name, style: Get.textTheme.bodyLarge?.merge(TextStyle(fontWeight: FontWeight.w600))),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(Routes.GALLERY, arguments: {
                              'media': [new Media(id: this.chat.text, url: this.chat.text)],
                              'current': new Media(id: this.chat.text, url: this.chat.text),
                              'heroTag': 'chat_image'
                            });
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: CachedNetworkImage(
                              width: double.infinity,
                              fit: BoxFit.cover,
                              height: 200,
                              imageUrl: this.chat.text,
                              placeholder: (context, url) => Image.asset(
                                'assets/img/loading.gif',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.link_outlined),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                new Container(
                  margin: const EdgeInsets.only(left: 8.0),
                  width: 42,
                  height: 42,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(42)),
                    child: CachedNetworkImage(
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: this.chat.user.avatar.thumb,
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error_outline),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              DateFormat('d, MMMM y | HH:mm', Get.locale.toString()).format(DateTime.fromMillisecondsSinceEpoch(this.chat.time)),
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Get.textTheme.bodySmall,
            ),
          )
        ],
      ),
    );
  }

  // Sent file message layout
  Widget getSentMessageFileLayout(context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Get.theme.focusColor.withOpacity(0.2),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Flexible(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      new Text(this.chat.user.name, style: Get.textTheme.bodyLarge?.merge(TextStyle(fontWeight: FontWeight.w600))),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Row(
                          children: [
                            Icon(Icons.attach_file, size: 20),
                            SizedBox(width: 8),
                            Text("File Attachment", style: Get.textTheme.bodyLarge),
                            IconButton(
                              icon: Icon(Icons.download, size: 20),
                              onPressed: () {
                                downloadFile(this.chat.text); // Call the download function
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                 Container(
                  margin: const EdgeInsets.only(left: 8.0),
                  width: 42,
                  height: 42,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(42)),
                    child: CachedNetworkImage(
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: this.chat.user.avatar.thumb,
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error_outline),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              DateFormat('d, MMMM y | HH:mm', Get.locale.toString()).format(DateTime.fromMillisecondsSinceEpoch(this.chat.time)),
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Get.textTheme.bodySmall,
            ),
          )
        ],
      ),
    );
  }

  // Received text message layout
  Widget getReceivedMessageTextLayout(context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Get.theme.colorScheme.secondary,
                borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 42,
                  height: 42,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(42)),
                    child: CachedNetworkImage(
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: this.chat.user.avatar.thumb,
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error_outline),
                    ),
                  ),
                ),
                 Flexible(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(this.chat.user.name, style: Get.textTheme.bodyMedium?.merge(TextStyle(fontWeight: FontWeight.w600, color: Get.theme.primaryColor))),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: new Text(chat.text, style: Get.textTheme.bodyLarge),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              DateFormat('d, MMMM y | HH:mm', Get.locale.toString()).format(DateTime.fromMillisecondsSinceEpoch(this.chat.time)),
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Get.textTheme.bodySmall,
            ),
          )
        ],
      ),
    );
  }

  // Received image message layout
  Widget getReceivedMessageImageLayout(context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Get.theme.colorScheme.secondary,
                borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 42,
                  height: 42,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(42)),
                    child: CachedNetworkImage(
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: this.chat.user.avatar.thumb,
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error_outline),
                    ),
                  ),
                ),
                new Flexible(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(this.chat.user.name, style: Get.textTheme.bodyMedium?.merge(TextStyle(fontWeight: FontWeight.w600, color: Get.theme.primaryColor))),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(Routes.GALLERY, arguments: {
                              'media': [new Media(id: this.chat.text, url: this.chat.text)],
                              'current': new Media(id: this.chat.text, url: this.chat.text),
                              'heroTag': 'chat_image'
                            });
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: CachedNetworkImage(
                              width: double.infinity,
                              fit: BoxFit.cover,
                              height: 200,
                              imageUrl: this.chat.text,
                              placeholder: (context, url) => Image.asset(
                                'assets/img/loading.gif',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.link_outlined),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              DateFormat('d, MMMM y | HH:mm', Get.locale.toString()).format(DateTime.fromMillisecondsSinceEpoch(this.chat.time)),
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Get.textTheme.bodySmall,
            ),
          )
        ],
      ),
    );
  }

  // Received file message layout
  Widget getReceivedMessageFileLayout(context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Get.theme.colorScheme.secondary,
                borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 42,
                  height: 42,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(42)),
                    child: CachedNetworkImage(
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: this.chat.user.avatar.thumb,
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error_outline),
                    ),
                  ),
                ),
                new Flexible(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(this.chat.user.name, style: Get.textTheme.bodyMedium?.merge(TextStyle(fontWeight: FontWeight.w600))),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Row(
                          children: [
                            Icon(Icons.attach_file, size: 20),
                            SizedBox(width: 8),
                            Text("File Attachment", style: Get.textTheme.bodyLarge),
                            IconButton(
                              icon: Icon(Icons.download, size: 20),
                              onPressed: () {
                                downloadFile(this.chat.text); // Call the download function
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              DateFormat('d, MMMM y | HH:mm', Get.locale.toString()).format(DateTime.fromMillisecondsSinceEpoch(this.chat.time)),
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Get.textTheme.bodySmall,
            ),
          )
        ],
      ),
    );
  }

  // Function to download file
  void downloadFile(String fileUrl) async {
    if (await canLaunch(fileUrl)) {
      await launch(fileUrl); // Open the URL for download
    } else {
      throw 'Could not launch $fileUrl';
    }
  }
}