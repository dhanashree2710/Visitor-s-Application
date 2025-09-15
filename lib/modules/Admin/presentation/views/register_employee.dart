import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/views/home_dashboard.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/widgets/employee_list.dart';
import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';
import 'package:visitors_and_grievance_application/utils/common/pop_up_screen.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class EmployeeRegisterPage extends StatefulWidget {
  final String role;
  const EmployeeRegisterPage({super.key,required this.role});

  @override
  State<EmployeeRegisterPage> createState() => _EmployeeRegisterPageState();
}

class _EmployeeRegisterPageState extends State<EmployeeRegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final supabase = Supabase.instance.client;

  bool isLoading = false;
  bool isDeptLoading = true;

  List<Map<String, dynamic>> departmentList = [];
  String? selectedDeptId;

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  /// ✅ Fetch department list from DB
  Future<void> fetchDepartments() async {
    try {
      final response = await supabase
          .from('department')
          .select('dept_id, dept_name')
          .order('dept_name');

      setState(() {
        departmentList = List<Map<String, dynamic>>.from(response);
        isDeptLoading = false;
      });
    } catch (e) {
      setState(() => isDeptLoading = false);
      showCustomAlert(
        context,
        isSuccess: false,
        title: "Error",
        description: "Failed to load departments.",
      );
    }
  }

  // /// ✅ Register Employee, Auth User, and Users table
  // Future<void> registerEmployee() async {
  //   String name = nameController.text.trim();
  //   String phone = phoneController.text.trim();
  //   String email = emailController.text.trim();
  //   String password = passwordController.text.trim();

  //   if (name.isEmpty || phone.isEmpty || password.isEmpty || selectedDeptId == null) {
  //     showCustomAlert(
  //       context,
  //       isSuccess: false,
  //       title: "Missing Fields",
  //       description: "Please fill Name, Phone, Password and Department.",
  //     );
  //     return;
  //   }

  //   setState(() => isLoading = true);

  //   try {
  //     /// ✅ 1. Create user in Supabase Auth
  //     final authResponse = await supabase.auth.signUp(
  //       email: email.isNotEmpty ? email : "$phone@company.com", // fallback email
  //       password: password,
  //       data: {
  //         'full_name': name,
  //         'phone': phone,
  //         'role': 'employee',
  //       },
  //     );

  //     final userId = authResponse.user?.id;
  //     if (userId == null) {
  //       throw Exception("Authentication failed");
  //     }

  //     /// ✅ 2. Insert into employee table
  //     final employeeResponse = await supabase.from('employee').insert({
  //       'emp_id': userId, // Use same ID as Auth user
  //       'emp_name': name,
  //       'emp_phone': phone,
  //       'emp_email': email.isEmpty ? null : email,
  //       'dept': selectedDeptId, // Department ID (foreign key)
  //     });

  //     debugPrint("Employee Insert Response: $employeeResponse");

  //     /// ✅ 3. Insert into users table (Role = employee)
  //     final usersResponse = await supabase.from('users').insert({
  //       'user_id': userId, // Same UUID as Auth user
  //       'user_name': name,
  //       'user_phone': phone,
  //       'user_email': email.isEmpty ? null : email,
  //       'role': 'employee',
  //     });

  //     debugPrint("Users Table Insert Response: $usersResponse");

  //     showCustomAlert(
  //       context,
  //       isSuccess: true,
  //       title: "Registration Successful",
  //       description: "Employee has been registered successfully.",
  //     );

  //     /// ✅ Reset fields
  //     nameController.clear();
  //     phoneController.clear();
  //     emailController.clear();
  //     passwordController.clear();
  //     setState(() => selectedDeptId = null);

  //   } on AuthException catch (error) {
  //     debugPrint("Auth Error: ${error.message}");
  //     showCustomAlert(
  //       context,
  //       isSuccess: false,
  //       title: "Authentication Error",
  //       description: error.message,
  //     );
  //   } on PostgrestException catch (error) {
  //     debugPrint("Database Error: ${error.message}");
  //     showCustomAlert(
  //       context,
  //       isSuccess: false,
  //       title: "Database Error",
  //       description: error.message,
  //     );
  //   } catch (e) {
  //     debugPrint("Unknown Error: $e");
  //     showCustomAlert(
  //       context,
  //       isSuccess: false,
  //       title: "Error",
  //       description: "Something went wrong. Please try again.",
  //     );
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }

  Future<void> registerEmployee() async {
  String name = nameController.text.trim();
  String phone = phoneController.text.trim();
  String email = emailController.text.trim();
  String password = passwordController.text.trim();

  if (name.isEmpty || phone.isEmpty || password.isEmpty || selectedDeptId == null) {
    showCustomAlert(
      context,
      isSuccess: false,
      title: "Missing Fields",
      description: "Please fill Name, Phone, Password and Department.",
    );
    return;
  }

  setState(() => isLoading = true);

  try {
    /// ✅ 1. Create user in Supabase Auth
    final authResponse = await supabase.auth.signUp(
      email: email.isNotEmpty ? email : "$phone@company.com", // fallback email
      password: password,
      data: {
        'full_name': name,
        'phone': phone,
        'role': 'employee',
      },
    );

    final userId = authResponse.user?.id;
    if (userId == null) {
      throw Exception("Authentication failed");
    }

    /// ✅ 2. Insert into employee table and get emp_id
    final employeeResponse = await supabase.from('employee').insert({
      'emp_id': userId, // Use same ID as Auth user
      'emp_name': name,
      'emp_phone': phone,
      'emp_email': email.isEmpty ? null : email,
      'dept': selectedDeptId,
    }).select('emp_id').single();

    final empId = employeeResponse['emp_id'];

    /// ✅ 3. Insert into users table (Role = employee) including emp_id
    await supabase.from('users').insert({
      'user_id': userId, // Same UUID as Auth user
      'user_name': name,
      'user_phone': phone,
      'user_email': email.isEmpty ? null : email,
      'role': 'employee',
      'emp_id': empId, // ✅ Storing emp_id here
    });

    showCustomAlert(
      context,
      isSuccess: true,
      title: "Registration Successful",
      description: "Employee has been registered successfully.",
      nextScreen:EmployeeListScreen(),
    );

    /// ✅ Reset fields
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
    setState(() => selectedDeptId = null);

  } on AuthException catch (error) {
    debugPrint("Auth Error: ${error.message}");
    showCustomAlert(
      context,
      isSuccess: false,
      title: "Authentication Error",
      description: error.message,
    );
  } on PostgrestException catch (error) {
    debugPrint("Database Error: ${error.message}");
    showCustomAlert(
      context,
      isSuccess: false,
      title: "Database Error",
      description: error.message,
    );
  } catch (e) {
    debugPrint("Unknown Error: $e");
    showCustomAlert(
      context,
      isSuccess: false,
      title: "Error",
      description: "Something went wrong. Please try again.",
    );
  } finally {
    setState(() => isLoading = false);
  }
}


InputDecoration customInputDecoration(String label, {Widget? prefixIcon}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: prefixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: KDRTColors.darkBlue, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: KDRTColors.darkBlue, width: 2),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Register Employee",
            style: TextStyle(color: Colors.white),
          ),
           centerTitle: true,
          backgroundColor: KDRTColors.darkBlue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
               const SizedBox(height: 40),

/// Employee Name
TextField(
  controller: nameController,
  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  decoration: customInputDecoration(
    "Employee Name",
    prefixIcon: const Icon(Icons.person, color: KDRTColors.darkBlue),
  ),
),
const SizedBox(height: 16),

/// Employee Phone
TextField(
  controller: phoneController,
  keyboardType: TextInputType.phone,
  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  decoration: customInputDecoration(
    "Employee Phone",
    prefixIcon: const Icon(Icons.phone, color: KDRTColors.darkBlue),
  ),
),
const SizedBox(height: 16),

/// Employee Email
TextField(
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  decoration: customInputDecoration(
    "Employee Email",
    prefixIcon: const Icon(Icons.email, color: KDRTColors.darkBlue),
  ),
),
const SizedBox(height: 16),

/// Password
TextField(
  controller: passwordController,
  obscureText: true,
  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  decoration: customInputDecoration(
    "Password",
    prefixIcon: const Icon(Icons.lock, color: KDRTColors.darkBlue),
  ),
),
const SizedBox(height: 16),

/// ✅ Department Dropdown
isDeptLoading
    ? const Center(child: CircularProgressIndicator())
    : DropdownButtonFormField<String>(
        value: selectedDeptId,
        items: departmentList.map((dept) {
          return DropdownMenuItem<String>(
            value: dept['dept_id'],
            child: Text(dept['dept_name']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedDeptId = value;
          });
        },
        decoration: customInputDecoration(
          "Select Department",
          prefixIcon: const Icon(Icons.apartment, color: KDRTColors.darkBlue),
        ),
      ),
const SizedBox(height: 20),


                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButtonField(
                        label: "Register Employee",
                        width: double.infinity,
                        height: 50,
                        onPressed: registerEmployee,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
