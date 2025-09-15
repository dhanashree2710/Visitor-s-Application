import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:visitors_and_grievance_application/modules/Employee/presentation/views/employee_home_dashboard.dart';
import 'package:visitors_and_grievance_application/modules/Visitors/presentation/widgets/visitor_details_list.dart';

import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class VisitorRegistrationScreen extends StatefulWidget {
  const VisitorRegistrationScreen({super.key});

  @override
  _VisitorRegistrationScreenState createState() =>
      _VisitorRegistrationScreenState();
}

class _VisitorRegistrationScreenState extends State<VisitorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  File? _image;
  String? profileUrl;
  final ImagePicker _picker = ImagePicker();

  String? selectedDepartment;
  String? selectedPurpose;

  List<String> departments = [];
  final List<String> purposeOptions = [
    "Meeting",
    "Some Meeting Application",
    "Complaints",
    "Taking Approval",
    "Revisit",
  ];

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    try {
      final response = await supabase.from('department').select('dept_name');
      setState(() {
        departments = List<String>.from(
            response.map((dept) => dept['dept_name'].toString()));
      });
    } catch (e) {
      print("Error fetching departments: $e");
    }
  }


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
      await _uploadImage();
    }
  }

Future<void> _uploadImage() async {
  if (_image == null) return;
  try {
    final fileBytes = await _image!.readAsBytes(); // Convert File to bytes
    String fileName = "Visitors/${DateTime.now().millisecondsSinceEpoch}.jpg";

    // Upload to Supabase Storage bucket
    final res = await supabase.storage.from('Visitors').uploadBinary(
      fileName,
      fileBytes,
      fileOptions: const FileOptions(upsert: true),
    );

    // Check if upload is successful
    profileUrl = supabase.storage.from('Visitors').getPublicUrl(fileName);
    print("Image uploaded: $profileUrl");
    } catch (e) {
    print("Image upload failed: $e");
  }
}


  Future<void> registerVisitor() async {
    if (!_formKey.currentState!.validate()) return;

    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      await supabase.from('visitor').insert({
        'visitor_name': fullNameController.text.trim(),
        'visitor_phone': phoneController.text.trim(),
        'visitor_email': emailController.text.trim(),
        'department': selectedDepartment ?? '',
        'purpose': selectedPurpose ?? '',
        'profile_img': profileUrl ?? '',
        'visit_date': currentDate,
        'in_time': DateTime.now().toIso8601String(),
      });

      // Fetch all visitors again
    final response = await supabase.from('visitor').select();
    final visitors = List<Map<String, dynamic>>.from(response);

      // Clear fields
      fullNameController.clear();
      emailController.clear();
      phoneController.clear();
      setState(() {
        selectedDepartment = null;
        selectedPurpose = null;
        _image = null;
        profileUrl = null;
      });

      // Navigate to Employee Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DayWiseVisitorsStatusUpdate(visitors: visitors)),
      );
    } catch (e) {
      print("Error registering visitor: $e");
    }
  }

  InputDecoration customInputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: KDRTColors.darkBlue),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: icon != null ? Icon(icon, color: KDRTColors.darkBlue) : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: KDRTColors.darkBlue, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: KDRTColors.darkBlue, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Visitors Registration",
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: KDRTColors.darkBlue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 16),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      backgroundColor: Colors.grey.shade300,
                      child: _image == null
                          ? Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                    CircleAvatar(
                      backgroundColor: KDRTColors.darkBlue,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: fullNameController,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  decoration:
                      customInputDecoration("Full Name", icon: Icons.person),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  decoration:
                      customInputDecoration("Phone Number", icon: Icons.phone),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  decoration:
                      customInputDecoration("Email ID", icon: Icons.email),
                ),
                const SizedBox(height: 16),

                // Department Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: KDRTColors.darkBlue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedDepartment,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.business, color: KDRTColors.darkBlue),
                    ),
                    hint: Text("Select Department"),
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: KDRTColors.darkBlue),
                    items: departments.map((dept) {
                      return DropdownMenuItem<String>(
                        value: dept,
                        child: Text(dept),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDepartment = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? "Please select a department" : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Purpose Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: KDRTColors.darkBlue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedPurpose,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.info, color: KDRTColors.darkBlue),
                    ),
                    hint: Text("Select Purpose"),
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: KDRTColors.darkBlue),
                    items: purposeOptions.map((purpose) {
                      return DropdownMenuItem<String>(
                        value: purpose,
                        child: Text(purpose),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPurpose = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? "Please select a purpose" : null,
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: 150,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KDRTColors.darkBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: registerVisitor,
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
