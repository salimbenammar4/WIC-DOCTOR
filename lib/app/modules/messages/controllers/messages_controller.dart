import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/ui.dart';
import '../../../models/chat_model.dart';
import '../../../models/message_model.dart';
import '../../../models/user_model.dart';
import '../../../repositories/chat_repository.dart';
import '../../../repositories/notification_repository.dart';
import '../../../services/auth_service.dart';

class MessagesController extends GetxController {
  final uploading = false.obs;
  var message = Message([]).obs;
  late ChatRepository _chatRepository;
  late NotificationRepository _notificationRepository;
  late AuthService _authService;
  var messages = <Message>[].obs;
  var chats = <Chat>[].obs;
  File? imageFile;
  Rx<DocumentSnapshot?> lastDocument = Rx<DocumentSnapshot?>(null);
  final isLoading = true.obs;
  final isDone = false.obs;
  ScrollController scrollController = ScrollController();
  final chatTextController = TextEditingController();
  var isMessageEmpty = true.obs;

  MessagesController() {
    _chatRepository = ChatRepository();
    _notificationRepository = NotificationRepository();
    _authService = Get.find<AuthService>();
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() async {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !isDone.value) {
        await listenForMessages();
      }
    });
    listenForMessages(); // Start listening for messages on initialization
  }

  @override
  void onClose() {
    chatTextController.dispose();
  }

  Future createMessage(Message _message) async {
    _message.users.insert(0, _authService.user.value);
    _message.lastMessageTime = DateTime.now().millisecondsSinceEpoch;
    _message.readByUsers = [_authService.user.value.id];

    message.value = _message;

    await _chatRepository.createMessage(_message);
    listenForChats();
  }

  Future deleteMessage(Message _message) async {
    messages.remove(_message);
    await _chatRepository.deleteMessage(_message);
  }

  Future refreshMessages() async {
    messages.clear();
    lastDocument.value = null; // Reset lastDocument
    await listenForMessages(); // Fetch messages again
  }

  Future listenForMessages() async {
    isLoading.value = true;
    isDone.value = false;
    Stream<QuerySnapshot> _userMessages;

    if (lastDocument.value == null) {
      _userMessages = _chatRepository.getUserMessages(_authService.user.value.id);
    } else {
      _userMessages = _chatRepository.getUserMessagesStartAt(_authService.user.value.id, lastDocument.value!);
    }

    _userMessages.listen((QuerySnapshot query) {
      if (query.docs.isNotEmpty) {
        query.docs.forEach((element) {
          Message newMessage = Message.fromDocumentSnapshot(element);
          if (!messages.any((msg) => msg.id == newMessage.id)) {
            messages.add(newMessage);
          }
        });
        lastDocument.value = query.docs.last;
      } else {
        isDone.value = true;
      }
      isLoading.value = false;
    });
  }

  listenForChats() async {
    message.value = await _chatRepository.getMessage(message.value);
    message.value.readByUsers.add(_authService.user.value.id);
    _chatRepository.getChats(message.value).listen((event) {
      chats.assignAll(event);
    });
  }

  void addMessage(Message _message, String text) {
    Chat _chat = Chat(text, DateTime.now().millisecondsSinceEpoch, _authService.user.value.id, _authService.user.value);

    if (!_message.hasData) {
      _message.id = UniqueKey().toString();
      createMessage(_message);
    }

    _message.lastMessage = text;
    _message.lastMessageTime = _chat.time;
    _message.readByUsers = [_authService.user.value.id];
    uploading.value = false;

    _chatRepository.addMessage(_message, _chat).then((value) {
      List<User> _users = List.from(_message.users);
      _users.removeWhere((element) => element.id == _authService.user.value.id);
      _notificationRepository.sendNotification(
        _users,
        _authService.user.value,
        "App\\Notifications\\NewMessage",
        text,
        _message.id,
      );

      // Refresh messages after sending
      refreshMessages();
    });
  }

  Future getImage(ImageSource source, Message _message) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;

    // Picking the image
    pickedFile = await imagePicker.pickImage(source: source);
    imageFile = pickedFile != null ? File(pickedFile.path) : null;

    // If an image is selected
    if (imageFile != null) {
      try {
        uploading.value = true;

        // Step 1: Upload the image and get the download URL
        String fileUrl = await _chatRepository.uploadFile(imageFile!);

        // Step 2: Create a Chat object for the image
        Chat _chat = Chat(fileUrl, DateTime.now().millisecondsSinceEpoch, _authService.user.value.id, _authService.user.value);

        // Step 3: Set the image URL as the last message text in _message
        _message.lastMessage = fileUrl;  // Set the image URL in the message
        _message.users.insert(0, _authService.user.value);  // Insert the current user at the start
        _message.lastMessageTime = _chat.time;  // Update the last message time
        _message.readByUsers = [_authService.user.value.id];  // Mark it as read by the current user

        message.value = _message;  // Update the message value

        // Step 4: Save the message to Firestore
        await _chatRepository.createMessage(_message);

        // Step 5: Add the message with the chat to Firestore
        await _chatRepository.addMessage(_message, _chat);

        // Step 6: Send notifications (if necessary)
        List<User> _users = List.from(_message.users);
        _users.removeWhere((element) => element.id == _authService.user.value.id);
        _notificationRepository.sendNotification(
          _users,
          _authService.user.value,
          "App\\Notifications\\NewMessage",
          fileUrl, // The file URL as the notification message
          _message.id,
        );

        // Step 7: Refresh messages after sending
        refreshMessages();

      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      } finally {
        uploading.value = false;
      }
    }
  }

  Future<void> pickAndUploadFile(Message _message) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      File selectedFile = File(result.files.single.path!);

      try {
        uploading.value = true;

        // Step 1: Upload the file and get the download URL
        String fileUrl = await _chatRepository.uploadFile(selectedFile);

        // Step 2: Ensure the message has an ID (if new, generate one)
        if (_message.id == null || _message.id!.isEmpty) {
          _message.id = FirebaseFirestore.instance.collection('messages').doc().id;
        }

        // Step 3: Create a Chat object for the file attachment
        Chat _chat = Chat(
          fileUrl,
          DateTime.now().millisecondsSinceEpoch,
          _authService.user.value.id,
          _authService.user.value,
        );

        // Step 4: Update the message object
        _message.lastMessage = "File: ${result.files.single.name}";
        _message.users.insert(0, _authService.user.value);
        _message.lastMessageTime = _chat.time;
        _message.readByUsers = [_authService.user.value.id];

        message.value = _message;

        // Step 5: Save the message and chat to Firestore
        await _chatRepository.createMessage(_message);
        await _chatRepository.addMessage(_message, _chat);

        // Step 6: Send a notification to other users
        List<User> _users = List.from(_message.users);
        _users.removeWhere((element) => element.id == _authService.user.value.id);
        _notificationRepository.sendNotification(
          _users,
          _authService.user.value,
          "App\\Notifications\\NewMessage",
          "File: ${result.files.single.name}",
          _message.id,
        );

        // Step 7: Refresh the chat messages
        listenForMessages();

      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      } finally {
        uploading.value = false;
      }
    }
  }




}
