import 'dart:convert';

import 'package:dfcu_hris/screens/update_staff.dart';
import 'package:flutter/material.dart';

import '../api_service.dart';

class StaffDetailsPage extends StatefulWidget {
  final String empNo;

  const StaffDetailsPage({Key? key, required this.empNo}) : super(key: key);

  @override
  _StaffDetailsPageState createState() => _StaffDetailsPageState();
}

class _StaffDetailsPageState extends State<StaffDetailsPage> {
  Map<String, dynamic>? staffData;

  final ApiService apiService = ApiService(); // Create an instance of ApiService

  @override
  void initState() {
    super.initState();
    fetchStaffDetails();
  }

  void fetchStaffDetails() {
    apiService.getStaff(widget.empNo).then((response) { // Use the instance to call the method
      if (response.statusCode == 200) {
        setState(() {
          staffData = jsonDecode(response.body)['data']; // Parse the response data
        });
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

  String formatDateOfBirth(String? dateOfBirth) {
    // Assuming dateOfBirth is in the format of your API response
    if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
      // Convert to desired format (YYYY-MM-DD)
      final DateTime parsedDate = DateTime.parse(dateOfBirth);
      return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    }
    return "N/A"; // Return N/A if dateOfBirth is null or empty
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: staffData == null
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
          : SingleChildScrollView( // Use SingleChildScrollView to avoid overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Make column stretch to full width
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 60, // Adjust the radius as needed
                  backgroundImage: staffData!['idPhoto'] != null && staffData!['idPhoto']!.isNotEmpty
                      ? MemoryImage(base64Decode(staffData!['idPhoto']))
                      : const AssetImage('assets/images/avatar.png') as ImageProvider,
                  backgroundColor: Colors.transparent,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Card containing staff details
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: 'EmpNo:  ', // Label
                        children: <TextSpan>[
                          TextSpan(
                            text: '  ${staffData!['employeeNumber']}', // Value
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), // Value style
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        text: 'Surname:  ', // Label
                        children: <TextSpan>[
                          TextSpan(
                            text: '  ${staffData!['surname'] ?? "N/A"}', // Value
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), // Value style
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        text: 'Other Names:   ', // Label
                        children: <TextSpan>[
                          TextSpan(
                            text: ' ${staffData!['otherNames'] ?? "N/A"}', // Value
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), // Value style
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        text: 'Date of Birth:    ', // Label
                        children: <TextSpan>[
                          TextSpan(
                            text: formatDateOfBirth(staffData!['dateOfBirth']), // Value
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), // Value style
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),

              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the update page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateStaffPage(staffDetails: staffData!),
                  ),
                );
              },
              child: const Text('Update Details'),
            ),
          ],
        ),
      ),
    );
  }

}
