/*This guy was here:
* SALIM BEN AMMAR
* */

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../providers/laravel_provider.dart';
import '../../../services/settings_service.dart';
import '../../global_widgets/notifications_button_widget.dart';
import '../../global_widgets/tab_bar_widget.dart';
import '../controllers/appointments_controller.dart';
import '../widgets/appointments_list_widget.dart';

class AppointmentsView extends GetView<AppointmentsController> {
  AppointmentsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          if (!Get.find<LaravelApiClient>().isLoading(task: 'getAppointments')) {
            Get.find<LaravelApiClient>().forceRefresh();
            controller.refreshAppointments(showMessage: true, statusId: controller.currentStatus.value);
            Get.find<LaravelApiClient>().unForceRefresh();
          }
        },
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: false,
          slivers: <Widget>[
            Obx(() {
              return SliverAppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                expandedHeight: 120,
                elevation: 0.5,
                floating: false,
                iconTheme: IconThemeData(color: Get.theme.primaryColor),
                title: Text(
                  Get.find<SettingsService>().setting.value.appName ?? '',
                  style: Get.textTheme.titleLarge,
                ),
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: Icon(Icons.sort, color: Colors.black87),
                  onPressed: () => {Scaffold.of(context).openDrawer()},
                ),
                actions: [NotificationsButtonWidget()],
                bottom: controller.appointmentStatuses.isEmpty
                    ? TabBarLoadingWidget()
                    : PreferredSize(
                  preferredSize: Size.fromHeight(50), // Set a height for the dropdown
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0), // Apply horizontal padding here
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF18167A), width: 2), // Border color and width
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      ),
                      child: DropdownButton<String>(
                        value: controller.currentStatus.value, // This binds the current selected ID
                        items: controller.appointmentStatuses.reversed.map((status) {
                          return DropdownMenuItem<String>(
                            value: status.id,
                            child: Text(status.status.tr),
                          );
                        }).toList(),
                        onChanged: (selectedId) {
                          if (selectedId != null) {
                            // Ensure the controller's current status is updated
                            controller.changeTab(selectedId);
                          }
                        },
                        isExpanded: true,
                        underline: Container(), // Removes default underline
                        hint: Text("Select a status".tr), // Placeholder text
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                    ),
                  ),
                ),
              );
            }),
            SliverToBoxAdapter(
              child: Wrap(
                children: [
                  AppointmentsListWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
