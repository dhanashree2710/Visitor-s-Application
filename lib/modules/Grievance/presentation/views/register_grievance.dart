// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';
// import 'package:visitors_and_grievance_application/utils/common/pop_up_screen.dart';
// import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

// class RegisterGrievancePage extends StatefulWidget {
//   const RegisterGrievancePage({super.key});

//   @override
//   State<RegisterGrievancePage> createState() => _RegisterGrievancePageState();
// }

// class _RegisterGrievancePageState extends State<RegisterGrievancePage> {
//   int currentStep = 0;
//   final supabase = Supabase.instance.client;

//   // Controllers
//   final fullNameController = TextEditingController();
//   final emailController = TextEditingController();
//   final phoneController = TextEditingController();
//   final grievanceSubjectController = TextEditingController();
//   final grievanceDetailsController = TextEditingController();

//   DateTime? visitDate;
//   String priorityLevel = "Low";
//   String? uploadedFileName;
//   Uint8List? fileBytes;
//   bool isUploading = false;

//   // Department dropdown
//   List<Map<String, dynamic>> departments = [];
//   String? selectedDepartmentId;

//   final List<GlobalKey<FormState>> _formKeys = [
//     GlobalKey<FormState>(),
//     GlobalKey<FormState>(),
//     GlobalKey<FormState>()
//   ];

//   @override
//   void initState() {
//     super.initState();
//     fetchDepartments();
//   }

//   /// ✅ Fetch Departments from Supabase
//   Future<void> fetchDepartments() async {
//     try {
//       final response = await supabase.from('department').select('dept_id, dept_name');
//       setState(() {
//         departments = List<Map<String, dynamic>>.from(response);
//       });
//       print("✅ Departments fetched: $departments");
//     } catch (e) {
//       print("❌ Error fetching departments: $e");
//     }
//   }

//   /// ✅ Pick File (Web + Mobile)
//   Future<void> pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       setState(() {
//         fileBytes = result.files.single.bytes;
//         uploadedFileName = result.files.single.name;
//       });
//       print("✅ File Selected: $uploadedFileName");
//     } else {
//       print("⚠️ File picking canceled by user");
//     }
//   }

//   /// ✅ Upload file to Supabase Storage
//   Future<String?> uploadFileToSupabase() async {
//     if (fileBytes == null || uploadedFileName == null) {
//       print("⚠️ No file selected for upload");
//       return null;
//     }

//     try {
//       setState(() => isUploading = true);

//       final fileName = "${DateTime.now().millisecondsSinceEpoch}_$uploadedFileName";
//       print("📤 Uploading file: $fileName");

//       await supabase.storage.from('Grievance').uploadBinary(
//         fileName,
//         fileBytes!,
//         fileOptions: FileOptions(contentType: _getMimeType(uploadedFileName!)),
//       );

//       final publicUrl = supabase.storage.from('Grievance').getPublicUrl(fileName);
//       print("✅ File uploaded successfully: $publicUrl");
//       return publicUrl;
//     } catch (e) {
//       print("❌ File upload error: $e");
//       return null;
//     } finally {
//       setState(() => isUploading = false);
//     }
//   }

//   /// ✅ Detect MIME type
//   String _getMimeType(String fileName) {
//     if (fileName.endsWith('.pdf')) return 'application/pdf';
//     if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) return 'image/jpeg';
//     if (fileName.endsWith('.png')) return 'image/png';
//     return 'application/octet-stream'; // default
//   }

//   /// ✅ Submit grievance
//   Future<void> submitGrievance() async {
//     if (_formKeys.every((key) => key.currentState!.validate())) {
//       print("📤 Submitting grievance...");
//       String? fileUrl = await uploadFileToSupabase();

//       try {
//         final grievanceData = {
//           'full_name': fullNameController.text,
//           'email_id': emailController.text,
//           'phone_number': phoneController.text,
//           'visit_date': DateFormat('yyyy-MM-dd').format(visitDate!),
//           'grievance_subject': grievanceSubjectController.text,
//           'grievance_details': grievanceDetailsController.text,
//           'upload_file': fileUrl,
//           'priority_level': priorityLevel,
//           'grievance_category': selectedDepartmentId,
//         };

//         print("✅ Grievance Data: $grievanceData");

//         await supabase.from('grievance').insert(grievanceData);

//         print("✅ Grievance inserted successfully");

//         showCustomAlert(
//           context,
//           isSuccess: true,
//           title: "Success",
//           description: "Your grievance has been submitted successfully.",
//           nextScreen: const RegisterGrievancePage(),
//         );
//       } catch (error) {
//         print("❌ Error inserting grievance: $error");
//         showCustomAlert(
//           context,
//           isSuccess: false,
//           title: "Error",
//           description: "Failed to submit grievance. Please try again.",
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Register Grievance", style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         backgroundColor: KDRTColors.darkBlue,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: ColorScheme.light(
//             primary: KDRTColors.darkBlue,
//           ),
//         ),
//         child: Stepper(
//           type: StepperType.vertical,
//           currentStep: currentStep,
//           onStepContinue: () {
//             if (currentStep < 2) {
//               if (_formKeys[currentStep].currentState!.validate()) {
//                 setState(() => currentStep++);
//               }
//             } else {
//               submitGrievance();
//             }
//           },
//           onStepCancel: () {
//             if (currentStep > 0) {
//               setState(() => currentStep--);
//             }
//           },
//           steps: [
//             /// STEP 1: Personal Info
//             Step(
//               title: const Text("Personal Info"),
//               isActive: currentStep >= 0,
//               state: currentStep > 0 ? StepState.complete : StepState.indexed,
//               content: Form(
//                 key: _formKeys[0],
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: fullNameController,
//                       decoration: const InputDecoration(labelText: "Full Name"),
//                       validator: (val) => val!.isEmpty ? "Enter your name" : null,
//                     ),
//                     TextFormField(
//                       controller: emailController,
//                       decoration: const InputDecoration(labelText: "Email"),
//                       validator: (val) => val!.contains("@") ? null : "Enter valid email",
//                     ),
//                     TextFormField(
//                       controller: phoneController,
//                       decoration: const InputDecoration(labelText: "Phone Number"),
//                       validator: (val) => val!.length == 10 ? null : "Enter valid phone",
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: KDRTColors.darkBlue,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                       ),
//                       onPressed: () async {
//                         DateTime? picked = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime.now(),
//                           firstDate: DateTime(2020),
//                           lastDate: DateTime(2100),
//                         );
//                         if (picked != null) {
//                           setState(() => visitDate = picked);
//                           print("✅ Visit Date selected: ${DateFormat('yyyy-MM-dd').format(visitDate!)}");
//                         }
//                       },
//                       child: Text(
//                         visitDate == null
//                             ? "Select Visit Date"
//                             : DateFormat('yyyy-MM-dd').format(visitDate!),
//                         style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),

//             /// STEP 2: Grievance Details
//             Step(
//               title: const Text("Grievance Details"),
//               isActive: currentStep >= 1,
//               state: currentStep > 1 ? StepState.complete : StepState.indexed,
//               content: Form(
//                 key: _formKeys[1],
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: grievanceSubjectController,
//                       decoration: const InputDecoration(labelText: "Grievance Subject"),
//                       validator: (val) => val!.isEmpty ? "Enter subject" : null,
//                     ),
//                     TextFormField(
//                       controller: grievanceDetailsController,
//                       maxLines: 4,
//                       decoration: const InputDecoration(labelText: "Grievance Details"),
//                       validator: (val) => val!.isEmpty ? "Enter details" : null,
//                     ),
//                     const SizedBox(height: 20),
//                     DropdownButtonFormField<String>(
//                       value: priorityLevel,
//                       items: ['Low', 'Medium', 'High']
//                           .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                           .toList(),
//                       onChanged: (val) => setState(() => priorityLevel = val!),
//                       decoration: const InputDecoration(labelText: "Priority Level"),
//                     ),
//                     const SizedBox(height: 20),
//                     DropdownButtonFormField<String>(
//                       value: selectedDepartmentId,
//                       items: departments
//                           .map((dept) => DropdownMenuItem(
//                                 value: dept['dept_id'].toString(),
//                                 child: Text(dept['dept_name']),
//                               ))
//                           .toList(),
//                       onChanged: (val) => setState(() => selectedDepartmentId = val),
//                       decoration: const InputDecoration(labelText: "Select Department"),
//                       validator: (val) => val == null ? "Please select a department" : null,
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             /// STEP 3: Upload File
//             Step(
//               title: const Text("Upload File"),
//               isActive: currentStep >= 2,
//               state: currentStep == 2 ? StepState.editing : StepState.indexed,
//               content: Form(
//                 key: _formKeys[2],
//                 child: Column(
//                   children: [
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.attach_file),
//                       label: const Text("Choose File"),
//                       onPressed: pickFile,
//                     ),
//                     if (uploadedFileName != null)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Text("Selected: $uploadedFileName"),
//                       ),
//                     if (isUploading)
//                       const Padding(
//                         padding: EdgeInsets.only(top: 10),
//                         child: CircularProgressIndicator(),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],

//           controlsBuilder: (context, details) {
//             return Container(
//               margin: const EdgeInsets.only(top: 20),
//               child: Row(
//                 children: [
//                   CustomButton(
//                     label: currentStep == 2 ? "Submit" : "Next",
//                     icon: Icons.arrow_forward,
//                     width: 120,
//                     height: 50,
//                     onPressed: details.onStepContinue!,
//                   ),
//                   const SizedBox(width: 10),
//                   if (currentStep > 0)
//                     CustomButton(
//                       label: "Back",
//                       icon: Icons.arrow_back,
//                       width: 120,
//                       height: 50,
//                       onPressed: details.onStepCancel!,
//                     ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';
// import 'package:visitors_and_grievance_application/utils/common/pop_up_screen.dart';
// import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

// class RegisterGrievancePage extends StatefulWidget {
//   const RegisterGrievancePage({super.key});

//   @override
//   State<RegisterGrievancePage> createState() => _RegisterGrievancePageState();
// }

// class _RegisterGrievancePageState extends State<RegisterGrievancePage> {
//   int currentStep = 0;
//   final supabase = Supabase.instance.client;

//   final fullNameController = TextEditingController();
//   final emailController = TextEditingController();
//   final phoneController = TextEditingController();
//   final grievanceSubjectController = TextEditingController();
//   final grievanceDetailsController = TextEditingController();

//   DateTime? visitDate;
//   String priorityLevel = "Low";
//   String? uploadedFileName;
//   Uint8List? fileBytes;
//   bool isUploading = false;

//   List<Map<String, dynamic>> departments = [];
//   String? selectedDepartmentId;

//   final List<GlobalKey<FormState>> _formKeys = [
//     GlobalKey<FormState>(),
//     GlobalKey<FormState>(),
//     GlobalKey<FormState>()
//   ];

//   @override
//   void initState() {
//     super.initState();
//     fetchDepartments();
//   }

//   /// ✅ Fetch Departments
//   Future<void> fetchDepartments() async {
//     try {
//       final response = await supabase.from('department').select('dept_id, dept_name');
//       setState(() {
//         departments = List<Map<String, dynamic>>.from(response);
//       });
//       print("✅ Departments fetched: $departments");
//     } catch (e) {
//       print("❌ Error fetching departments: $e");
//     }
//   }

//   /// ✅ Pick File
//   Future<void> pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       setState(() {
//         fileBytes = result.files.single.bytes;
//         uploadedFileName = result.files.single.name;
//       });
//       print("✅ File Selected: $uploadedFileName");
//     } else {
//       print("⚠️ File picking canceled");
//     }
//   }

//   /// ✅ Upload File to Supabase
//   Future<String?> uploadFileToSupabase() async {
//     if (fileBytes == null || uploadedFileName == null) {
//       print("⚠️ No file selected for upload");
//       return null;
//     }

//     try {
//       setState(() => isUploading = true);

//       final fileName = "${DateTime.now().millisecondsSinceEpoch}_$uploadedFileName";
//       print("📤 Uploading file: $fileName");

//       await supabase.storage.from('Grievance').uploadBinary(
//         fileName,
//         fileBytes!,
//         fileOptions: FileOptions(contentType: _getMimeType(uploadedFileName!)),
//       );

//       final publicUrl = supabase.storage.from('Grievance').getPublicUrl(fileName);
//       print("✅ File uploaded successfully: $publicUrl");
//       return publicUrl;
//     } catch (e) {
//       print("❌ File upload error: $e");
//       return null;
//     } finally {
//       setState(() => isUploading = false);
//     }
//   }

//   String _getMimeType(String fileName) {
//     if (fileName.endsWith('.pdf')) return 'application/pdf';
//     if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) return 'image/jpeg';
//     if (fileName.endsWith('.png')) return 'image/png';
//     return 'application/octet-stream';
//   }

//   /// ✅ Submit Grievance
//   Future<void> submitGrievance() async {
//     if (_formKeys.every((key) => key.currentState!.validate())) {
//       print("📤 Submitting grievance...");
//       String? fileUrl = await uploadFileToSupabase();

//       try {
//         final grievanceData = {
//           'full_name': fullNameController.text,
//           'email_id': emailController.text,
//           'phone_number': phoneController.text,
//           'visit_date': DateFormat('yyyy-MM-dd').format(visitDate!),
//           'grievance_subject': grievanceSubjectController.text,
//           'grievance_details': grievanceDetailsController.text,
//           'upload_file': fileUrl,
//           'priority_level': priorityLevel,
//           'grievance_category': selectedDepartmentId,
//         };

//         print("✅ Grievance Data: $grievanceData");

//         await supabase.from('grievance').insert(grievanceData);

//         print("✅ Grievance inserted successfully");

//         /// ✅ Send SMS
//         String smsMessage =
//             "Hello ${fullNameController.text}, your grievance has been submitted successfully!";
//         String smsUrl = "sms:${phoneController.text}?body=${Uri.encodeComponent(smsMessage)}";

//         if (await canLaunchUrl(Uri.parse(smsUrl))) {
//           await launchUrl(Uri.parse(smsUrl));
//           print("✅ SMS launched");
//         } else {
//           print("❌ Could not launch SMS");
//         }

//         showCustomAlert(
//           context,
//           isSuccess: true,
//           title: "Success",
//           description: "Your grievance has been submitted successfully.",
//           nextScreen: const RegisterGrievancePage(),
//         );
//       } catch (error) {
//         print("❌ Error inserting grievance: $error");
//         showCustomAlert(
//           context,
//           isSuccess: false,
//           title: "Error",
//           description: "Failed to submit grievance. Please try again.",
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Register Grievance", style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         backgroundColor: KDRTColors.darkBlue,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: ColorScheme.light(
//             primary: KDRTColors.darkBlue,
//           ),
//         ),
//         child: Stepper(
//           type: StepperType.vertical,
//           currentStep: currentStep,
//           onStepContinue: () {
//             if (currentStep < 2) {
//               if (_formKeys[currentStep].currentState!.validate()) {
//                 setState(() => currentStep++);
//               }
//             } else {
//               submitGrievance();
//             }
//           },
//           onStepCancel: () {
//             if (currentStep > 0) {
//               setState(() => currentStep--);
//             }
//           },
//           steps: [
//             /// STEP 1
//             Step(
//               title: const Text("Personal Info"),
//               isActive: currentStep >= 0,
//               state: currentStep > 0 ? StepState.complete : StepState.indexed,
//               content: Form(
//                 key: _formKeys[0],
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: fullNameController,
//                       decoration: const InputDecoration(labelText: "Full Name"),
//                       validator: (val) => val!.isEmpty ? "Enter your name" : null,
//                     ),
//                     TextFormField(
//                       controller: emailController,
//                       decoration: const InputDecoration(labelText: "Email"),
//                       validator: (val) => val!.contains("@") ? null : "Enter valid email",
//                     ),
//                     TextFormField(
//                       controller: phoneController,
//                       decoration: const InputDecoration(labelText: "Phone Number"),
//                       validator: (val) => val!.length == 10 ? null : "Enter valid phone",
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: KDRTColors.darkBlue,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                       ),
//                       onPressed: () async {
//                         DateTime? picked = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime.now(),
//                           firstDate: DateTime(2020),
//                           lastDate: DateTime(2100),
//                         );
//                         if (picked != null) {
//                           setState(() => visitDate = picked);
//                           print("✅ Visit Date selected: ${DateFormat('yyyy-MM-dd').format(visitDate!)}");
//                         }
//                       },
//                       child: Text(
//                         visitDate == null
//                             ? "Select Visit Date"
//                             : DateFormat('yyyy-MM-dd').format(visitDate!),
//                         style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),

//             /// STEP 2
//             Step(
//               title: const Text("Grievance Details"),
//               isActive: currentStep >= 1,
//               state: currentStep > 1 ? StepState.complete : StepState.indexed,
//               content: Form(
//                 key: _formKeys[1],
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: grievanceSubjectController,
//                       decoration: const InputDecoration(labelText: "Grievance Subject"),
//                       validator: (val) => val!.isEmpty ? "Enter subject" : null,
//                     ),
//                     TextFormField(
//                       controller: grievanceDetailsController,
//                       maxLines: 4,
//                       decoration: const InputDecoration(labelText: "Grievance Details"),
//                       validator: (val) => val!.isEmpty ? "Enter details" : null,
//                     ),
//                     const SizedBox(height: 20),
//                     DropdownButtonFormField<String>(
//                       value: priorityLevel,
//                       items: ['Low', 'Medium', 'High']
//                           .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                           .toList(),
//                       onChanged: (val) => setState(() => priorityLevel = val!),
//                       decoration: const InputDecoration(labelText: "Priority Level"),
//                     ),
//                     const SizedBox(height: 20),
//                     DropdownButtonFormField<String>(
//                       value: selectedDepartmentId,
//                       items: departments
//                           .map((dept) => DropdownMenuItem(
//                                 value: dept['dept_id'].toString(),
//                                 child: Text(dept['dept_name']),
//                               ))
//                           .toList(),
//                       onChanged: (val) => setState(() => selectedDepartmentId = val),
//                       decoration: const InputDecoration(labelText: "Select Department"),
//                       validator: (val) => val == null ? "Please select a department" : null,
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             /// STEP 3
//             Step(
//               title: const Text("Upload File"),
//               isActive: currentStep >= 2,
//               state: currentStep == 2 ? StepState.editing : StepState.indexed,
//               content: Form(
//                 key: _formKeys[2],
//                 child: Column(
//                   children: [
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.attach_file),
//                       label: const Text("Choose File"),
//                       onPressed: pickFile,
//                     ),
//                     if (uploadedFileName != null)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Text("Selected: $uploadedFileName"),
//                       ),
//                     if (isUploading)
//                       const Padding(
//                         padding: EdgeInsets.only(top: 10),
//                         child: CircularProgressIndicator(),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],

//           controlsBuilder: (context, details) {
//             return Container(
//               margin: const EdgeInsets.only(top: 20),
//               child: Row(
//                 children: [
//                   CustomButton(
//                     label: currentStep == 2 ? "Submit" : "Next",
//                     icon: Icons.arrow_forward,
//                     width: 120,
//                     height: 50,
//                     onPressed: details.onStepContinue!,
//                   ),
//                   const SizedBox(width: 10),
//                   if (currentStep > 0)
//                     CustomButton(
//                       label: "Back",
//                       icon: Icons.arrow_back,
//                       width: 120,
//                       height: 50,
//                       onPressed: details.onStepCancel!,
//                     ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';
// import 'package:visitors_and_grievance_application/utils/common/pop_up_screen.dart';
// import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

// class RegisterGrievancePage extends StatefulWidget {
//   const RegisterGrievancePage({super.key});

//   @override
//   State<RegisterGrievancePage> createState() => _RegisterGrievancePageState();
// }

// class _RegisterGrievancePageState extends State<RegisterGrievancePage> {
//   int currentStep = 0;
//   final supabase = Supabase.instance.client;

//   // Controllers
//   final fullNameController = TextEditingController();
//   final emailController = TextEditingController();
//   final phoneController = TextEditingController();
//   final grievanceSubjectController = TextEditingController();
//   final grievanceDetailsController = TextEditingController();

//   DateTime? visitDate;
//   String priorityLevel = "Low";
//   String? uploadedFileName;
//   Uint8List? fileBytes;
//   bool isUploading = false;

//   // Department dropdown
//   List<Map<String, dynamic>> departments = [];
//   String? selectedDepartmentId;

//   final List<GlobalKey<FormState>> _formKeys = [
//     GlobalKey<FormState>(),
//     GlobalKey<FormState>(),
//     GlobalKey<FormState>()
//   ];

//   @override
//   void initState() {
//     super.initState();
//     fetchDepartments();
//   }

//   /// ✅ Fetch Departments from Supabase
//   Future<void> fetchDepartments() async {
//     try {
//       final response = await supabase.from('department').select('dept_id, dept_name');
//       setState(() {
//         departments = List<Map<String, dynamic>>.from(response);
//       });
//       print("✅ Departments fetched: $departments");
//     } catch (e) {
//       print("❌ Error fetching departments: $e");
//     }
//   }

//   /// ✅ Pick File (Web + Mobile)
//   Future<void> pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       setState(() {
//         fileBytes = result.files.single.bytes;
//         uploadedFileName = result.files.single.name;
//       });
//       print("✅ File Selected: $uploadedFileName");
//     } else {
//       print("⚠️ File picking canceled by user");
//     }
//   }

//   /// ✅ Upload file to Supabase Storage
//   Future<String?> uploadFileToSupabase() async {
//     if (fileBytes == null || uploadedFileName == null) {
//       print("⚠️ No file selected for upload");
//       return null;
//     }

//     try {
//       setState(() => isUploading = true);

//       final fileName = "${DateTime.now().millisecondsSinceEpoch}_$uploadedFileName";
//       print("📤 Uploading file: $fileName");

//       await supabase.storage.from('Grievance').uploadBinary(
//         fileName,
//         fileBytes!,
//         fileOptions: FileOptions(contentType: _getMimeType(uploadedFileName!)),
//       );

//       final publicUrl = supabase.storage.from('Grievance').getPublicUrl(fileName);
//       print("✅ File uploaded successfully: $publicUrl");
//       return publicUrl;
//     } catch (e) {
//       print("❌ File upload error: $e");
//       return null;
//     } finally {
//       setState(() => isUploading = false);
//     }
//   }

//   /// ✅ Detect MIME type
//   String _getMimeType(String fileName) {
//     if (fileName.endsWith('.pdf')) return 'application/pdf';
//     if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) return 'image/jpeg';
//     if (fileName.endsWith('.png')) return 'image/png';
//     return 'application/octet-stream'; // default
//   }

//   /// ✅ Submit grievance
//   Future<void> submitGrievance() async {
//     if (_formKeys.every((key) => key.currentState!.validate())) {
//       print("📤 Submitting grievance...");
//       String? fileUrl = await uploadFileToSupabase();

//       try {
//         final grievanceData = {
//           'full_name': fullNameController.text,
//           'email_id': emailController.text,
//           'phone_number': phoneController.text,
//           'visit_date': DateFormat('yyyy-MM-dd').format(visitDate!),
//           'grievance_subject': grievanceSubjectController.text,
//           'grievance_details': grievanceDetailsController.text,
//           'upload_file': fileUrl,
//           'priority_level': priorityLevel,
//           'grievance_category': selectedDepartmentId,
//         };

//         print("✅ Grievance Data: $grievanceData");

//         await supabase.from('grievance').insert(grievanceData);

//         print("✅ Grievance inserted successfully");

//         showCustomAlert(
//           context,
//           isSuccess: true,
//           title: "Success",
//           description: "Your grievance has been submitted successfully.",
//           nextScreen: const RegisterGrievancePage(),
//         );
//       } catch (error) {
//         print("❌ Error inserting grievance: $error");
//         showCustomAlert(
//           context,
//           isSuccess: false,
//           title: "Error",
//           description: "Failed to submit grievance. Please try again.",
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Register Grievance", style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         backgroundColor: KDRTColors.darkBlue,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: ColorScheme.light(
//             primary: KDRTColors.darkBlue,
//           ),
//         ),
//         child: Stepper(
//           type: StepperType.vertical,
//           currentStep: currentStep,
//           onStepContinue: () {
//             if (currentStep < 2) {
//               if (_formKeys[currentStep].currentState!.validate()) {
//                 setState(() => currentStep++);
//               }
//             } else {
//               submitGrievance();
//             }
//           },
//           onStepCancel: () {
//             if (currentStep > 0) {
//               setState(() => currentStep--);
//             }
//           },
//           steps: [
//             /// STEP 1: Personal Info
//             Step(
//               title: const Text("Personal Info"),
//               isActive: currentStep >= 0,
//               state: currentStep > 0 ? StepState.complete : StepState.indexed,
//               content: Form(
//                 key: _formKeys[0],
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: fullNameController,
//                       decoration: const InputDecoration(labelText: "Full Name"),
//                       validator: (val) => val!.isEmpty ? "Enter your name" : null,
//                     ),
//                     TextFormField(
//                       controller: emailController,
//                       decoration: const InputDecoration(labelText: "Email"),
//                       validator: (val) => val!.contains("@") ? null : "Enter valid email",
//                     ),
//                     TextFormField(
//                       controller: phoneController,
//                       decoration: const InputDecoration(labelText: "Phone Number"),
//                       validator: (val) => val!.length == 10 ? null : "Enter valid phone",
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: KDRTColors.darkBlue,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                       ),
//                       onPressed: () async {
//                         DateTime? picked = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime.now(),
//                           firstDate: DateTime(2020),
//                           lastDate: DateTime(2100),
//                         );
//                         if (picked != null) {
//                           setState(() => visitDate = picked);
//                           print("✅ Visit Date selected: ${DateFormat('yyyy-MM-dd').format(visitDate!)}");
//                         }
//                       },
//                       child: Text(
//                         visitDate == null
//                             ? "Select Visit Date"
//                             : DateFormat('yyyy-MM-dd').format(visitDate!),
//                         style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),

//             /// STEP 2: Grievance Details
//             Step(
//               title: const Text("Grievance Details"),
//               isActive: currentStep >= 1,
//               state: currentStep > 1 ? StepState.complete : StepState.indexed,
//               content: Form(
//                 key: _formKeys[1],
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: grievanceSubjectController,
//                       decoration: const InputDecoration(labelText: "Grievance Subject"),
//                       validator: (val) => val!.isEmpty ? "Enter subject" : null,
//                     ),
//                     TextFormField(
//                       controller: grievanceDetailsController,
//                       maxLines: 4,
//                       decoration: const InputDecoration(labelText: "Grievance Details"),
//                       validator: (val) => val!.isEmpty ? "Enter details" : null,
//                     ),
//                     const SizedBox(height: 20),
//                     DropdownButtonFormField<String>(
//                       value: priorityLevel,
//                       items: ['Low', 'Medium', 'High']
//                           .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                           .toList(),
//                       onChanged: (val) => setState(() => priorityLevel = val!),
//                       decoration: const InputDecoration(labelText: "Priority Level"),
//                     ),
//                     const SizedBox(height: 20),
//                     DropdownButtonFormField<String>(
//                       value: selectedDepartmentId,
//                       items: departments
//                           .map((dept) => DropdownMenuItem(
//                                 value: dept['dept_id'].toString(),
//                                 child: Text(dept['dept_name']),
//                               ))
//                           .toList(),
//                       onChanged: (val) => setState(() => selectedDepartmentId = val),
//                       decoration: const InputDecoration(labelText: "Select Department"),
//                       validator: (val) => val == null ? "Please select a department" : null,
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             /// STEP 3: Upload File
//             Step(
//               title: const Text("Upload File"),
//               isActive: currentStep >= 2,
//               state: currentStep == 2 ? StepState.editing : StepState.indexed,
//               content: Form(
//                 key: _formKeys[2],
//                 child: Column(
//                   children: [
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.attach_file),
//                       label: const Text("Choose File"),
//                       onPressed: pickFile,
//                     ),
//                     if (uploadedFileName != null)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Text("Selected: $uploadedFileName"),
//                       ),
//                     if (isUploading)
//                       const Padding(
//                         padding: EdgeInsets.only(top: 10),
//                         child: CircularProgressIndicator(),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],

//           controlsBuilder: (context, details) {
//             return Container(
//               margin: const EdgeInsets.only(top: 20),
//               child: Row(
//                 children: [
//                   CustomButton(
//                     label: currentStep == 2 ? "Submit" : "Next",
//                     icon: Icons.arrow_forward,
//                     width: 120,
//                     height: 50,
//                     onPressed: details.onStepContinue!,
//                   ),
//                   const SizedBox(width: 10),
//                   if (currentStep > 0)
//                     CustomButton(
//                       label: "Back",
//                       icon: Icons.arrow_back,
//                       width: 120,
//                       height: 50,
//                       onPressed: details.onStepCancel!,
//                     ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';
// import 'package:visitors_and_grievance_application/utils/common/pop_up_screen.dart';
// import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

// class RegisterGrievancePage extends StatefulWidget {
//   const RegisterGrievancePage({super.key});

//   @override
//   State<RegisterGrievancePage> createState() => _RegisterGrievancePageState();
// }

// class _RegisterGrievancePageState extends State<RegisterGrievancePage> {
//   int currentStep = 0;
//   final supabase = Supabase.instance.client;

//   final fullNameController = TextEditingController();
//   final emailController = TextEditingController();
//   final phoneController = TextEditingController();
//   final grievanceSubjectController = TextEditingController();
//   final grievanceDetailsController = TextEditingController();

//   DateTime? visitDate;
//   String priorityLevel = "Low";
//   String? uploadedFileName;
//   Uint8List? fileBytes;
//   bool isUploading = false;

//   List<Map<String, dynamic>> departments = [];
//   String? selectedDepartmentId;

//   final List<GlobalKey<FormState>> _formKeys = [
//     GlobalKey<FormState>(),
//     GlobalKey<FormState>(),
//     GlobalKey<FormState>()
//   ];

//   @override
//   void initState() {
//     super.initState();
//     fetchDepartments();
//   }

//   /// ✅ Fetch Departments
//   Future<void> fetchDepartments() async {
//     try {
//       final response = await supabase.from('department').select('dept_id, dept_name');
//       setState(() {
//         departments = List<Map<String, dynamic>>.from(response);
//       });
//       print("✅ Departments fetched: $departments");
//     } catch (e) {
//       print("❌ Error fetching departments: $e");
//     }
//   }

//   /// ✅ Pick File
//   Future<void> pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       setState(() {
//         fileBytes = result.files.single.bytes;
//         uploadedFileName = result.files.single.name;
//       });
//       print("✅ File Selected: $uploadedFileName");
//     } else {
//       print("⚠️ File picking canceled");
//     }
//   }

//   /// ✅ Upload File to Supabase
//   Future<String?> uploadFileToSupabase() async {
//     if (fileBytes == null || uploadedFileName == null) {
//       print("⚠️ No file selected for upload");
//       return null;
//     }

//     try {
//       setState(() => isUploading = true);

//       final fileName = "${DateTime.now().millisecondsSinceEpoch}_$uploadedFileName";
//       print("📤 Uploading file: $fileName");

//       await supabase.storage.from('Grievance').uploadBinary(
//         fileName,
//         fileBytes!,
//         fileOptions: FileOptions(contentType: _getMimeType(uploadedFileName!)),
//       );

//       final publicUrl = supabase.storage.from('Grievance').getPublicUrl(fileName);
//       print("✅ File uploaded successfully: $publicUrl");
//       return publicUrl;
//     } catch (e) {
//       print("❌ File upload error: $e");
//       return null;
//     } finally {
//       setState(() => isUploading = false);
//     }
//   }

//   String _getMimeType(String fileName) {
//     if (fileName.endsWith('.pdf')) return 'application/pdf';
//     if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) return 'image/jpeg';
//     if (fileName.endsWith('.png')) return 'image/png';
//     return 'application/octet-stream';
//   }

//   /// ✅ Submit Grievance
//   Future<void> submitGrievance() async {
//     if (_formKeys.every((key) => key.currentState!.validate())) {
//       print("📤 Submitting grievance...");
//       String? fileUrl = await uploadFileToSupabase();

//       try {
//         final grievanceData = {
//           'full_name': fullNameController.text,
//           'email_id': emailController.text,
//           'phone_number': phoneController.text,
//           'visit_date': DateFormat('yyyy-MM-dd').format(visitDate!),
//           'grievance_subject': grievanceSubjectController.text,
//           'grievance_details': grievanceDetailsController.text,
//           'upload_file': fileUrl,
//           'priority_level': priorityLevel,
//           'grievance_category': selectedDepartmentId,
//         };

//         print("✅ Grievance Data: $grievanceData");

//         await supabase.from('grievance').insert(grievanceData);

//         print("✅ Grievance inserted successfully");

//         /// ✅ Send SMS
//         String smsMessage =
//             "Hello ${fullNameController.text}, your grievance has been submitted successfully!";
//         String smsUrl = "sms:${phoneController.text}?body=${Uri.encodeComponent(smsMessage)}";

//         if (await canLaunchUrl(Uri.parse(smsUrl))) {
//           await launchUrl(Uri.parse(smsUrl));
//           print("✅ SMS launched");
//         } else {
//           print("❌ Could not launch SMS");
//         }

//         showCustomAlert(
//           context,
//           isSuccess: true,
//           title: "Success",
//           description: "Your grievance has been submitted successfully.",
//           nextScreen: const RegisterGrievancePage(),
//         );
//       } catch (error) {
//         print("❌ Error inserting grievance: $error");
//         showCustomAlert(
//           context,
//           isSuccess: false,
//           title: "Error",
//           description: "Failed to submit grievance. Please try again.",
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Register Grievance", style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         backgroundColor: KDRTColors.darkBlue,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: ColorScheme.light(
//             primary: KDRTColors.darkBlue,
//           ),
//         ),
//         child: Stepper(
//           type: StepperType.vertical,
//           currentStep: currentStep,
//           onStepContinue: () {
//             if (currentStep < 2) {
//               if (_formKeys[currentStep].currentState!.validate()) {
//                 setState(() => currentStep++);
//               }
//             } else {
//               submitGrievance();
//             }
//           },
//           onStepCancel: () {
//             if (currentStep > 0) {
//               setState(() => currentStep--);
//             }
//           },
//           steps: [
//             /// STEP 1
//             Step(
//               title: const Text("Personal Info"),
//               isActive: currentStep >= 0,
//               state: currentStep > 0 ? StepState.complete : StepState.indexed,
//               content: Form(
//                 key: _formKeys[0],
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: fullNameController,
//                       decoration: const InputDecoration(labelText: "Full Name"),
//                       validator: (val) => val!.isEmpty ? "Enter your name" : null,
//                     ),
//                     TextFormField(
//                       controller: emailController,
//                       decoration: const InputDecoration(labelText: "Email"),
//                       validator: (val) => val!.contains("@") ? null : "Enter valid email",
//                     ),
//                     TextFormField(
//                       controller: phoneController,
//                       decoration: const InputDecoration(labelText: "Phone Number"),
//                       validator: (val) => val!.length == 10 ? null : "Enter valid phone",
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: KDRTColors.darkBlue,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                       ),
//                       onPressed: () async {
//                         DateTime? picked = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime.now(),
//                           firstDate: DateTime(2020),
//                           lastDate: DateTime(2100),
//                         );
//                         if (picked != null) {
//                           setState(() => visitDate = picked);
//                           print("✅ Visit Date selected: ${DateFormat('yyyy-MM-dd').format(visitDate!)}");
//                         }
//                       },
//                       child: Text(
//                         visitDate == null
//                             ? "Select Visit Date"
//                             : DateFormat('yyyy-MM-dd').format(visitDate!),
//                         style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),

//             /// STEP 2
//             Step(
//               title: const Text("Grievance Details"),
//               isActive: currentStep >= 1,
//               state: currentStep > 1 ? StepState.complete : StepState.indexed,
//               content: Form(
//                 key: _formKeys[1],
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: grievanceSubjectController,
//                       decoration: const InputDecoration(labelText: "Grievance Subject"),
//                       validator: (val) => val!.isEmpty ? "Enter subject" : null,
//                     ),
//                     TextFormField(
//                       controller: grievanceDetailsController,
//                       maxLines: 4,
//                       decoration: const InputDecoration(labelText: "Grievance Details"),
//                       validator: (val) => val!.isEmpty ? "Enter details" : null,
//                     ),
//                     const SizedBox(height: 20),
//                     DropdownButtonFormField<String>(
//                       value: priorityLevel,
//                       items: ['Low', 'Medium', 'High']
//                           .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                           .toList(),
//                       onChanged: (val) => setState(() => priorityLevel = val!),
//                       decoration: const InputDecoration(labelText: "Priority Level"),
//                     ),
//                     const SizedBox(height: 20),
//                     DropdownButtonFormField<String>(
//                       value: selectedDepartmentId,
//                       items: departments
//                           .map((dept) => DropdownMenuItem(
//                                 value: dept['dept_id'].toString(),
//                                 child: Text(dept['dept_name']),
//                               ))
//                           .toList(),
//                       onChanged: (val) => setState(() => selectedDepartmentId = val),
//                       decoration: const InputDecoration(labelText: "Select Department"),
//                       validator: (val) => val == null ? "Please select a department" : null,
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             /// STEP 3
//             Step(
//               title: const Text("Upload File"),
//               isActive: currentStep >= 2,
//               state: currentStep == 2 ? StepState.editing : StepState.indexed,
//               content: Form(
//                 key: _formKeys[2],
//                 child: Column(
//                   children: [
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.attach_file),
//                       label: const Text("Choose File"),
//                       onPressed: pickFile,
//                     ),
//                     if (uploadedFileName != null)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Text("Selected: $uploadedFileName"),
//                       ),
//                     if (isUploading)
//                       const Padding(
//                         padding: EdgeInsets.only(top: 10),
//                         child: CircularProgressIndicator(),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],

//           controlsBuilder: (context, details) {
//             return Container(
//               margin: const EdgeInsets.only(top: 20),
//               child: Row(
//                 children: [
//                   CustomButton(
//                     label: currentStep == 2 ? "Submit" : "Next",
//                     icon: Icons.arrow_forward,
//                     width: 120,
//                     height: 50,
//                     onPressed: details.onStepContinue!,
//                   ),
//                   const SizedBox(width: 10),
//                   if (currentStep > 0)
//                     CustomButton(
//                       label: "Back",
//                       icon: Icons.arrow_back,
//                       width: 120,
//                       height: 50,
//                       onPressed: details.onStepCancel!,
//                     ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }



import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';
import 'package:visitors_and_grievance_application/utils/common/pop_up_screen.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class RegisterGrievancePage extends StatefulWidget {
  const RegisterGrievancePage({super.key});

  @override
  State<RegisterGrievancePage> createState() => _RegisterGrievancePageState();
}

class _RegisterGrievancePageState extends State<RegisterGrievancePage> {
  int currentStep = 0;
  final supabase = Supabase.instance.client;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final grievanceSubjectController = TextEditingController();
  final grievanceDetailsController = TextEditingController();

  DateTime? visitDate;
  String priorityLevel = "Low";
  String? uploadedFileName;
  Uint8List? fileBytes;
  bool isUploading = false;

  List<Map<String, dynamic>> departments = [];
  String? selectedDepartmentId;

  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  /// ✅ Fetch Departments from Supabase
  Future<void> fetchDepartments() async {
    try {
      final response = await supabase.from('department').select('dept_id, dept_name');
      setState(() {
        departments = List<Map<String, dynamic>>.from(response);
      });
      print("✅ Departments fetched: $departments");
    } catch (e) {
      print("❌ Error fetching departments: $e");
    }
  }

  /// ✅ Pick File
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        fileBytes = result.files.single.bytes;
        uploadedFileName = result.files.single.name;
      });
      print("✅ File Selected: $uploadedFileName");
    } else {
      print("⚠️ File picking canceled");
    }
  }

  /// ✅ Upload File to Supabase
  Future<String?> uploadFileToSupabase() async {
    if (fileBytes == null || uploadedFileName == null) {
      print("⚠️ No file selected for upload");
      return null;
    }

    try {
      setState(() => isUploading = true);

      final fileName = "${DateTime.now().millisecondsSinceEpoch}_$uploadedFileName";
      print("📤 Uploading file: $fileName");

      await supabase.storage.from('Grievance').uploadBinary(
        fileName,
        fileBytes!,
        fileOptions: FileOptions(contentType: _getMimeType(uploadedFileName!)),
      );

      final publicUrl = supabase.storage.from('Grievance').getPublicUrl(fileName);
      print("✅ File uploaded successfully: $publicUrl");
      return publicUrl;
    } catch (e) {
      print("❌ File upload error: $e");
      return null;
    } finally {
      setState(() => isUploading = false);
    }
  }

  String _getMimeType(String fileName) {
    if (fileName.endsWith('.pdf')) return 'application/pdf';
    if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) return 'image/jpeg';
    if (fileName.endsWith('.png')) return 'image/png';
    return 'application/octet-stream';
  }

Future<void> submitGrievance() async {
  if (_formKeys.every((key) => key.currentState!.validate())) {
    if (visitDate == null) {
      print("⚠️ Visit date not selected");
      return;
    }

    print("📤 Submitting grievance...");
    String? fileUrl = await uploadFileToSupabase();

    try {
     
     

      final grievanceData = {
        
        'full_name': fullNameController.text,
        'email_id': emailController.text,
        'phone_number': phoneController.text,
        'visit_date': DateFormat('yyyy-MM-dd').format(visitDate!),
        'grievance_subject': grievanceSubjectController.text,
        'grievance_details': grievanceDetailsController.text,
        'upload_file': fileUrl,
        'priority_level': priorityLevel,
        'grievance_category': selectedDepartmentId,
        'grievance_status': 'Pending'
      };

      print("✅ Grievance Data: $grievanceData");

      await supabase.from('grievance').insert(grievanceData);

      print("✅ Grievance inserted successfully");

      /// ✅ Send SMS & WhatsApp
      await _sendSMS(
       
        status: "Pending",
        subject: grievanceSubjectController.text,
        details: grievanceDetailsController.text,
        category: _getDepartmentName(selectedDepartmentId),

      );

      await _sendWhatsApp(
       
        status: "Pending",
        subject: grievanceSubjectController.text,
        details: grievanceDetailsController.text,
        category: _getDepartmentName(selectedDepartmentId),

      );

      /// ✅ Show Success Popup
      showCustomAlert(
        context,
        isSuccess: true,
        title: "Success",
        description: "Your grievance has been submitted successfully.",
        nextScreen: const RegisterGrievancePage(),
      );
    } catch (error) {
      print("❌ Error inserting grievance: $error");
      showCustomAlert(
        context,
        isSuccess: false,
        title: "Error",
        description: "Failed to submit grievance. Please try again.",
      );
    }
  }
}

String _getDepartmentName(String? deptId) {
  final dept = departments.firstWhere(
    (d) => d['dept_id'] == deptId,
    orElse: () => {'dept_name': 'Unknown'},
  );
  return dept['dept_name'] ?? 'Unknown';
}


 /// ✅ Open SMS App with professional message
  Future<void> _sendSMS({
    
    required String status,
    required String subject,
    required String details,
    required String category,
  }) async {
    String smsMessage =
        "Dear ${fullNameController.text},\n\n"
        "Your grievance has been registered successfully.\n\n"
       
        "📂 Status: $status\n"
        "📝 Subject: $subject\n"
        "📄 Details: $details\n"
        "🏢 Category: $category\n\n"
        "Thank you for reaching out to us. We will review it shortly.";

    print("📲 SMS Message:\n$smsMessage");

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneController.text,
      queryParameters: {'body': smsMessage},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
      print("✅ SMS app opened with message");
    } else {
      print("❌ Could not open SMS app");
    }
  }

  /// ✅ Send WhatsApp message
  Future<void> _sendWhatsApp({
   
    required String status,
    required String subject,
    required String details,
    required String category,
  }) async {
    String message =
        "Dear ${fullNameController.text},\n\n"
        "Your grievance has been registered successfully.\n\n"
      
        "📂 Status: $status\n"
        "📝 Subject: $subject\n"
        "📄 Details: $details\n"
        "🏢 Category: $category\n\n"
        "Thank you for reaching out to us. We will review it shortly.";

    print("📲 WhatsApp Message:\n$message");

    String phone = phoneController.text;
    if (!phone.startsWith("+")) {
      phone = "+91$phone"; // Default India code
    }

    final Uri whatsappUri = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      print("✅ WhatsApp opened with message");
    } else {
      print("❌ Could not open WhatsApp");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Grievance", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: KDRTColors.darkBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: KDRTColors.darkBlue,
          ),
        ),
        child: Stepper(
          type: StepperType.vertical,
          currentStep: currentStep,
          onStepContinue: () {
            if (currentStep < 2) {
              if (_formKeys[currentStep].currentState!.validate()) {
                setState(() => currentStep++);
              }
            } else {
              submitGrievance();
            }
          },
          onStepCancel: () {
            if (currentStep > 0) {
              setState(() => currentStep--);
            }
          },
          steps: _buildSteps(),
          controlsBuilder: (context, details) {
            return Container(
              margin: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  CustomButton(
                    label: currentStep == 2 ? "Submit" : "Next",
                    icon: Icons.arrow_forward,
                    width: 140,
                    height: 50,
                    onPressed: details.onStepContinue!,
                  ),
                  const SizedBox(width: 10),
                  if (currentStep > 0)
                    CustomButton(
                      label: "Back",
                      icon: Icons.arrow_back,
                      width: 120,
                      height: 50,
                      onPressed: details.onStepCancel!,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// ✅ Build Steps
  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text("Personal Info"),
        isActive: currentStep >= 0,
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _formKeys[0],
          child: Column(
            children: [
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (val) => val!.isEmpty ? "Enter your name" : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (val) => val!.contains("@") ? null : "Enter valid email",
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                validator: (val) => val!.length == 10 ? null : "Enter valid phone",
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: KDRTColors.darkBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  setState(() => visitDate = picked);
                  print("✅ Visit Date selected: ${DateFormat('yyyy-MM-dd').format(visitDate!)}");
                                },
                child: Text(
                  visitDate == null
                      ? "Select Visit Date"
                      : DateFormat('yyyy-MM-dd').format(visitDate!),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
      Step(
        title: const Text("Grievance Details"),
        isActive: currentStep >= 1,
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _formKeys[1],
          child: Column(
            children: [
              TextFormField(
                controller: grievanceSubjectController,
                decoration: const InputDecoration(labelText: "Grievance Subject"),
                validator: (val) => val!.isEmpty ? "Enter subject" : null,
              ),
              TextFormField(
                controller: grievanceDetailsController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: "Grievance Details"),
                validator: (val) => val!.isEmpty ? "Enter details" : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: priorityLevel,
                items: ['Low', 'Medium', 'High']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => priorityLevel = val!),
                decoration: const InputDecoration(labelText: "Priority Level"),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedDepartmentId,
                items: departments
                    .map((dept) => DropdownMenuItem(
                          value: dept['dept_id'].toString(),
                          child: Text(dept['dept_name']),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => selectedDepartmentId = val),
                decoration: const InputDecoration(labelText: "Select Department"),
                validator: (val) => val == null ? "Please select a department" : null,
              ),
            ],
          ),
        ),
      ),
      Step(
        title: const Text("Upload File"),
        isActive: currentStep >= 2,
        state: currentStep == 2 ? StepState.editing : StepState.indexed,
        content: Form(
          key: _formKeys[2],
          child: Column(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text("Choose File"),
                onPressed: pickFile,
              ),
              if (uploadedFileName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("Selected: $uploadedFileName"),
                ),
              if (isUploading)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    ];
  }
}
