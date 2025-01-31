import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/doctor_model.dart';
import '../../speciality/widgets/doctors_list_item_widget.dart';
import '../../global_widgets/circular_loading_widget.dart';

class SearchServicesListWidget extends StatelessWidget {
  final List<Doctor> doctors;

  SearchServicesListWidget({Key? key, required List<Doctor> this.doctors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (this.doctors.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,  // Icon of your choice
                size: 80,           // Set the size of the icon
                color: Color(0xFF18167A), // Icon color
              ),
              SizedBox(height: 10),
              Text(
                'No matches'.tr,       // Message text
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF18167A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      } else {
        return ListView.builder(
          padding: EdgeInsets.only(bottom: 10, top: 10),
          primary: false,
          shrinkWrap: true,
          itemCount: doctors.length,
          itemBuilder: ((_, index) {
            var _doctor = doctors.elementAt(index);
            return DoctorsListItemWidget(doctor: _doctor);
          }),
        );
      }
    });
  }
}
