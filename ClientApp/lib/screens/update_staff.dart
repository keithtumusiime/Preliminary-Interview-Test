import 'dart:convert';
import 'dart:io';

import 'package:dfcu_hris/screens/staff_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api_service.dart';

class UpdateStaffPage extends StatefulWidget {
  final Map<String, dynamic> staffDetails;

  const UpdateStaffPage({Key? key, required this.staffDetails}) : super(key: key);

  @override
  _UpdateStaffPageState createState() => _UpdateStaffPageState();
}

class _UpdateStaffPageState extends State<UpdateStaffPage> {
  late TextEditingController dateOfBirthController;
  String? base64Image; // To store the base64 encoded image
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    dateOfBirthController = TextEditingController(text: widget.staffDetails['dateOfBirth']);
    base64Image = widget.staffDetails['idPhoto']; // Existing image if available
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      // Convert image to Base64 string
      final bytes = await pickedFile.readAsBytes();
      base64Image = base64Encode(bytes);
    }
  }

  void updateStaff() {
    // Create a map of the updated data
    Map<String, dynamic> updatedData = {
      'empNo': widget.staffDetails['employeeNumber'],
      'dateOfBirth': dateOfBirthController.text,
      'idPhoto': base64Image, // Include the updated image
    };

    ApiService apiService = ApiService();
    apiService.updateStaff(updatedData).then((response) {
      if (response.statusCode == 200) {
        // Update successful, navigate back to details page
        Navigator.pop(context); // Pop the update page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StaffDetailsPage(empNo: widget.staffDetails['employeeNumber']),
          ),
        );
      } else {
        final errorData = jsonDecode(response.body); // Parse the error response
        // Show the error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['Message'])),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }

  ImageProvider<Object> _getImage() {
    if (base64Image != null && base64Image!.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(base64Image!));
      } catch (e) {
        // Return a default image if decoding fails
        return const AssetImage('assets/images/avatar.png');
      }
    }
    return const AssetImage('assets/images/avatar.png');
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(dateOfBirthController.text),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dateOfBirthController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Employee'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to details page
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Centered staff image at the top with edit icon
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 60, // Adjust the radius as needed
                  backgroundImage: _getImage(),
                  backgroundColor: Colors.transparent,
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: pickImage,
                    child: const CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.edit, size: 15, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Card containing other staff details
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date of Birth field
                    GestureDetector(
                      onTap: () => _selectDate(context), // Show date picker when tapped
                      child: AbsorbPointer(
                        child: TextField(
                          controller: dateOfBirthController,
                          decoration: const InputDecoration(labelText: 'Date of Birth'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Image upload button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Upload ID Photo'),
                        IconButton(
                          icon: const Icon(Icons.upload_file),
                          onPressed: pickImage,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: updateStaff,
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

