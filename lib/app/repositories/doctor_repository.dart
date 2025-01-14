import 'package:get/get.dart';

import '../models/doctor_model.dart';
import '../models/experience_model.dart';
import '../models/favorite_model.dart';
import '../models/review_model.dart';
import '../providers/laravel_provider.dart';
import '../models/pattern_model.dart';
class DoctorRepository {
  late LaravelApiClient _laravelApiClient;

  DoctorRepository() {
    this._laravelApiClient = Get.find<LaravelApiClient>();
  }

  Future<List<Doctor>> getAllWithPagination(String specialityId, {int page = 1}) {
    return _laravelApiClient.getAllDoctorsWithPagination(specialityId, page);
  }

  Future<List<Doctor>> search(String? keywords, List<String> specialities, {int page = 1}) {
    return _laravelApiClient.searchDoctors(keywords, specialities, page);
  }

  Future<List<Favorite>> getFavorites() {
    return _laravelApiClient.getFavoritesDoctors();
  }


  Future<List<Experience>> getExperiences(String doctorId) {
    return _laravelApiClient.getDoctorExperiences(doctorId);
  }

  Future<Favorite> addFavorite(Favorite favorite) {
    return _laravelApiClient.addFavoriteDoctor(favorite);
  }

  Future<bool> removeFavorite(Favorite favorite) {
    return _laravelApiClient.removeFavoriteDoctor(favorite);
  }

  Future<List<Doctor>> getRecommended() {
    return _laravelApiClient.getRecommendedDoctors();
  }

  Future<List<Doctor>> getFeatured(String specialityId, {int page = 1}) {
    return _laravelApiClient.getFeaturedDoctors(specialityId, page);
  }

  Future<List<Doctor>> getPopular(String specialityId, {int page = 1}) {
    return _laravelApiClient.getPopularDoctors(specialityId, page);
  }

  Future<List<Doctor>> getMostRated(String specialityId, {int page = 1}) {
    return _laravelApiClient.getMostRatedDoctors(specialityId, page);
  }

  Future<List<Doctor>> getAvailable(String specialityId, {int page = 1}) {
    return _laravelApiClient.getAvailableDoctors(specialityId, page);
  }

  Future<Doctor> get(String id) {
    return _laravelApiClient.getDoctor(id);
  }

  Future<List<Review>> getReviews(String doctorId) {
    return _laravelApiClient.getDoctorReviews(doctorId);
  }

  Future<List> getAvailabilityHours(String doctorId, DateTime date, bool online) {
    Get.log("sssssssssssssssssssssssss");
    return _laravelApiClient.getAvailabilityHours(doctorId, date, online);
  }

  Future<List<Doctor>> getRecentDoctorsOfPatient(String id) {
    return _laravelApiClient.getRecentDoctorsOfPatient(id);
  }

  Future<List<Pattern>> getPatterns(String doctorId){
    return _laravelApiClient.getPatterns(doctorId);
  }

  Future <Review> addReview (Review review){
    return _laravelApiClient.addDoctorReview(review);
  }
}
