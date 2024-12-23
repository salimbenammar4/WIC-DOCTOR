import 'dart:convert'; // Add this import to use jsonDecode
import 'package:flutter/material.dart';
import 'doctor_model.dart';
import 'clinic_model.dart';
import 'speciality_model.dart';
import 'parents/model.dart';

class Pattern extends Model {
  String? _nom;
  Speciality? _speciality;
  double? _price;
  Doctor? _doctor;
  Clinic? _clinic;
  Color? _color;

  Pattern({
    String? id,
    String? nom,
    Speciality? speciality,
    double? price,
    Doctor? doctor,
    Clinic? clinic,
    Color? color,
  }) {
    this.id = id;
    _nom = nom;
    _speciality = speciality;
    _price = price;
    _doctor = doctor;
    _clinic = clinic;
    _color = color;
  }

  // Factory constructor for creating a Pattern instance from JSON
  Pattern.fromJson(Map<String, dynamic>? json) {
    this.id = transStringFromJson(json, 'id');
    _nom = _parseNom(json?['nom']);  // Decode and parse the 'nom' field
    _speciality = json?['speciality'] != null
        ? Speciality.fromJson(json?['speciality'])
        : null;
    _price = doubleFromJson(json, 'price');
    _doctor = json?['doctor'] != null ? Doctor.fromJson(json?['doctor']) : null;
    _clinic = json?['clinic'] != null ? Clinic.fromJson(json?['clinic']) : null;
    _color = json?['color'] != null
        ? Color(int.parse(json?['color']))
        : null;
    super.fromJson(json);
  }

  // Parse the 'nom' field, which is a JSON string
  String? _parseNom(String? nomJson) {
    if (nomJson == null) return null;
    try {
      // Decode the JSON string into a Map
      final Map<String, dynamic> nomMap = jsonDecode(nomJson);
      return nomMap['fr']; // Return the value for 'fr' key
    } catch (e) {
      print('Error decoding nom field: $e');
      return null;
    }
  }

  // Convert Pattern instance to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.id != null) data['id'] = this.id;
    if (_nom != null) data['nom'] = _nom; // The 'nom' will be stored as a string after decoding
    if (_speciality != null) data['speciality'] = _speciality!.toJson();
    if (_price != null) data['price'] = _price;
    if (_doctor != null) data['doctor'] = _doctor!.toJson();
    if (_clinic != null) data['clinic'] = _clinic!.toJson();
    if (_color != null) {
      data['color'] = _color!.value.toRadixString(16).padLeft(8, '0');
    }
    return data;
  }

  // Getters and Setters
  String get nom => _nom ?? '';
  set nom(String value) {
    _nom = value;
  }

  Speciality? get speciality => _speciality;
  set speciality(Speciality? value) {
    _speciality = value;
  }

  double get price => _price ?? 0;
  set price(double value) {
    _price = value;
  }

  Doctor? get doctor => _doctor;
  set doctor(Doctor? value) {
    _doctor = value;
  }

  Clinic? get clinic => _clinic;
  set clinic(Clinic? value) {
    _clinic = value;
  }

  Color? get color => _color;
  set color(Color? value) {
    _color = value;
  }

  String? get doctorId => _doctor?.id;

  @override
  int get hashCode =>
      id.hashCode ^ _nom.hashCode ^ _doctor.hashCode;

  @override
  bool get hasData {
    return super.hasData && _nom != null && _price != null;
  }
}
