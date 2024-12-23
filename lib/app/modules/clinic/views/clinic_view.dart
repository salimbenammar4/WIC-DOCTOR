import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../common/map.dart';
import '../../../../common/ui.dart';
import '../../../models/clinic_model.dart';
import '../../../models/media_model.dart';
import '../../../providers/laravel_provider.dart';
import '../../../routes/app_routes.dart';
import '../../global_widgets/circular_loading_widget.dart';
import '../controllers/clinic_controller.dart';
import '../widgets/clinic_til_widget.dart';
import '../widgets/clinic_title_bar_widget.dart';
import '../widgets/featured_carousel_widget.dart';
import '../widgets/review_item_widget.dart';
import '../widgets/review_popup.dart';

class ClinicView extends GetView<ClinicController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var _clinic = controller.clinic.value;
      if (_clinic.name.isEmpty) {
        return Text('No data');
      } else {
        return Scaffold(
          body: RefreshIndicator(
              onRefresh: () async {
                Get.find<LaravelApiClient>().forceRefresh();
                controller.refreshClinic(showMessage: true);
                Get.find<LaravelApiClient>().unForceRefresh();
              },
              child: CustomScrollView(
                primary: true,
                shrinkWrap: false,
                slivers: <Widget>[
                  SliverAppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    expandedHeight: 310,
                    elevation: 0,
                    floating: true,
                    iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    leading: new IconButton(
                      icon: new Icon(Icons.arrow_back_ios, color: Get.theme.hintColor),
                      onPressed: () => Get.back(),
                    ),
                    bottom: buildClinicTitleBarWidget(_clinic),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Obx(() {
                        return Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: <Widget>[
                            buildCarouselSlider(_clinic),
                            buildCarouselBullets(_clinic),
                          ],
                        );
                      }),
                    ).marginOnly(bottom: 50),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 10),
                        buildContactUs(),
                        ClinicTilWidget(
                          title: Text("Description".tr, style: Get.textTheme.titleSmall),
                          content: Ui.applyHtml(_clinic.description ?? '', style: Get.textTheme.bodyLarge),
                        ),
                        buildAddress(context),
                        buildAwards(),
                        ClinicTilWidget(
                          horizontalPadding: 0,
                          title: Text("Featured Doctors".tr, style: Get.textTheme.titleSmall).paddingSymmetric(horizontal: 20),
                          content: FeaturedCarouselWidget(),
                          actions: [
                            InkWell(
                              onTap: () {
                                Get.toNamed(Routes.CLINIC_DOCTORS, arguments: _clinic);
                              },
                              child: Text("View All".tr, style: Get.textTheme.titleMedium),
                            ).paddingSymmetric(horizontal: 20),
                          ],
                        ),
                        buildGalleries(),
                        ClinicTilWidget(

                          title: Text("Reviews & Ratings".tr, style: Get.textTheme.titleSmall),
                          content: Column(
                            children: [
                              Text(_clinic.rate.toString(), style: Get.textTheme.displayLarge),
                              Wrap(
                                children: Ui.getStarsList(_clinic.rate, size: 32),
                              ),
                              Text(
                                "Reviews (%s)".trArgs([_clinic.totalReviews.toString()]),
                                style: Get.textTheme.bodySmall,
                              ).paddingOnly(top: 10),
                              Divider(height: 35, thickness: 1.3, color: Get.theme.dividerColor),
                              Obx(() {
                                if (controller.reviews.isEmpty) {
                                  return CircularLoadingWidget(height: 100);
                                }
                                return ListView.separated(
                                  padding: EdgeInsets.all(0),
                                  itemBuilder: (context, index) {
                                  print("----review-------");
                                  print(controller.reviews.elementAt(index));
                                    return ReviewItemWidget(review: controller.reviews.elementAt(index));
                                  },
                                  separatorBuilder: (context, index) {
                                    return Divider(height: 35, thickness: 1.3, color: Get.theme.dividerColor);
                                  },
                                  itemCount: controller.reviews.length,
                                  primary: false,
                                  shrinkWrap: true,
                                );
                              }),
                              SizedBox(height: 20), // Add spacing before the button
                              ElevatedButton(
                                onPressed: () {
                                  // Open the review popup
                                  Get.bottomSheet(
                                    ReviewPopupWidget(
                                      clinic: _clinic,
                                      onReviewAdded: () {
                                        Get.find<LaravelApiClient>().forceRefresh();
                                        controller.refreshClinic(showMessage: true);
                                        Get.find<LaravelApiClient>().unForceRefresh();
                                      },
                                    ),
                                    isScrollControlled: true,
                                    backgroundColor: Get.theme.primaryColor,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Get.theme.colorScheme.primary, // Apply the same primary color style
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.rate_review_outlined, // Icon for review button
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8), // Space between icon and text
                                    Text(
                                      'Ajouter un avis',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              )

                            ],
                          ),
                          actions: [
                            // TODO view all reviews
                          ],
                        ),

                      ],
                    ),
                  ),
                ],
              )),
        );
      }
    });
  }

  Widget buildGalleries() {
    return Obx(() {
      if (controller.galleries.isEmpty) {
        return SizedBox();
      }
      return ClinicTilWidget(
        horizontalPadding: 0,
        title: Text("Galleries".tr, style: Get.textTheme.titleSmall).paddingSymmetric(horizontal: 20),
        content: Container(
          height: 120,
          child: ListView.builder(
              primary: false,
              shrinkWrap: false,
              scrollDirection: Axis.horizontal,
              itemCount: controller.galleries.length,
              itemBuilder: (_, index) {
                var _media = controller.galleries.elementAt(index);
                return InkWell(
                  onTap: () {
                    Get.toNamed(Routes.GALLERY, arguments: {'media': controller.galleries, 'current': _media, 'heroTag': 'e_provide_galleries'});
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsetsDirectional.only(end: 20, start: index == 0 ? 20 : 0, top: 10, bottom: 10),
                    child: Stack(
                      alignment: AlignmentDirectional.topStart,
                      children: [
                        Hero(
                          tag: 'e_provide_galleries' + _media.id,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: CachedNetworkImage(
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              imageUrl: _media.thumb,
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
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 12, top: 8),
                          child: Text(
                            _media.name ?? '',
                            maxLines: 2,
                            style: Get.textTheme.bodyMedium?.merge(TextStyle(color: Get.theme.primaryColor)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
        actions: [
          // TODO show all galleries
        ],
      );
    });
  }

  Widget buildAwards() {
    return Obx(() {
      if (controller.awards.isEmpty) {
        return SizedBox(height: 0);
      }
      return ClinicTilWidget(
        title: Text("Awards".tr, style: Get.textTheme.titleSmall),
        content: ListView.separated(
          padding: EdgeInsets.zero,
          primary: false,
          shrinkWrap: true,
          itemCount: controller.awards.length,
          separatorBuilder: (context, index) {
            return Divider(height: 16, thickness: 0.8,color: Get.theme.dividerColor,);
          },
          itemBuilder: (context, index) {
            var _award = controller.awards.elementAt(index);
            return Column(
              children: [
                Text(_award.title ?? '').paddingSymmetric(vertical: 5),
                Ui.applyHtml(
                  _award.description ?? '',
                  style: Get.textTheme.bodySmall,
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            );
          },
        ),
      );
    });
  }

  Container buildContactUs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: Ui.getBoxDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Contact us".tr, style: Get.textTheme.titleSmall),
                Text("If your have any question!".tr, style: Get.textTheme.bodySmall),
              ],
            ),
          ),
          Wrap(
            spacing: 5,
            children: [

              MaterialButton(
                onPressed: () {
                  launchUrlString("tel:${controller.clinic.value.phoneNumber}");
                },
                height: 44,
                minWidth: 44,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: Get.theme.colorScheme.secondary.withOpacity(0.2),
                child: Icon(
                  Icons.call_outlined,
                  color: Get.theme.colorScheme.secondary,
                ),
                elevation: 0,
              ),
              MaterialButton(
                onPressed: () {
                  controller.startChat();
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: Get.theme.colorScheme.secondary.withOpacity(0.2),
                padding: EdgeInsets.zero,
                height: 44,
                minWidth: 44,
                child: Icon(
                  Icons.chat_outlined,
                  color: Get.theme.colorScheme.secondary,
                ),
                elevation: 0,
              ),
            ],
          )
        ],
      ),
    );
  }

  Container buildAddress(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: Ui.getBoxDecoration(),
      child: (controller.clinic.value.address == null)
          ? Container(
        width: double.infinity,
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          "Adresse non trouvée",
          style: Get.textTheme.bodySmall?.copyWith(color: Colors.black),
        ),
      )
          : Column(
        children: [
          // Address container with button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Get.theme.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Location".tr, style: Get.textTheme.titleSmall),
                      SizedBox(height: 5),
                      Text(
                        controller.clinic.value.address!.address,
                        style: Get.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    // Open Google Maps with clinic location
                    MapsUtil.openMapsSheet(
                      context,
                      controller.clinic.value.address!.getLatLng(),
                      controller.clinic.value.name,
                    );
                  },
                  height: 44,
                  minWidth: 44,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Get.theme.colorScheme.secondary.withOpacity(0.2),
                  child: Icon(
                    Icons.map_outlined,
                    color: Get.theme.colorScheme.secondary,
                  ),
                  elevation: 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }






  CarouselSlider buildCarouselSlider(Clinic _clinic) {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 7),
        height: 360,
        viewportFraction: 1.0,
        onPageChanged: (index, reason) {
          controller.currentSlide.value = index;
        },
      ),
      items: _clinic.images.map((Media media) {
        return Builder(
          builder: (BuildContext context) {
            return Hero(
              tag: controller.heroTag + _clinic.id,
              child: CachedNetworkImage(
                width: double.infinity,
                height: 360,
                fit: BoxFit.cover,
                imageUrl: media.url,
                placeholder: (context, url) => Image.asset(
                  'assets/img/loading.gif',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error_outline),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Container buildCarouselBullets(Clinic _clinic) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _clinic.images.map((Media media) {
          return Container(
            width: 20.0,
            height: 5.0,
            margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 2.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: controller.currentSlide.value == _clinic.images.indexOf(media) ? Get.theme.hintColor : Get.theme.primaryColor.withOpacity(0.4)),
          );
        }).toList(),
      ),
    );
  }

  ClinicTitleBarWidget buildClinicTitleBarWidget(Clinic _clinic) {
    return ClinicTitleBarWidget(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _clinic.name ?? '',
                  style: Get.textTheme.headlineSmall?.merge(TextStyle(height: 1.1)),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.fade,
                ),
              ),
              Container(
                child: Text(_clinic.level.name.tr,
                    maxLines: 1,
                    style: Get.textTheme.bodyMedium?.merge(
                      TextStyle(color: Get.theme.colorScheme.secondary, height: 1.4, fontSize: 10),
                    ),
                    softWrap: false,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.fade),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ],
          ),
          Row(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: List.from(Ui.getStarsList(_clinic.rate))
                        ..addAll([
                          SizedBox(width: 5),
                          Text(
                            "Reviews (%s)".trArgs([_clinic.totalReviews.toString()]),
                            style: Get.textTheme.bodySmall,
                          ),
                        ]),
                    ),
                  ),
                  Text(
                    "Appointments (%s)".trArgs([_clinic.total_appointments.toString()]),
                    style: Get.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
