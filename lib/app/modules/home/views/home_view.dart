import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../providers/laravel_provider.dart';
import '../../../services/settings_service.dart';
import '../controllers/home_controller.dart';
import '../widgets/specialities_carousel_widget.dart';
import '../widgets/featured_specialities_widget.dart';
import '../widgets/recommended_doctors_carousel_widget.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Get.find<SettingsService>().setting.value.appName ?? '',
          style: Get.textTheme.titleLarge,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Get.theme.hintColor),
          onPressed: () => {Scaffold.of(context).openDrawer()},
        ),
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            Get.find<LaravelApiClient>().forceRefresh();
            controller.refreshHome(showMessage: true);
            Get.find<LaravelApiClient>().unForceRefresh();
          },
          child: ListView(
            primary: true,
            shrinkWrap: true,
            children: [ //WelcomeWidget(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  children: [
                    Expanded(child: Text("Specialities".tr, style: Get.textTheme.headlineSmall)),
                    MaterialButton(
                      onPressed: () {},
                      shape: StadiumBorder(side: BorderSide(color: Colors.transparent)),
                      color: Get.theme.colorScheme.secondary.withOpacity(0.1),
                      child: Text("View All".tr, style: Get.textTheme.titleMedium),
                      elevation: 0,
                    ),
                  ],
                ),
              ),
              SpecialitiesCarouselWidget(),
              /*Container(
                color: Get.theme.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  children: [
                    Expanded(child: Text("Recommended for you".tr, style: Get.textTheme.headlineSmall)),
                    MaterialButton(
                      onPressed: () {},
                      shape: StadiumBorder(side: BorderSide(color: Colors.transparent)),
                      color: Get.theme.colorScheme.secondary.withOpacity(0.1),
                      child: Text("View All".tr, style: Get.textTheme.titleMedium),
                      elevation: 0,
                    ),
                  ],
                ),
              ),*/
              RecommendedDoctorsCarouselWidget(),
              FeaturedSpecialitiesWidget(),
            ],
          )),
    );
  }
}
