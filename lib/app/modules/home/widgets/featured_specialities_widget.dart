import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'doctors_carousel_widget.dart';

import '../../../routes/app_routes.dart';
import '../../global_widgets/circular_loading_widget.dart';
import '../controllers/home_controller.dart';

class FeaturedSpecialitiesWidget extends GetWidget<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.featured.isEmpty) {
        return CircularLoadingWidget(height: 300);
      }
      return Column(
        children: List.generate(controller.featured.length, (index) {
          var _speciality = controller.featured.elementAt(index);
          return Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  children: [
                    Expanded(child: Text(_speciality.name, style: Get.textTheme.headlineSmall)),
                    MaterialButton(
                      onPressed: () {
                        Get.toNamed(Routes.SPECIALITY, arguments: _speciality);
                      },
                      shape: StadiumBorder(side: BorderSide(color: Colors.transparent)),
                      color: Get.theme.colorScheme.secondary.withOpacity(0.1),
                      child: Text("View All".tr, style: Get.textTheme.titleMedium),
                      elevation: 0,
                    ),
                  ],
                ),
              ),
              Obx(() {
                if (controller.featured.elementAt(index).doctors.isEmpty) {
                  return Text('loading...');
                }
                return DoctorsCarouselWidget(doctors: controller.featured.elementAt(index).doctors);
              }),
            ],
          );
        }),
      );
    });
  }
}
