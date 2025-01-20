import 'package:get/get.dart';

import '../../home/controllers/home_controller.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(),
    );

  }
}
