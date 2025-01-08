import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
        return FutureBuilder<String?>(
          future: getFileMetadata(chat.text),  // Get content type of the file
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();  // Show a loading spinner while fetching metadata
            } else if (snapshot.hasError || !snapshot.hasData) {
              return getSentMessageTextLayout(context);  // Fallback if metadata is not available
            } else {
              String? contentType = snapshot.data;
              if (contentType != null) {
                if (contentType.startsWith('image')) {
                  return getSentMessageImageLayout(context);  // Show image layout if the content is an image
                } else if (contentType.startsWith('application/pdf')) {
                  return getSentMessageFileLayout(context);  // Show file layout for PDFs or other files
                } else {
                  return getSentMessageTextLayout(context);  // Fallback for non-image, non-pdf files
                }
              } else {
                return getSentMessageTextLayout(context);  // Default to text layout if content type is unknown
              }
            }
          },
        );
      } else {
        return getSentMessageTextLayout(context);
      }
    } else {
      if (chat.text.isURL) {
        return FutureBuilder<String?>(
          future: getFileMetadata(chat.text),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();  // Show loading spinner for receiving message
            } else if (snapshot.hasError || !snapshot.hasData) {
              return getReceivedMessageTextLayout(context);  // Fallback if metadata is not available
            } else {
              String? contentType = snapshot.data;
              if (contentType != null) {
                if (contentType.startsWith('image')) {
                  return getReceivedMessageImageLayout(context);  // Show image layout for received message
                } else if (contentType.startsWith('application/pdf')) {
                  return getReceivedMessageFileLayout(context);  // Show file layout for PDFs
                } else {
                  return getReceivedMessageTextLayout(context);  // Default to text layout for other files
                }
              } else {
                return getReceivedMessageTextLayout(context);  // Default fallback for unknown file types
              }
            }
          },
        );
      } else {
        return getReceivedMessageTextLayout(context);  // Handle normal text message
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
                new Flexible(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(this.chat.user.name, style: Get.textTheme.bodyMedium?.merge(TextStyle(fontWeight: FontWeight.w600, color: Get.theme.primaryColor))),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: new Text(
                          chat.text,
                          style: Get.textTheme.bodyLarge?.merge(TextStyle(color: Get.theme.primaryColor)),
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
              DateFormat('HH:mm | d, MMMM y', Get.locale.toString()).format(DateTime.fromMillisecondsSinceEpoch(this.chat.time)),
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Get.textTheme.bodySmall,
            ),
          )
        ],
      ),
    );
  }

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
              DateFormat('HH:mm | d, MMMM y', Get.locale.toString()).format(DateTime.fromMillisecondsSinceEpoch(this.chat.time)),
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Get.textTheme.bodySmall,
            ),
          )
        ],
      ),
    );
  }

  Widget getSentMessageFileLayout(BuildContext context) {
    String fileName = chat.text.split('/').last.split('?')[0]; // Extract file name from URL

    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Get.theme.focusColor.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        chat.user.name,
                        style: Get.textTheme.bodyLarge?.merge(
                          TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(height: 5),
                      InkWell(
                        onTap: () {
                          if (chat.text.endsWith('.jpg') ||
                              chat.text.endsWith('.jpeg') ||
                              chat.text.endsWith('.png')) {
                            // Handle image preview
                            Get.toNamed(Routes.GALLERY, arguments: {
                              'media': [Media(id: chat.text, url: chat.text)],
                              'current': Media(id: chat.text, url: chat.text),
                              'heroTag': 'chat_image',
                            });
                          } else {
                            // Handle file download or redirection
                            launchUrl(Uri.parse(chat.text));
                          }
                        },
                        child: Row(
                          children: [
                            Icon(
                              chat.text.endsWith('.jpg') ||
                                  chat.text.endsWith('.jpeg') ||
                                  chat.text.endsWith('.png')
                                  ? Icons.image
                                  : Icons.picture_as_pdf,
                              size: 30,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                fileName,
                                style: Get.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  width: 42,
                  height: 42,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(42)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              DateFormat('d, MMMM y | HH:mm', Get.locale.toString())
                  .format(DateTime.fromMillisecondsSinceEpoch(chat.time)),
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Get.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget getReceivedMessageFileLayout(BuildContext context) {
    String fileName = chat.text.split('/').last; // Extract file name from URL
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Get.theme.focusColor.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        chat.user.name,
                        style: Get.textTheme.bodyLarge?.merge(
                          TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(height: 5),
                      InkWell(
                        onTap: () {
                          // Handle file download
                          launchUrl(Uri.parse(chat.text));
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.insert_drive_file,
                              size: 40,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                fileName,
                                style: Get.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  width: 42,
                  height: 42,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(42)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              DateFormat('d, MMMM y | HH:mm', Get.locale.toString())
                  .format(DateTime.fromMillisecondsSinceEpoch(chat.time)),
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Get.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> getFileMetadata(String fileUrl) async {
    try {
      // Parse the file URL
      Uri fileUri = Uri.parse(fileUrl);

      // Extract the file path by removing the '/o/' part from the URL
      String path = Uri.decodeFull(fileUri.pathSegments.last); // Get the last segment of the URL path

      // Create a reference to the file in Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(path);

      // Get the file's metadata
      final metadata = await storageRef.getMetadata();

      // Print the content type (MIME type) of the file
      print('File content type: ${metadata.contentType}');
      return metadata.contentType;
    } catch (e) {
      print('Error getting file metadata: $e');
      return null;
    }
  }
}
