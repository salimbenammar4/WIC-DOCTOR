import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../common/ui.dart';
import '../../../models/appointment_model.dart';
import '../../../providers/laravel_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../services/settings_service.dart';
import '../../global_widgets/block_button_widget.dart';
import '../controllers/book_doctor_controller.dart';
import '../widgets/payment_details_widget.dart';
import '../../../models/doctor_model.dart';

class AppointmentSummaryView extends GetView<BookDoctorController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Appointment Summary".tr,
            style: context.textTheme.titleLarge,
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios, color: Get.theme.hintColor),
            onPressed: () => Get.back(),
          ),
          elevation: 0,
        ),
        bottomNavigationBar: buildBottomWidget(controller.appointment.value),
        body: ListView(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: Ui.getBoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Appointment At".tr, style: Get.textTheme.bodyLarge),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: Get.theme.focusColor),
                      SizedBox(width: 15),
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${DateFormat.yMMMMEEEEd(Get.locale.toString()).format(controller.appointment.value.startAt!)}', style: Get.textTheme.bodyMedium),
                              Text('${DateFormat('HH:mm', Get.locale.toString()).format(controller.appointment.value.startAt!)}', style: Get.textTheme.bodyMedium),
                            ],
                          )),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: Ui.getBoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Patient".tr, style: Get.textTheme.bodyLarge),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.group_outlined, color: Get.theme.focusColor),
                      SizedBox(width: 15),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                                controller.appointment.value.patient?.first_name ?? '',
                                style: Get.textTheme.bodyMedium
                              // textAlign: TextAlign.end,
                            ),
                            SizedBox(width: 3,),
                            Text(
                                controller.appointment.value.patient?.last_name ?? '',
                                style: Get.textTheme.bodyMedium
                              // textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: Ui.getBoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Doctor".tr, style: Get.textTheme.bodyLarge),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.assignment_ind_outlined, color: Get.theme.focusColor),
                      SizedBox(width: 15),
                      Expanded(child:Text(controller.appointment.value.doctor!.name, style: Get.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: Ui.getBoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Address".tr, style: Get.textTheme.bodyLarge),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.place_outlined, color: Get.theme.focusColor),
                      SizedBox(width: 15),
                      Expanded(
                        child: Obx(() {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (controller.appointment.value.doctor?.address?.description != null)
                                Text(
                                  controller.appointment.value.address!.description,
                                  style: Get.textTheme.bodyMedium,
                                )
                              else
                                Text(
                                  "Doctor's address".tr,
                                  style: Get.textTheme.bodyMedium,
                                ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),


            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: Ui.getBoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("A Hint for the Doctor".tr, style: Get.textTheme.bodyLarge),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.description_outlined, color: Get.theme.focusColor),
                      SizedBox(width: 15),
                      Expanded(
                        child: Obx(() {
                          String hint = controller.appointment.value.hint;
                          return Text(
                            hint.isNotEmpty ? hint : "No hint".tr,
                            style: Get.textTheme.bodyMedium,
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget buildBottomWidget(Appointment _appointment) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PaymentDetailsWidget(appointment: _appointment),
          if((Get.find<SettingsService>().setting.value.enablePaymentBeforeAppointmentIsCompleted ?? false) == false)
            Obx(() {
            return BlockButtonWidget(
                text: Stack(
                  alignment: AlignmentDirectional.centerEnd,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Confirm the Appointment".tr,
                        textAlign: TextAlign.center,
                        style: Get.textTheme.titleLarge?.merge(
                          TextStyle(color: Get.theme.primaryColor),
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Get.theme.primaryColor, size: 20)
                  ],
                ),
                color: Get.theme.colorScheme.secondary,
                onPressed: Get.find<LaravelApiClient>().isLoading(task: "addAppointment")
                    ? null
                    : () {
                        controller.createAppointment();
                      });
          }).paddingSymmetric(vertical: 10, horizontal: 20)
          else
            BlockButtonWidget(
                text: Stack(
                  alignment: AlignmentDirectional.centerEnd,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Confirm & Checkout".tr,
                        textAlign: TextAlign.center,
                        style: Get.textTheme.titleLarge?.merge(
                          TextStyle(color: Get.theme.primaryColor),
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Get.theme.primaryColor, size: 20)
                  ],
                ),
                color: Get.theme.colorScheme.secondary,
                onPressed: () async {
                  await Get.toNamed(Routes.CHECKOUT, arguments: _appointment);
                }).paddingSymmetric(vertical: 10, horizontal: 20),
        ],
      ),
    );
  }
}
