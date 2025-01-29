import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:url_launcher/url_launcher.dart';
import '../../../models/appointment_model.dart';
import '../../../routes/app_routes.dart';
import 'appointment_options_popup_menu_widget.dart';
import 'dart:developer';

class AppointmentsListItemWidget extends StatelessWidget {
  const AppointmentsListItemWidget({
    Key? key,
    required Appointment appointment,
  })  : _appointment = appointment,
        super(key: key);

  final Appointment _appointment;

  @override
  Widget build(BuildContext context) {
    log('Appointment Details: ${_appointment.toJson()}');
    Color _color =
    _appointment.cancel ? Get.theme.focusColor : Get.theme.colorScheme.secondary;

    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.APPOINTMENT, arguments: _appointment);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Get.theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF18167A),
              blurRadius: 2.0,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Opacity(
                opacity: _appointment.cancel ? 0.3 : 1,
                child: Wrap(
                  runSpacing: 10,
                  alignment: WrapAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.medical_services_outlined,
                                size: 18,
                                color: Get.theme.focusColor,
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  _appointment.doctor?.name ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: Get.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppointmentOptionsPopupMenuWidget(appointment: _appointment),
                      ],
                    ),
                    Divider(height: 8, thickness: 1, color: Get.theme.dividerColor),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 18,
                          color: Get.theme.focusColor,
                        ),
                        SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "${_appointment.patient?.first_name ?? ''} ${_appointment.patient?.last_name ?? ''}",
                            style: Get.textTheme.bodyLarge,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: Get.theme.focusColor,
                        ),
                        SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            _appointment.doctor?.address?.address ?? '',
                            style: Get.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 8, thickness: 1, color: Get.theme.dividerColor),
                    // Address Row
// Address Row with centered date and time
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Center content in this row
                            children: [
                              Icon(
                                Icons.calendar_today_outlined, // Calendar icon for the date
                                size: 18,
                                color: Get.theme.focusColor,
                              ),
                              SizedBox(width: 5),
                              Text(
                                _appointment.startAt != null
                                    ? '${DateFormat('dd-MM-yyyy').format(_appointment.startAt!.toLocal())}'
                                    : '',
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: Get.textTheme.bodyLarge,
                              ),
                              if (_appointment.startAt != null) ...[
                                SizedBox(width: 20), // Add spacing between the date and time
                                Icon(
                                  Icons.access_time_outlined, // Clock icon for the time
                                  size: 18,
                                  color: Get.theme.focusColor,
                                ),
                                SizedBox(width: 5), // Add spacing after the clock icon
                                Text(
                                  '${DateFormat('HH:mm').format(_appointment.startAt!.toLocal())}',
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: Get.textTheme.bodyLarge,
                                ),
                              ],
                              if (_appointment.startAt != null && _appointment.endsAt != null) ...[
                                SizedBox(width: 5), // Add spacing before the arrow icon
                                Icon(
                                  Icons.arrow_forward, // Arrow icon
                                  size: 18,
                                  color: Get.theme.focusColor,
                                ),
                                SizedBox(width: 5), // Add spacing after the arrow icon
                                Text(
                                  '${DateFormat('HH:mm').format(_appointment.endsAt!.toLocal())}',
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: Get.textTheme.bodyLarge,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 8, thickness: 1, color: Get.theme.dividerColor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the button row
                      children: [
                        Visibility(
                          visible: !_appointment.cancel, // Hide button if the appointment is canceled
                          child: (_appointment.doctor?.address?.address == null)
                              ? Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Adresse non trouvée",
                              style: Get.textTheme.bodySmall?.copyWith(color: Colors.black),
                            ),
                          )
                              : ElevatedButton(
                            onPressed: () async {
                              // Construct the Google Maps URL
                              final Uri googleMapsUrl = Uri.parse(
                                "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(_appointment.doctor?.address?.address ?? '')}",
                              );

                              // Check if the URL can be launched
                              if (await canLaunchUrl(googleMapsUrl)) {
                                await launchUrl(googleMapsUrl);
                              } else {
                                Get.snackbar("Error", "Could not launch map");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Get.theme.colorScheme.primary,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.map_outlined, // Google Maps icon
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8), // Space between icon and text
                                Text(
                                  "Open in Maps".tr,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),


                    // Button Row (separated from address)


                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
