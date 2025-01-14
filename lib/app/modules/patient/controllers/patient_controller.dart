  import 'package:get/get.dart';
  import 'package:intl/intl.dart';

  import '../../../../common/ui.dart';
  import '../../../models/doctor_model.dart';
  import '../../../models/patient_model.dart';
  import '../../../repositories/doctor_repository.dart';
  import '../../../repositories/patient_repository.dart';

  class PatientController extends GetxController {
    final patient = Patient().obs;
    final heroTag = ''.obs;
    final currentSlide = 0.obs;
    final recentDoctors = <Doctor>[].obs;
    final totalAppointments = 0.obs;
    late PatientRepository _patientRepository;
    late DoctorRepository _doctorRepository;

    PatientController() {
      _patientRepository = new PatientRepository();
      _doctorRepository = new DoctorRepository();
    }

    @override
    void onInit() async {
      var arguments = Get.arguments as Map<String, dynamic>;
      patient.value = arguments['patient'] as Patient;
      heroTag.value = arguments['heroTag'] as String;
      super.onInit();
      await getTotalAppointments();
      await getRecentDoctors();
    }

    @override
    void onReady() async {
      await refreshPatient();
      super.onReady();
      await getTotalAppointments();
    }

    Future refreshPatient({bool showMessage = false}) async {
      await getPatient();
      await getRecentDoctors();
      if (showMessage) {
        Get.showSnackbar(Ui.SuccessSnackBar(message: (patient.value.first_name! + " " + patient.value.last_name!) + " " + "page refreshed successfully".tr));
      }

    }

    Future getPatient() async{
      try {
        patient.value = await _patientRepository.get(patient.value.id);
      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }



    Future<void> getRecentDoctors() async {
      try {
        // Fetch the doctors for the current patient
        var doctors = await _doctorRepository.getRecentDoctorsOfPatient(patient.value.id);

        // Update the list with the fetched doctors
        recentDoctors.assignAll(doctors);  // This will now be a List<Doctor> with all the fields populated

      } catch (e) {
        // Handle errors
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }


    Future<void> getTotalAppointments() async {
      try {
        int total = await _patientRepository.getTotalAppointments(patient.value.id);

        // Update the patient's total_appointments using the setter
        patient.update((patient) {
          patient?.total_appointments = total;
        });
      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    }


  }