import 'dart:convert';
import 'package:dfcu_hris/models/models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://10.68.17.75:5000/api';
  final String secret_key = 'your_secure_server_key';

  Future<http.Response> registerStaff(Map<String, dynamic> staffData) async {
    var url = Uri.parse('$baseUrl/Staff/register');

    try {
      // Log the request details
      print('Making POST request to $url');
      print('Request body: ${jsonEncode(staffData)}');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $secret_key',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(staffData),
      );

      // Log the response details
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response;
    } catch (error) {
      // Log the error if any
      print('Error during POST request: $error');
      rethrow;
    }
  }

  Future<http.Response> getStaff(String employeeNumber) async {
    var url = Uri.parse('$baseUrl/Staff?employeeNumber=$employeeNumber');

    try {
      // Log the request details
      print('Making GET request to $url');
      final headers = {
        'Authorization': 'Bearer $secret_key', // Include authorization header
        'Content-Type': 'application/json', // Add other headers as necessary
      };
      final response = await http.get(url,headers: headers);

      // Log the response details
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response;
    } catch (error) {
      // Log the error if any
      print('Error during GET request: $error');
      rethrow;
    }
  }

  Future<http.Response> updateStaff(Map<String, dynamic> staffData) async {
    var url = Uri.parse('$baseUrl/Staff/update');

    try {
      // Log the request details
      print('Making PUT request to $url');
      print('Request body: ${jsonEncode(staffData)}');

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $secret_key',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(staffData),
      );

      // Log the response details
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response;
    } catch (error) {
      // Log the error if any
      print('Error during PUT request: $error');
      rethrow;
    }
  }

  Future<http.Response> getAllStaff() async {
    var url = Uri.parse('$baseUrl/Staff');

    try {
      // Log the request details
      print('Making GET request to $url');
      final headers = {
        'Authorization': 'Bearer $secret_key', // Include authorization header
        'Content-Type': 'application/json', // Add other headers as necessary
      };

      final response = await http.get(url,headers: headers);

      // Log the response details
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response;
    } catch (error) {
      // Log the error if any
      print('Error during GET request: $error');
      rethrow;
    }
  }
}

