import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/ui.dart';
import '../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';

class RecommendedDoctorsCarouselWidget extends GetWidget<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      child: Obx(() {
        return ListView.builder(
          padding: EdgeInsets.only(bottom: 10),
          primary: false,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: controller.doctors.length,
          itemBuilder: (_, index) {
            var _doctor = controller.doctors.elementAt(index);
            return GestureDetector(
              onTap: () {
                Get.toNamed(Routes.DOCTOR, arguments: {'doctor': _doctor, 'heroTag': 'recommended_carousel'});
              },
              child: Container(
                width: 220,
                margin: EdgeInsetsDirectional.only(end: 20, start: index == 0 ? 20 : 0, top: 20, bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(color: Get.theme.focusColor.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                  ],
                ),
                child: Column(
                  children: [
                    Hero(
                      tag: 'recommended_carousel' + _doctor.id,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                        child: CachedNetworkImage(
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          imageUrl: _doctor.firstImageUrl,
                          placeholder: (context, url) => Image.asset(
                            'assets/img/loading.gif',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 100,
                          ),
                          errorWidget: (context, url, error) => Icon(Icons.error_outline),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Adjusted padding
                      decoration: BoxDecoration(
                        color: Get.theme.primaryColor,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // Prevent overflow
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 110,
                                child: Text(
                                  _doctor.name ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Get.textTheme.bodyMedium?.merge(TextStyle(color: Get.theme.hintColor)),
                                ),
                              ),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 5,
                                children: [
                                  SizedBox(
                                    height: 32,
                                    child: Chip(
                                      elevation: 0,
                                      padding: EdgeInsets.all(0),
                                      label: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.star,
                                            color: Color(0xFFFFB24D),
                                            size: 18,
                                          ),
                                          Text(
                                            _doctor.rate.toString(),
                                            style: Get.textTheme.bodyMedium?.merge(TextStyle(color: Color(0xFFFFB24D), height: 1.4)),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Color(0xFFFFB24D).withOpacity(0.15),
                                      shape: StadiumBorder(side: BorderSide(color: Colors.transparent)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 5), // Space between old price and "Start from"

                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Color(0xFF18167A),
                                size: 18,
                              ),
                              SizedBox(width: 5), // Space between the icon and the text
                              Expanded( // This allows the text to take up the remaining space
                                child: Text(
                                  _doctor.address!.ville,
                                  style: Get.textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis, // Ensure long addresses are truncated
                                  maxLines: 1, // Limit to a single line
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
          },
        );
      }),
    );
  }
}
