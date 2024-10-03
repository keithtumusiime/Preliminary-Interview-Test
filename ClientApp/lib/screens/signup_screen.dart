import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dfcu_hris/screens/staff_details.dart';
import 'package:flutter/material.dart';
import 'package:dfcu_hris/theme/theme.dart';
import 'package:dfcu_hris/widgets/custom_scaffold.dart';
import 'package:image_picker/image_picker.dart';

import '../api_service.dart';
import '../models/models.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool agreePersonalData = true;
  final _registrationFormKey = GlobalKey<FormState>();
  RegistrationModel registrationModel = RegistrationModel();
  File? _imageFile;
  TextEditingController dobController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  @override
  void initState() {
    super.initState();

    // Generate the unique code and set it in the text field when the page opens
    String uniqueCode = generateUniqueCode();
    codeController.text = uniqueCode;
    registrationModel.uniqueCode = uniqueCode;
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      // Convert image to Base64 string
      final bytes = await pickedFile.readAsBytes();
      registrationModel.idPhoto = base64Encode(bytes);
    }
  }
  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        // Format the date and update the controller and model
        dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
        registrationModel.dateOfBirth = dobController.text; // Update the model
      });
    }
  }
  String generateUniqueCode() {
    // Get the current time in milliseconds
    int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;

    // Convert to a string and take the last 6 digits (to reduce length)
    String timePart = currentTimeMillis.toString().substring(7);

    // Generate a 4-digit random number
    Random random = Random();
    String randomPart = (random.nextInt(9000) + 1000).toString();

    // Combine time and random parts to form a 10-digit code
    String uniqueCode = timePart + randomPart;

    return uniqueCode;
  }
  /*void registerStaff() {
    if (_registrationFormKey.currentState!.validate()) {
      // Call the API to register the staff
      ApiService.registerStaff(registrationModel).then((response) {
        // Handle the response
        if (response.statusCode == 200) {
          // Registration successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
        } else {
          // Registration failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.message}')),
          );
        }
      });
    }
  }*/
  void registerStaff() {
    if (_registrationFormKey.currentState!.validate()) {
      // Create an instance of the ApiService
      ApiService apiService = ApiService();
      DateTime parsedDateOfBirth = DateTime.parse(registrationModel.dateOfBirth);
      Map<String, dynamic> registrationData = {
        'surname': registrationModel.surname,
        'otherNames': registrationModel.otherNames,
        'dateOfBirth': parsedDateOfBirth.toIso8601String(),
        'idPhoto': registrationModel.idPhoto,  // Assuming this is base64 encoded string
        'uniqueCode': registrationModel.uniqueCode,
      };
      // Call the API to register the staff
      apiService.registerStaff(registrationData).then((response) {
        // Handle the response
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          var responseData = jsonDecode(response.body);
          String employeeNumber = responseData['employeeNumber'];
          // Show dialog with employee number
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Registration Successful'),
                content: Text(
                  'Employee Number: $employeeNumber\nRegistration successful!',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text('OK'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to details page with the employee number
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StaffDetailsPage(empNo: employeeNumber),
                        ),
                      );
                    },
                    child: const Text('View Details'),
                  ),
                ],
              );
            },
          );
        } else {
          final errorData = jsonDecode(response.body); // Parse the error response
          // Show the error message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorData['Message'])),
          );
        }
      }).catchError((error) {
        // Handle any errors that occurred during the API call
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')), // Log the error
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                // get started form
                child: Form(
                  key: _registrationFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // get started text
                      Text(
                        'Staff Registration',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      TextFormField(
                        controller: codeController,
                        readOnly: true,
                        validator: (value) => value!.isEmpty ? 'Enter unique code' : null,
                        decoration: InputDecoration(
                          label: const Text('Unique Code'),
                          hintText: 'Unique Code',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) => registrationModel.uniqueCode = value,

                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // full name
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Surname';
                          }
                          return null;
                        },
                        onChanged: (value) => registrationModel.surname = value,
                        decoration: InputDecoration(
                          label: const Text('Surname'),
                          hintText: 'Enter Surname',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Other Name(s)';
                          }
                          return null;
                        },
                        onChanged: (value) => registrationModel.otherNames = value,
                        decoration: InputDecoration(
                          label: const Text('Other Name(s)'),
                          hintText: 'Enter Other Name(s)',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        controller: dobController,
                        decoration: InputDecoration(
                          label: const Text('Date of Birth'),
                          hintText: 'Date of Birth',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        readOnly: true,
                        onTap: () => selectDate(context), // Open DatePicker when tapped
                        validator: (value) => value!.isEmpty ? 'Select date of birth' : null,
                      ),
                      const SizedBox(height: 25),
                      TextButton(
                        onPressed: pickImage,
                        child: Text('Upload ID Photo'),
                      ),
                      if (_imageFile != null) ...[
                        Image.file(
                          _imageFile!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 25),
                      ],
                      // signup button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_registrationFormKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Processing Data'),
                                ),
                              );
                              registerStaff();

                            }
                          },
                          child: const Text('Register'),
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
