import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/ui.dart';
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
        decoration: Ui.getBoxDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                ClipRRect(
                  borderRadius:
                  BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  child: CachedNetworkImage(
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    imageUrl: _appointment.doctor?.firstImageThumb ?? '',
                    placeholder: (context, url) => Image.asset(
                      'assets/img/loading.gif',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 80,
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error_outline),
                  ),
                ),
                if (_appointment.payment != null)
                  Container(
                    width: 80,
                    child: Text(
                      _appointment.payment?.paymentStatus.status ?? '',
                      style: Get.textTheme.bodySmall?.merge(
                        TextStyle(fontSize: 10),
                      ),
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                    ),
                    decoration: BoxDecoration(
                      color: Get.theme.focusColor.withOpacity(0.2),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                  ),
                Container(
                  width: 80,
                  child: Column(
                    children: [
                      Text(
                        DateFormat('HH:mm', Get.locale.toString())
                            .format(_appointment.appointmentAt!),
                        maxLines: 1,
                        style: Get.textTheme.bodyMedium?.merge(
                          TextStyle(color: Get.theme.primaryColor, height: 1.4),
                        ),
                        softWrap: false,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade,
                      ),
                      Text(
                        DateFormat('dd', Get.locale.toString())
                            .format(_appointment.appointmentAt!),
                        maxLines: 1,
                        style: Get.textTheme.displaySmall?.merge(
                          TextStyle(color: Get.theme.primaryColor, height: 1),
                        ),
                        softWrap: false,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade,
                      ),
                      Text(
                        DateFormat('MMM', Get.locale.toString())
                            .format(_appointment.appointmentAt!),
                        maxLines: 1,
                        style: Get.textTheme.bodyMedium?.merge(
                          TextStyle(color: Get.theme.primaryColor, height: 1),
                        ),
                        softWrap: false,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade,
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: _color,
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                ),
              ],
            ),
            SizedBox(width: 12),
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
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined, // Calendar icon for the date
                          size: 18,
                          color: Get.theme.focusColor,
                        ),
                        SizedBox(width: 5),
                        Flexible(
                          child: Row(
                            children: [
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


                    // Button Row (separated from address)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
