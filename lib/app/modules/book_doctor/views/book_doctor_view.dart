/*Brought back to life by:
* SALIM BEN AMMAR
* */

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../common/ui.dart';
import '../../../models/appointment_model.dart';
import '../../../providers/laravel_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../services/settings_service.dart';
import '../../global_widgets/block_button_widget.dart';
import '../../global_widgets/tab_bar_widget.dart';
import '../../global_widgets/text_field_widget.dart';
import '../../patient/controllers/create_patient_controller.dart';
import '../../patient/views/create_patient_view_from_Book_Doctor.dart';
import '../controllers/book_doctor_controller.dart';
import '../widgets/dropdownlist.dart';

class BookDoctorView extends GetView<BookDoctorController> {
  final RxString selectedPatternId = ''.obs;
  @override
  Widget build(BuildContext context) {
    void refreshData() {
      // Call the existing method that reloads your data
      controller.refreshPatients(); // Replace with your actual method to fetch data
      // Use this if you're using GetBuilder to update the UI
    }
    return RefreshIndicator(
      onRefresh: () async {
        if (!Get.find<LaravelApiClient>().isLoading(task: 'getAllPatientsWithUserId')) {

          Get.find<LaravelApiClient>().forceRefresh();
          controller.refreshPatients();
          controller.getTimes(date:controller.selectedDate);
          Get.find<LaravelApiClient>().unForceRefresh();
        }
        print("patternaaaaaaaaaaaaaaaaaaaaaaa");
        print(controller.patterns);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Complete your Appointment".tr,
            style: context.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF18167A),
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          elevation: 0,
        ),
        bottomNavigationBar:
        buildBlockButtonWidget(controller.appointment.value),
        body: ListView(
          children: [
            Obx(() {
              var _patients = controller.patients;
              if (_patients.length == 0) {
                return Container(
                  decoration: Ui.getBoxDecoration(),
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(child: Text("Create a Patient".tr, style: Get.textTheme.bodyLarge)).paddingOnly(top: 14.0),
                      MaterialButton(
                        padding: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),

                        onPressed: () {
                          // Ensure the controller is initialized
                          if (!Get.isRegistered<CreatePatientController>()) {
                            Get.put(CreatePatientController());
                          }

                          // Navigate to the view
                          Get.to(() => CreatePatientViewFromBookDoctorView())?.then((result) {
                            if (result != null && result['refresh'] == true) {
                              // Trigger refresh logic
                              refreshData();
                            }
                          });
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        color: Get.theme.colorScheme.secondary.withOpacity(0.1),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          children: [
                            Text("Add".tr, style: Get.textTheme.titleMedium),
                            Icon(
                              Icons.add_circle_outline,
                              color: Get.theme.colorScheme.secondary,
                              size: 20,
                            ),
                          ],
                        ),
                        elevation: 0,
                      ),
                    ],
                  ),
                );
              }
              else {
                return Container(
                  decoration: Ui.getBoxDecoration(),
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose patient'.tr,
                          style: Get.textTheme.bodyMedium,
                        ),
                        SizedBox(height: 10),
                        Obx(() {
                          return ListView.separated(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: false,
                            padding: EdgeInsets.zero,
                            itemCount: controller.patients.length,
                            separatorBuilder: (context, index) {
                              return SizedBox(height: 6);
                            },
                            itemBuilder: (context, index) {
                              var _patient = controller.patients.elementAt(index);
                              return GestureDetector(
                                onTap: () {
                                  controller.selectPatient(_patient);
                                  controller.appointment.update((val) {
                                    val!.patient = _patient;
                                  });
                                },
                                child: Obx(() {
                                  return Container(
                                    padding:
                                    EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Stack(
                                          alignment:
                                          AlignmentDirectional.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                              BorderRadius.all(
                                                  Radius.circular(10)),
                                              child: CachedNetworkImage(
                                                height: 42,
                                                width: 42,
                                                fit: BoxFit.cover,
                                                imageUrl: _patient.images.first.thumb,
                                                placeholder: (context, url) => Image.asset('assets/img/loading.gif', fit: BoxFit.cover, height: 42, width: 42,),
                                                errorWidget: (context, url, error) => Icon(Icons.error_outline),
                                              ),
                                            ),
                                            Container(
                                              height: 42,
                                              width: 42,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.all(Radius.circular(10)),
                                                color: Get.theme.colorScheme.secondary.withOpacity(controller.isCheckedPatient(_patient) ? 0.8 : 0),
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                size: 28,
                                                color: Theme.of(context).primaryColor.withOpacity(controller.isCheckedPatient(_patient) ? 1 : 0),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Text(_patient.first_name ??"", style: controller.getTitleTheme(_patient)
                                                // textAlign: TextAlign.end,
                                              ),
                                              SizedBox(
                                                width: 3,
                                              ),
                                              Text(_patient.last_name ?? "", style: controller.getTitleTheme(_patient)
                                                // textAlign: TextAlign.end,
                                              ),
                                            ],
                                          ).paddingOnly(bottom: 5),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                );}
            }),

            Obx(() {
              if (!controller.appointment.value.canAppointmentAtClinic) return SizedBox();
              final ThemeData theme = ThemeData();
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: Ui.getBoxDecoration(color: controller.getColor(controller.atClinic.value)),
                child: Theme(
                  data: theme.copyWith(
                    switchTheme: SwitchThemeData(
                      thumbColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return null;
                            }
                            if (states.contains(WidgetState.selected)) {
                              return Get.theme.primaryColor;
                            }
                            return null;
                          }),
                      trackColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return null;
                            }
                            if (states.contains(WidgetState.selected)) {
                              return Get.theme.primaryColor;
                            }
                            return null;
                          }),
                    ),
                    radioTheme: RadioThemeData(
                      fillColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return null;
                            }
                            if (states.contains(WidgetState.selected)) {
                              return Get.theme.primaryColor;
                            }
                            return null;
                          }),
                    ),
                    checkboxTheme: CheckboxThemeData(
                      fillColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return null;
                            }
                            if (states.contains(WidgetState.selected)) {
                              return Get.theme.primaryColor;
                            }
                            return null;
                          }),
                    ),
                  ),
                  child: RadioListTile(
                    value: true,
                    groupValue: controller.atClinic.value,
                    onChanged: (value) {
                      controller.appointment.update((val) {
                        // val!.address = controller.appointment.value.clinic.address;
                        // //Get.find<TabBarController>(tag: 'addresses').selectedId = RxString("");
                      });
                      controller.appointment.value.address = controller.appointment.value.clinic.address;
                      print(controller.appointment.value.address?.address ?? "there is no address");
                      controller.toggleAtClinic(value);
                    },
                    title: Text("At the office".tr, style: controller.getTextTheme(controller.atClinic.value)).paddingSymmetric(vertical: 20),
                  ),
                ),
              );
            }),
            Obx(() {
              if (!controller.appointment.value.canOnlineConsultation) return SizedBox();
              final ThemeData theme = ThemeData();
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: Ui.getBoxDecoration(color: controller.getColor(controller.onlineConsultation.value)),
                child: Theme(
                  data: theme.copyWith(
                    switchTheme: SwitchThemeData(
                      thumbColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return null;
                            }
                            if (states.contains(WidgetState.selected)) {
                              return Get.theme.primaryColor;
                            }
                            return null;
                          }),
                      trackColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return null;
                            }
                            if (states.contains(WidgetState.selected)) {
                              return Get.theme.primaryColor;
                            }
                            return null;
                          }),
                    ),
                    radioTheme: RadioThemeData(
                      fillColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return null;
                            }
                            if (states.contains(WidgetState.selected)) {
                              return Get.theme.primaryColor;
                            }
                            return null;
                          }),
                    ),
                    checkboxTheme: CheckboxThemeData(
                      fillColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return null;
                            }
                            if (states.contains(WidgetState.selected)) {
                              return Get.theme.primaryColor;
                            }
                            return null;
                          }),
                    ),
                  ),

                  child: RadioListTile(
                    value: true,
                    groupValue: controller.onlineConsultation.value,
                    onChanged: (value) {
                      controller.toggleOnline(value);
                      controller.appointment.value.address = controller.appointment.value.clinic.address;
                      print(controller.appointment.value.address?.address ?? "there is no address");
                    },
                    title: Text("Online Consultation".tr,
                        style: controller.getTextTheme(
                            controller.onlineConsultation.value))
                        .paddingSymmetric(vertical: 20),
                  ),
                ),
              );
            }),
            Obx(() {
              return AnimatedOpacity(
                opacity: controller.atAddress.value ? 1 : 0,
                duration: Duration(milliseconds: 300),
                child: AnimatedContainer(
                  height: controller.atAddress.value ? 230 : 0,
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: controller.atClinic.value ? 0 : 10),
                  padding: EdgeInsets.symmetric(
                      vertical: controller.atClinic.value ? 0 : 20),
                  decoration: Ui.getBoxDecoration(),
                  child: ListView(
                    primary: false,
                    shrinkWrap: true,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 20),
                          Expanded(
                              child: Text("Your Addresses".tr,
                                  style: Get.textTheme.bodyLarge)),
                          SizedBox(width: 4),
                          MaterialButton(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 14),
                            onPressed: () {
                              Get.toNamed(Routes.SETTINGS_ADDRESS_PICKER);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            color: Get.theme.colorScheme.secondary
                                .withOpacity(0.1),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              children: [
                                Text("New".tr,
                                    style: Get.textTheme.titleMedium),
                                Icon(
                                  Icons.my_location,
                                  color: Get.theme.colorScheme.secondary,
                                  size: 20,
                                ),
                              ],
                            ),
                            elevation: 0,
                          ),
                          SizedBox(width: 20),
                        ],
                      ),
                      SizedBox(height: 10),
                      Obx(() {
                        Get.put(TabBarController(), tag: 'hours');
                        if (controller.addresses.isEmpty) {
                          return TabBarLoadingWidget();
                        } else {
                          return TabBarWidget(
                            initialSelectedId: "",
                            tag: 'addresses',
                            tabs: List.generate(controller.addresses.length, (index) {
                              final _address = controller.addresses.elementAt(index);
                              return ChipWidget(
                                tag: 'addresses',
                                text: _address.description,
                                id: index,
                                onSelected: (id) {
                                  controller.appointment.update((val) {
                                    val!.address = _address;
                                  });
                                  Get.find<SettingsService>().address.value =
                                      _address;
                                },
                              );
                            }),
                          );
                        }
                      }),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          SizedBox(width: 20),
                          Icon(Icons.place_outlined,
                              color: Get.theme.focusColor),
                          SizedBox(width: 15),
                          Expanded(
                            child: Obx(() {
                              return Text(
                                  controller.appointment.value.address
                                      ?.address ??
                                      "Select an address".tr,
                                  style: Get.textTheme.bodyMedium);
                            }),
                          ),
                          SizedBox(width: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            Container(

              decoration: Ui.getBoxDecoration(),
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: DatePicker(
                      DateTime.now(),
                      width: 60,
                      height: 90,
                      daysCount: 30,
                      controller: controller.datePickerController,
                      initialSelectedDate: DateTime.now(),
                      selectionColor: Get.theme.colorScheme.secondary,
                      selectedTextColor: Get.theme.primaryColor,
                      locale: Get.locale.toString(),
                      onDateChange: (date) async {
                        // New date selected
                        Get.find<TabBarController>(tag: 'hours').selectedId.value = "";
                        await controller.getTimes(date: date);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
                    child: Center(
                      child: Text(
                        "Available Times".tr,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          fontSize: 20,  // Adjust the font size as needed
                          fontWeight: FontWeight.bold, // Make it bolder if desired
                        ),
                      ),
                    ),
                  ),
                  Obx(() {
                    // Combine all available times into one list
                    List<List<dynamic>> allAvailableTimes = [
                      ...controller.morningTimes,
                      ...controller.afternoonTimes,
                      ...controller.eveningTimes,
                      ...controller.nightTimes
                    ];

                    // Debugging: Print the available times
                    print("All Available Times: $allAvailableTimes");

                    // Show loading state until data is available
                    if (controller.isLoading.value) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(3, (index) {
                            // Display loading chips (you can customize the number)
                            return RawChip(
                              side: BorderSide(color: Colors.transparent),
                              elevation: 0,
                              label: Text("Loading...", style: Get.textTheme.bodySmall),
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                              backgroundColor: Get.theme.focusColor.withOpacity(0.1),
                              selectedColor: Get.theme.colorScheme.secondary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              showCheckmark: false,
                              pressElevation: 0,
                            ).marginSymmetric(horizontal: 5);
                          }),
                        ),
                      );
                    }

                    // Debugging: Print the result after checking the available times
                    if (allAvailableTimes.isEmpty) {
                      print("No available times found.");

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Center( // Center the text horizontally
                          child: Text(
                            "Sorry, this doctor is not available on the selected date.".tr,
                            style: Get.textTheme.bodyMedium?.copyWith(color: Color(0xFF18167A)),
                            textAlign: TextAlign.center, // Center text inside the widget
                          ),
                        ),
                      );
                    }

                    // If there are available times, show them
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(allAvailableTimes.length, (index) {
                          final _time = allAvailableTimes[index].elementAt(0);
                          bool _available = allAvailableTimes[index].elementAt(1) && !allAvailableTimes[index].elementAt(2);

                          if (_available) {
                            return ChipWidget(
                              backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.2),
                              style: Get.textTheme.bodyLarge?.merge(TextStyle(color: Get.theme.colorScheme.secondary)),
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                              tag: 'hours',
                              text: DateFormat('HH:mm').format(DateTime.parse(_time).toLocal()),
                              id: _time,
                              onSelected: (id) {
                                controller.appointment.update((val) {
                                  val!.appointmentAt = DateTime.now().toLocal();
                                  val.startAt = DateTime.parse(id).toLocal();

                                  int sessionDuration = int.parse(controller.appointment.value.doctor?.sessionDuration ?? '15');
                                  val.endsAt = val.startAt!.add(Duration(minutes: sessionDuration));
                                });
                              },
                            );
                          } else {
                            return Container(); // Return an empty container for unavailable times
                          }
                        }),
                      ),
                    );
                  }),
                ],
              ),
            ),

            Obx(() {
              if (controller.patterns.isEmpty) {
                return Container(
                  padding: EdgeInsets.only(top: 20, bottom: 14, left: 20, right: 20),
                  margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10), // Direct values for margins
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                    ],
                    border: Border.all(color: Get.theme.focusColor.withOpacity(0.05)),
                  ),
                  child: Center(
                    child: Text(
                      "No patterns available".tr,
                      style: Get.textTheme.bodyLarge?.copyWith(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ); // Or some placeholder widget
              } else {
                return DropDownList(
                  patterns: controller.patterns,
                  selectedPattern: controller.appointment.value.motif,
                  onPatternSelected: (newPattern) {
                    // Update the appointment's motif field in the controller
                    controller.selectPattern(newPattern);

                    controller.appointment.update((appointment) {
                      if (appointment != null) {
                        appointment.motif = newPattern;
                      }
                      print(controller.appointment.value.motif);
                    });
                  },
                );
              }
            }),

            TextFieldWidget(
              onChanged: (input) => controller.appointment.value.hint = input,
              hintText:
              "Is there anything else you would like us to know?".tr,
              labelText: "Hint".tr,
              iconData: Icons.description_outlined,
            ),
            Obx(() {
              return TextFieldWidget(
                onChanged: (input) => controller.appointment.value.coupon?.code = input,
                hintText: "COUPON01".tr,
                labelText: "Coupon Code".tr,
                errorText: controller.getValidationMessage(),
                iconData: Icons.confirmation_number_outlined,
                style: Get.textTheme.bodyMedium?.merge(TextStyle(color: controller.getValidationMessage() != null ? Colors.redAccent : Colors.green)),
                suffixIcon: MaterialButton(
                  onPressed: () {
                    controller.validateCoupon();
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  color: Get.theme.focusColor.withOpacity(0.1),
                  child: Text("Apply".tr, style: Get.textTheme.bodyLarge),
                  elevation: 0,
                ).marginSymmetric(vertical: 4),
              );
            }),
          ],
        ),),
    );
  }

  Widget buildBlockButtonWidget(Appointment _appointment) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Get.theme.focusColor.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() {
        return BlockButtonWidget(
          text: Stack(
            alignment: AlignmentDirectional.centerEnd,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  "Continue".tr,
                  textAlign: TextAlign.center,
                  style: Get.textTheme.titleLarge?.merge(TextStyle(color: Get.theme.primaryColor)),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Get.theme.primaryColor, size: 20),
            ],
          ),
          color: Get.theme.colorScheme.secondary,
          onPressed: controller.appointment.value.motif != null &&
              controller.appointment.value.appointmentAt != null &&
              (controller.appointment.value.address != null || controller.appointment.value.canAppointmentAtClinic) &&
              Get.isRegistered<TabBarController>(tag: 'hours') &&
              Get.find<TabBarController>(tag: 'hours').initialized &&
              Get.find<TabBarController>(tag: 'hours').selectedId.value != "" &&
              (controller.appointment.value.patient != null && controller.appointment.value.patient!.hasData)
              ? () async {
            await Get.toNamed(Routes.APPOINTMENT_SUMMARY);
          }
              : null, // Button disabled when motif is null or conditions aren't met
        ).paddingOnly(right: 20, left: 20);
      }),
    );
  }
}