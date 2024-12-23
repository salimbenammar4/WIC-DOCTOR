import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/ui.dart';
import '../../../models/doctor_model.dart';
import '../../../routes/app_routes.dart';

class DoctorsCarouselWidget extends StatelessWidget {
  final List<Doctor> doctors;

  const DoctorsCarouselWidget({Key? key, required List<Doctor> this.doctors})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: ListView.builder(
          padding: EdgeInsets.only(bottom: 10),
          primary: false,
          shrinkWrap: false,
          scrollDirection: Axis.horizontal,
          itemCount: doctors.length,
          itemBuilder: (_, index) {
            var _doctor = doctors.elementAt(index);
            return GestureDetector(
              onTap: () {
                Get.toNamed(Routes.DOCTOR, arguments: {
                  'doctor': _doctor,
                  'heroTag': 'doctors_carousel'
                });
              },
              child: Container(
                width: 220,
                margin: EdgeInsetsDirectional.only(
                    end: 20, start: index == 0 ? 20 : 0, top: 20, bottom: 10),
                // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                        color: Get.theme.focusColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5)),
                  ],
                ),
                child: Column(
                  //alignment: AlignmentDirectional.topStart,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      child: CachedNetworkImage(
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        imageUrl: _doctor.firstImageUrl,
                        placeholder: (context, url) => Image.asset(
                          'assets/img/loading.gif',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 100,
                        ),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error_outline),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 10),
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Get.theme.primaryColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            _doctor.name,
                            maxLines: 1,
                            style: Get.textTheme.bodyMedium
                                ?.merge(TextStyle(color: Get.theme.hintColor)),
                          ),
                          // Wrap(
                          //   children: Ui.getStarsList(_doctor.rate)
                          // ).marginZero,
                          //SizedBox(height: 10),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 5,
                            children: [
                              SizedBox(
                                height: 32,
                                child: Chip(
                                  padding: EdgeInsets.all(0),
                                  label: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.star,
                                        color: Get.theme.colorScheme.secondary,
                                        size: 18,
                                      ),
                                      Text(_doctor.rate.toString(),
                                          style: Get.textTheme.bodyMedium
                                              ?.merge(TextStyle(
                                                  color: Get.theme.colorScheme
                                                      .secondary,
                                                  height: 1.4))),
                                    ],
                                  ),
                                  backgroundColor: Get
                                      .theme.colorScheme.secondary
                                      .withOpacity(0.15),
                                  shape: StadiumBorder(side: BorderSide(color: Colors.transparent)),
                                ),
                              )
                            ],
                          ),
                          Wrap(
                            spacing: 5,
                            alignment: WrapAlignment.spaceBetween,
                            direction: Axis.horizontal,
                            crossAxisAlignment: WrapCrossAlignment.end,
                            children: [
                              Text(
                                "Start from".tr,
                                style: Get.textTheme.bodySmall,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (_doctor.getOldPrice > 0)
                                    Ui.getPrice(
                                      _doctor.getOldPrice,
                                      style: Get.textTheme.bodyLarge?.merge(
                                          TextStyle(
                                              color: Get.theme.focusColor,
                                              decoration:
                                                  TextDecoration.lineThrough)),
                                    ),
                                  Ui.getPrice(
                                    _doctor.getPrice,
                                    style: Get.textTheme.bodyMedium?.merge(
                                        TextStyle(
                                            color: Get
                                                .theme.colorScheme.secondary)),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
