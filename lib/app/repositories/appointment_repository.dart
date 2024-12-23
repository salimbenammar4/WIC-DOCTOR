import 'package:get/get.dart';

import '../models/appointment_model.dart';
import '../models/appointment_status_model.dart';
import '../models/coupon_model.dart';
import '../models/review_model.dart';
import '../providers/laravel_provider.dart';

class AppointmentRepository {
  late LaravelApiClient _laravelApiClient;

  AppointmentRepository() {
    this._laravelApiClient = Get.find<LaravelApiClient>();
  }

  Future<List<Appointment>> all(String statusId, {int page = 1}) {
    return _laravelApiClient.getAppointments(statusId, page);
  }

  Future<List<AppointmentStatus>> getStatuses() {
    return _laravelApiClient.getAppointmentStatuses();
  }

  Future<Appointment> get(String appointmentId) {
    return _laravelApiClient.getAppointment(appointmentId);
  }

  Future<Appointment> add(Appointment appointment) {
    return _laravelApiClient.addAppointment(appointment);
  }

  Future<Appointment> update(Appointment appointment) {
    return _laravelApiClient.updateAppointment(appointment);
  }

  Future<Coupon> coupon(Appointment appointment) {
    return _laravelApiClient.validateCoupon(appointment);
  }

  Future<Review> addDoctorReview(Review review) {
    return _laravelApiClient.addDoctorReview(review);
  }

  Future<Review> addClinicReview(Review review) {
    return _laravelApiClient.addClinicReview(review);
  }
  Future<List<Appointment>> getAppointmentsByIds(List<String> appointmentIds) async {
    List<Appointment> appointments = [];

    for (String id in appointmentIds) {
      try {
        Appointment appointment = await get(id);
        appointments.add(appointment);
        print("------------APPOINTMENT------------");
        print(appointments);
      } catch (e) {
        // Handle any errors (e.g., if an appointment ID is invalid)
        print("Error fetching appointment with ID $id: $e");
      }
    }

    return appointments;
  }
}
