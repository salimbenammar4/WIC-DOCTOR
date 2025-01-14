import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../providers/laravel_provider.dart';

class PatientRepository {
  late LaravelApiClient _laravelApiClient;

  PatientRepository() {
    _laravelApiClient = Get.find<LaravelApiClient>();
  }

  Future<Patient> get(String id) {
    return _laravelApiClient.getPatient(id);
  }

  Future<List<Patient>> getWithUserId(String UserId,{int page = 1}) {
    return _laravelApiClient.getPatientsWithUserId(UserId,page);
  }

  Future<List<Patient>> getAllWithUserId(String UserId) {
    return _laravelApiClient.getAllPatientsWithUserId(UserId);
  }

  Future<int> getTotalAppointments(String patientId) async {
    return _laravelApiClient.getTotalAppointments(patientId);
  }

  Future<Patient> update(Patient patient) {
    return _laravelApiClient.updatePatient(patient);
  }

  Future<Patient> create(Patient patient) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.createPatient(patient);
  }


  Future<void> deletePatient(Patient patient) async {
    _laravelApiClient = Get.find<LaravelApiClient>();

    await _laravelApiClient.deletePatient(patient);
  }
}
