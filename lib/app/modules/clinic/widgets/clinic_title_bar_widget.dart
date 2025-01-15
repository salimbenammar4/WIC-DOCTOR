import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClinicTitleBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;

  const ClinicTitleBarWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Get.theme.focusColor.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: title, // Directly using the `title` widget
    );
  }

  @override
  Size get preferredSize => Size(Get.width, 110);
}
