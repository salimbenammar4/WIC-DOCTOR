/*
 * Copyright (c) 2020 .
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../search/controllers/search_controller.dart' as searchController;
import 'circular_loading_widget.dart';

class FilterBottomSheetWidget extends GetView<searchController.SearchController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height - 300,
      decoration: BoxDecoration(
        color: Get.theme.primaryColor,
        borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Get.theme.focusColor.withOpacity(0.4), blurRadius: 30, offset: Offset(0, -30)),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 90),
            child: ListView(
              padding: EdgeInsets.only(top: 20, bottom: 15, left: 4, right: 4),
              children: [
                Obx(() {
                  if (controller.specialities.isEmpty) {
                    return CircularLoadingWidget(height: 50);
                  }
                  return ExpansionTile(
                    title: Text("Specialities".tr, style: Get.textTheme.bodyMedium),
                    children: List.generate(controller.specialities.length, (index) {
                      var _speciality = controller.specialities.elementAt(index);
                      return Obx(() {
                        return CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.trailing,
                          value: controller.selectedSpecialities.contains(_speciality.id),
                          onChanged: (value) {
                            controller.toggleSpeciality(value!, _speciality);
                          },
                          title: Text(
                            _speciality.name,
                            style: Get.textTheme.bodyLarge,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            maxLines: 1,
                          ),
                        );
                      });
                    }),
                    initiallyExpanded: false,
                  );
                }),
                Obx(() {
                  if (controller.regions.isEmpty) {
                    return CircularLoadingWidget(height: 100);
                  }
                  return ExpansionTile(
                    title: Text("Gouvernorats".tr, style: Get.textTheme.bodyMedium),
                    children: List.generate(controller.regions.length, (index) {
                      var region = controller.regions[index];
                      return Obx(() {
                        return CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.trailing,
                          value: controller.selectedRegions.contains(region),
                          onChanged: (value) {
                            controller.toggleRegion(value!, region);
                          },
                          title: Text(
                            region,
                            style: Get.textTheme.bodyLarge,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            maxLines: 1,
                          ),
                        );
                      });
                    }),
                    initiallyExpanded: false,
                  );
                }),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 45),
            child: Row(
              children: [
                Expanded(child: Text("Filter".tr, style: Get.textTheme.headlineSmall)),
                MaterialButton(
                  onPressed: () {
                    controller.searchDoctors(keywords: controller.textEditingController.text);
                    Get.back();
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  color: Get.theme.colorScheme.secondary.withOpacity(0.15),
                  child: Text("Apply".tr, style: Get.textTheme.titleMedium),
                  elevation: 0,
                ),
              ],
            ),
          ),
          Container(
            height: 30,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 13, horizontal: (Get.width / 2) - 30),
            decoration: BoxDecoration(
              color: Get.theme.focusColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Get.theme.focusColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(3),
              ),
              //child: SizedBox(height: 1,),
            ),
          ),
        ],
      ),
    );
  }
}
