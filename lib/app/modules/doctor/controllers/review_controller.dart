import 'package:get/get.dart';
import '../../../../common/ui.dart';
import '../../../models/review_model.dart';
import '../../../repositories/clinic_repository.dart';
import '../../../repositories/doctor_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

class ReviewsController extends GetxController {
  final reviews = <Review>[].obs;
  final isLoading = false.obs;
  late ClinicRepository _clinicRepository;
  late DoctorRepository _doctorRepository;

  // Constructor
  ReviewsController() {
    _doctorRepository = DoctorRepository();
  }

  @override
  void onInit() {
    super.onInit();
    user: Get.find<AuthService>().user.value;
  }



  // Add a Doctor Review
  Future addDoctorReview(Review review) async {
    try {
      print("REVIEWW-----");
      // Check if the user is authenticated
      if (!Get.find<AuthService>().isAuth) {
        print("REVIEWW-----11111111");
        // Redirect to the login screen
        Get.toNamed(Routes.LOGIN); // Adjust the route to your login screen
        return; // Exit the method early
      }

      // Include authenticated user's ID in the review object
      review.user = Get.find<AuthService>().user.value;
      print("REVIEWW2222222222222-----");
      // Add the review via the repository
      var newReview = await _doctorRepository.addReview(review);

      // Update the local reviews list with the new review
      reviews.insert(0, newReview);
      print("REVIEWW3333333333333333333-----");
      // Show success message
      Get.showSnackbar(Ui.SuccessSnackBar(message: "Review added successfully".tr));
    } catch (e) {
      // Show error message
      print("REVIEWW--888888888888888---");
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }


}
