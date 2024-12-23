import 'package:get/get.dart';

import '../../../../common/ui.dart';
import '../../../models/award_model.dart';
import '../../../models/clinic_model.dart';
import '../../../models/doctor_model.dart';
import '../../../models/experience_model.dart';
import '../../../models/media_model.dart';
import '../../../models/message_model.dart';
import '../../../models/review_model.dart';
import '../../../models/user_model.dart';
import '../../../repositories/clinic_repository.dart';
import '../../../routes/app_routes.dart';
import 'review_controller.dart';

class ClinicController extends GetxController {
  final clinic = Clinic().obs;
  final reviews = <Review>[].obs;
  final awards = <Award>[].obs;
  final galleries = <Media>[].obs;
  final experiences = <Experience>[].obs;
  final featuredDoctors = <Doctor>[].obs;
  final currentSlide = 0.obs;
  String heroTag = "";
  late ClinicRepository _clinicRepository;
  late final ReviewsController reviewController;

  // Constructor
  ClinicController() {
    _clinicRepository = ClinicRepository();
  }

  @override
  void onInit() {
    super.onInit();
    getFeaturedDoctors();
    print("onInit called");
    var arguments = Get.arguments as Map<String, dynamic>;
    clinic.value = arguments['clinic'] as Clinic;
    heroTag = arguments['heroTag'] as String;
    print("Clinic onInit: ${clinic.value.name}"); // Check if this prints
    reviewController = Get.put(ReviewsController());
    getReviews();
  }

  void refreshReviews() async {
    try {
      await getReviews();
      update();  // Call update to trigger the UI update in GetX
    } catch (error) {
      print("Error refreshing reviews: $error");
      Get.showSnackbar(Ui.ErrorSnackBar(message: error.toString()));
    }
  }


  @override
  void onReady() async {
    super.onReady();
    await getFeaturedDoctors();
    print("ClinicController is ready, fetching data...");
    await fetchClinicData(); // Fetch data when the controller is ready
    print("fetchClinicData() called");
  }

  // Method to refresh clinic data and related information
  Future refreshClinic({bool showMessage = false}) async {
    await fetchClinicData(); // Call the fetch method
    await getFeaturedDoctors();
    await getAwards();
    // Uncomment this line if you have experience data
    // await getExperiences();
    await getGalleries();
    await getReviews();
    if (showMessage) {
      Get.showSnackbar(
        Ui.SuccessSnackBar(
          message: "${clinic.value.name} page refreshed successfully".tr,
        ),
      );
    }
  }

  // Fetch clinic data
  Future<void> fetchClinicData() async {
    try {
      var clinicData = await _clinicRepository.get(clinic.value.id);
      clinic.value = clinicData; // Assign data to observable
      print("Fetched clinic data: ${clinic.value.name}"); // This should print the clinic name
      print("Clinic Data after fetch: ${clinic.value.toJson()}"); // This should print the entire clinic object
    } catch (error) {
      print("Error fetching clinic data: $error"); // Print error if it occurs
      Get.showSnackbar(Ui.ErrorSnackBar(message: error.toString()));
    }
  }

  // Fetch featured doctors
  Future<void> getFeaturedDoctors() async {
    try {
      var doctors = await _clinicRepository.getFeaturedDoctors(clinic.value.id, page: 1);
      featuredDoctors.assignAll(doctors);
      featuredDoctors.refresh();
      print("Fetched featured doctors: ${featuredDoctors.length}");

    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  // Fetch reviews
  Future<void> getReviews() async {
    try {
      print("Fetched reviews0: ${reviews.length}");
      var reviewList = await _clinicRepository.getReviews(clinic.value.id);
      reviews.assignAll(reviewList);
      clinic.value.reviews=reviewList;
      print("Fetched reviews: ${reviews.length}");
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }

  }

  // Fetch awards
  Future<void> getAwards() async {
    try {
      var awardList = await _clinicRepository.getAwards(clinic.value.id);
      awards.assignAll(awardList);
      print("Fetched awards: ${awards.length}");
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  // Fetch galleries
  Future<void> getGalleries() async {
    try {
      final _galleries = await _clinicRepository.getGalleries(clinic.value.id);
      galleries.assignAll(_galleries.map((e) {
        e.image.name = e.description;
        return e.image;
      }));
      print("Fetched galleries: ${galleries.length}");
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  // Start chat
  void startChat() {
    List<User> _employees = clinic.value.employees.map((e) {
      e.avatar = clinic.value.images[0];
      return e;
    }).toList();
    Message _message = new Message(_employees, name: clinic.value.name);
    Get.toNamed(Routes.CHAT, arguments: _message);
  }

}
