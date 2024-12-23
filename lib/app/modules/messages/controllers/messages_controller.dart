import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  Future getImage(ImageSource source) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;

    pickedFile = await imagePicker.pickImage(source: source);
    imageFile = pickedFile != null ? File(pickedFile.path) : null;

    if (imageFile != null) {
      try {
        uploading.value = true;
        await _chatRepository.uploadFile(imageFile!);
      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      } finally {
        uploading.value = false;
      }
    } else {
      Get.showSnackbar(Ui.ErrorSnackBar(message: "Please select an image file".tr));
    }
  }
}
