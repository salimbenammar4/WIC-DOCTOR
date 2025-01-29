import 'package:get/get.dart';

import '../../messages/controllers/messages_controller.dart';
import '../controllers/doctor_controller.dart';

class DoctorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorController>(
      () => DoctorController(),
    );
    Get.put(MessagesController());
  }
}
