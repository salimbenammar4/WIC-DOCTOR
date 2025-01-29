import 'package:get/get.dart';
import '../controllers/messages_controller.dart';

class MessagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MessagesController());
    Get.lazyPut(()=>MessagesController());
  }
}
