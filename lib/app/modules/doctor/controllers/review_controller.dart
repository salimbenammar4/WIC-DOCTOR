import 'package:get/get.dart';
import '../../../../common/ui.dart';
import '../../../models/review_model.dart';
import '../../../repositories/clinic_repository.dart';
import '../../../repositories/doctor_repository.dart';

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
  }



  // Add a Doctor Review
  Future<void> addDoctorReview(Review review) async {
    try {
      isLoading.value = true;
      var newReview = await _doctorRepository.addReview(review);
      reviews.insert(0, newReview); // Add the new review to the list
      Get.showSnackbar(Ui.SuccessSnackBar(message: 'Review added successfully'.tr));
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    } finally {
      isLoading.value = false;
    }
  }

}
