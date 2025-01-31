import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/ui.dart';
import '../../../models/speciality_model.dart';
import '../../../models/doctor_model.dart';
import '../../../repositories/speciality_repository.dart';
import '../../../repositories/doctor_repository.dart';

class SearchController extends GetxController {
  final heroTag = "".obs;
  final specialities = <Speciality>[].obs;
  final selectedSpecialities = <String>[].obs;
  late TextEditingController textEditingController;

  final doctors = <Doctor>[].obs;
  late DoctorRepository _doctorRepository;
  late SpecialityRepository _specialityRepository;
  final List<String> regions = [
    "Tunis", "Ariana", "Ben Arous", "La Manouba", "Nabeul", "Zaghouan",
    "Bizerte", "Beja", "Jendouba", "Kef", "Siliana", "Sousse",
    "Monastir", "Mahdia", "Kairouan", "Kasserine", "Sidi Bouzid",
    "Sfax", "Gabes", "Medenine", "Tataouine", "Gafsa", "Tozeur", "Kebili"
  ].obs;
  final RxList<String> selectedRegions = <String>[].obs;
  SearchController() {
    _doctorRepository = new DoctorRepository();
    _specialityRepository = new SpecialityRepository();
    textEditingController = new TextEditingController();
  }

  @override
  void onInit() async {
    super.onInit();
    textEditingController.text = ""; // Initialize with default text
    await getSpecialities(); // Ensure specialities are loaded before searching
    await searchDoctors(keywords: textEditingController.text);
  }

  @override
  void onReady() {
    if (Get.arguments != null){
      heroTag.value = Get.arguments as String;
    }
    super.onReady();
  }

  Future refreshSearch({bool? showMessage}) async {
    await getSpecialities();
    await searchDoctors();
    if (showMessage == true) {
      Get.showSnackbar(Ui.SuccessSnackBar(message: "List of doctors refreshed successfully".tr));
    }
  }

  Future searchDoctors({String? keywords}) async {
    try {
      List<String> specialitiesToFilter = selectedSpecialities.isEmpty
          ? specialities.map((element) => element.id).toList()
          : selectedSpecialities.toList();

      doctors.assignAll(await _doctorRepository.search(
        keywords,
        specialitiesToFilter,
        regions: selectedRegions.toList(), // ✅ Use named argument for regions
        page: 1, // ✅ Use named argument for page
      ));
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  Future getSpecialities() async {
    try {
      specialities.assignAll(await _specialityRepository.getAllParents());
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    }
  }

  bool isSelectedSpeciality(Speciality speciality) {
    return selectedSpecialities.contains(speciality.id);
  }

  void toggleSpeciality(bool value, Speciality speciality) {
    if (value) {
      selectedSpecialities.add(speciality.id);
    } else {
      selectedSpecialities.removeWhere((element) => element == speciality.id);
    }
  }

  void toggleRegion(bool selected, String region) {
    if (selected) {
      selectedRegions.add(region);
    } else {
      selectedRegions.remove(region);
    }
  }
}
