/*
 * Copyright (c) 2020 .
 */

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/ui.dart';
import '../../../models/patient_model.dart';
import '../../../routes/app_routes.dart';

class PatientsListItemWidget extends StatelessWidget {
  const PatientsListItemWidget({
    Key? key,
    required Patient patient,
  })  : _patient = patient,
        super(key: key);

  final Patient _patient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.PATIENT, arguments: {'patient': _patient, 'heroTag': 'patient'});
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: Ui.getBoxDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: CachedNetworkImage(
                height: 90,
                width: 80,
                fit: BoxFit.cover,
                imageUrl: _patient.firstImageThumb,
                placeholder: (context, url) => Image.asset(
                  'assets/img/loading.gif',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error_outline),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Wrap(
                runSpacing: 10,
                alignment: WrapAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              _patient.first_name ?? '',
                              style: Get.textTheme.bodyMedium,
                              maxLines: 3,
                            ),
                            SizedBox(width: 3),
                            Text(
                              _patient.last_name ?? '',
                              style: Get.textTheme.bodyMedium,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 2, thickness: 1, color: Get.theme.dividerColor),
                  Row(
                    children: [
                      Icon(
                        Icons.account_box,
                        size: 18,
                        color: Get.theme.focusColor,
                      ),
                      SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          _patient.getAge(_patient.date_naissance).toString()+" years old".tr,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Get.textTheme.bodyLarge,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.male_rounded,
                        size: 18,
                        color: Get.theme.focusColor,
                      ),
                      SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          _patient.gender.tr,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Get.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 2, thickness: 1, color: Get.theme.dividerColor),
                  Row(
                    children: [
                      Icon(
                        Icons.monitor_weight_outlined,
                        size: 18,
                        color: Get.theme.focusColor,
                      ),
                      SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          _patient.weight + '(KG)',
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Get.textTheme.bodyLarge,
                        ),
                      ),
                      SizedBox(width: 5), // Space between weight and height
                      Icon(
                        Icons.height,
                        size: 18,
                        color: Get.theme.focusColor,
                      ),
                      SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          _patient.height + '(CM)',
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Get.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
String getTranslatedText(Map<String, dynamic>? translations) {
  String langCode = Get.locale?.languageCode ?? 'en'; // Default to 'en'
  return translations?[langCode] ?? translations?['en'] ?? '';
}

