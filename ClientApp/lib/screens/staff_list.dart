import 'dart:convert';

import 'package:dfcu_hris/screens/staff_details.dart';
import 'package:flutter/material.dart';

import '../api_service.dart';

import 'dart:convert';
import 'package:flutter/material.dart';

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  _StaffListPageState createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  List<dynamic> staffList = []; // To hold the list of staff members
  bool isLoading = true; // To manage loading state

  ImageProvider<Object>? _getImage(String? base64String) {
    if (base64String != null && base64String.isNotEmpty) {
      // Check if the string length is valid for base64
      if (base64String.length % 4 == 0) {
        try {
          var decodedBytes = base64Decode(base64String);
          return MemoryImage(decodedBytes);
        } catch (e) {
          print('Failed to decode image: $e'); // Log the error
        }
      }
    }
    // Return a default image if decoding fails or string is invalid
    return const AssetImage('assets/images/avatar.png');
  }

  @override
  void initState() {
    super.initState();
    fetchAllStaff(); // Fetch the staff list when the page is initialized
  }

  void fetchAllStaff() async {
    try {
      final response = await ApiService().getAllStaff(); // Adjust to match your API call
      if (response.statusCode == 200) {
        setState(() {
          staffList = jsonDecode(response.body)['data']; // Assuming the response structure
          isLoading = false; // Set loading to false after fetching data
        });
      } else {
        final errorData = jsonDecode(response.body); // Parse the error response
        // Show the error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['Message'])),
        );
      }
    } catch (error) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DFCU Employee List'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns
            crossAxisSpacing: 10.0, // Space between columns
            mainAxisSpacing: 10.0, // Space between rows
            childAspectRatio: 3 / 4, // Adjust the height-to-width ratio
          ),
          itemCount: staffList.length,
          itemBuilder: (context, index) {
            var staff = staffList[index];
            return _buildStaffCard(context, staff);
          },
        ),
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, Map<String, dynamic> staff) {
    return InkWell(
      onTap: () {
        // Navigate to the staff details page when clicked
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffDetailsPage(empNo: staff['employeeNumber']),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipOval(
                child: Container(
                  width: 100, // Make sure the width and height are equal for a circle
                  height: 100, // Same as width for perfect circle
                  color: Colors.grey[200], // Fallback background color
                  child: staff['idPhoto'] != null
                      ? Image(
                    image: _getImage(staff['idPhoto'])!,
                    fit: BoxFit.contain, // Ensure the image fits within the container
                  )
                      : const Icon(Icons.person, size: 50), // Fallback icon
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${staff['surname']} ${staff['otherNames']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'EmpNO: ${staff['employeeNumber']}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }


}
