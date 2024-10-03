import 'package:flutter/foundation.dart';

class StaffRegistrationModel {
  String surname;
  String otherNames;
  DateTime dateOfBirth;
  String idPhoto; // Base64 encoded string
  String uniqueCode;

  StaffRegistrationModel({
    required this.surname,
    required this.otherNames,
    required this.dateOfBirth,
    required this.idPhoto,
    required this.uniqueCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'Surname': surname,
      'OtherNames': otherNames,
      'DateOfBirth': dateOfBirth.toIso8601String(),
      'IDPhoto': idPhoto,
      'UniqueCode': uniqueCode,
    };
  }
}

class StaffRegistrationResponse {
  int statusCode;
  String message;
  String? employeeNumber;

  StaffRegistrationResponse({
    required this.statusCode,
    required this.message,
    this.employeeNumber,
  });

  factory StaffRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return StaffRegistrationResponse(
      statusCode: json['StatusCode'],
      message: json['Message'],
      employeeNumber: json['EmployeeNumber'],
    );
  }
}

class Staff {
  String employeeNumber;
  String surname;
  String otherNames;
  DateTime dateOfBirth;
  String idPhoto; // Base64 encoded string
  String uniqueCode;

  Staff({
    required this.employeeNumber,
    required this.surname,
    required this.otherNames,
    required this.dateOfBirth,
    required this.idPhoto,
    required this.uniqueCode,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      employeeNumber: json['EmployeeNumber'],
      surname: json['Surname'],
      otherNames: json['OtherNames'],
      dateOfBirth: DateTime.parse(json['DateOfBirth']),
      idPhoto: json['IDPhoto'],
      uniqueCode: json['UniqueCode'],
    );
  }
}

class StaffUpdateModel {
  String empNo;
  DateTime dateOfBirth;
  String idPhoto; // Base64 encoded string

  StaffUpdateModel({
    required this.empNo,
    required this.dateOfBirth,
    required this.idPhoto,
  });

  Map<String, dynamic> toJson() {
    return {
      'EmpNo': empNo,
      'DateOfBirth': dateOfBirth.toIso8601String(),
      'IDPhoto': idPhoto,
    };
  }
}

class StaffUpdateResponse {
  int statusCode;
  String message;

  StaffUpdateResponse({
    required this.statusCode,
    required this.message,
  });

  factory StaffUpdateResponse.fromJson(Map<String, dynamic> json) {
    return StaffUpdateResponse(
      statusCode: json['StatusCode'],
      message: json['Message'],
    );
  }
}

// lib/models/registration_model.dart
class RegistrationModel {
  String surname;
  String otherNames;
  String idPhoto; // This will hold the Base64-encoded image
  String uniqueCode;
  String dateOfBirth;

  RegistrationModel({
    this.surname = '',
    this.otherNames = '',
    this.idPhoto = '',
    this.uniqueCode = '',
    this.dateOfBirth = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'surname': surname,
      'otherNames': otherNames,
      'DateOfBirth': dateOfBirth,
      'idPhoto': idPhoto,
      'uniqueCode': uniqueCode,
    };
  }
}

