// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:visitors_and_grievance_application/utils/common/appbar_drawer.dart';
// import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';
// import 'package:visitors_and_grievance_application/utils/common/pop_up_screen.dart';
// import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

// class AdminRegisterPage extends StatefulWidget {
//   const AdminRegisterPage({super.key});

//   @override
//   State<AdminRegisterPage> createState() => _AdminRegisterPageState();
// }

// class _AdminRegisterPageState extends State<AdminRegisterPage> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();

//   final supabase = Supabase.instance.client;

//   bool isLoading = false;

//   Future<void> registerAdmin() async {
//     String name = nameController.text.trim();
//     String phone = phoneController.text.trim();
//     String email = emailController.text.trim();

//     if (name.isEmpty || phone.isEmpty || email.isEmpty) {
//       showCustomAlert(
//         context,
//         isSuccess: false,
//         title: "Missing Fields",
//         description: "Please fill all the fields.",
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       await supabase.from('admin').insert({
//         'admin_name': name,
//         'admin_phone': phone,
//         'admin_email': email,
//       });

//       showCustomAlert(
//         context,
//         isSuccess: true,
//         title: "Registration Successful",
//         description: "Admin has been registered successfully.",
//       );

//       nameController.clear();
//       phoneController.clear();
//       emailController.clear();
//     } on PostgrestException catch (error) {
//       showCustomAlert(
//         context,
//         isSuccess: false,
//         title: "Error",
//         description: error.message,
//       );
//     } catch (e) {
//       showCustomAlert(
//         context,
//         isSuccess: false,
//         title: "Error",
//         description: "Something went wrong. Please try again.",
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   InputDecoration customInputDecoration(String label) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: TextStyle(color: KDRTColors.darkBlue),
//       filled: true,
//       fillColor: Colors.white,
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: KDRTColors.darkBlue, width: 3),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: KDRTColors.darkBlue, width: 3),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CommonScaffold(
//       title: "Admin Registration",
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 400),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // const Text(
//                 //   "Register Admin",
//                 //   style: TextStyle(
//                 //     fontSize: 30,
//                 //     fontWeight: FontWeight.bold,
//                 //     color: KDRTColors.darkBlue,
//                 //   ),
//                 //   textAlign: TextAlign.center,
//                 // ),
//                 const SizedBox(height: 40),
//                 TextField(
//                   controller: nameController,
//                   style: TextStyle(
//                     color: KDRTColors.black,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   decoration: customInputDecoration("Admin Name"),
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: phoneController,
//                   keyboardType: TextInputType.phone,
//                   style: TextStyle(
//                     color: KDRTColors.black,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   decoration: customInputDecoration("Admin Phone"),
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   style: TextStyle(
//                     color: KDRTColors.black,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   decoration: customInputDecoration("Admin Email"),
//                 ),
//                 const SizedBox(height: 20),
//                 isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : CustomButtonField(
//                         label: "Register Admin",
//                         width: double.infinity,
//                         height: 50,
//                         onPressed: registerAdmin,
//                       ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/views/home_dashboard.dart';
import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';
import 'package:visitors_and_grievance_application/utils/common/pop_up_screen.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class AdminRegisterPage extends StatefulWidget {
final String role;
const AdminRegisterPage({super.key, required this.role});
  @override
  State<AdminRegisterPage> createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final supabase = Supabase.instance.client;
  bool isLoading = false;
Future<void> registerAdmin() async {
  String name = nameController.text.trim();
  String phone = phoneController.text.trim();
  String email = emailController.text.trim();
  String password = passwordController.text.trim();

  if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
    showCustomAlert(
      context,
      isSuccess: false,
      title: "Missing Fields",
      description: "Please fill all fields including password.",
    );
    return;
  }

  setState(() => isLoading = true);

  try {
    /// ✅ 1. Create user in Supabase Auth
    final authResponse = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': name,
        'phone': phone,
        'role': 'admin',
      },
    );

    final userId = authResponse.user?.id;
    if (userId == null) {
      throw Exception("Authentication failed");
    }

    /// ✅ 2. Insert into admin table and return admin_id
    final adminResponse = await supabase
        .from('admin')
        .insert({
          'admin_id': userId, // Same as Auth user ID
          'admin_name': name,
          'admin_phone': phone,
          'admin_email': email,
        })
        .select('admin_id')
        .single();

    final adminId = adminResponse['admin_id'];

    /// ✅ 3. Insert into users table with admin_id
    await supabase.from('users').insert({
      'user_id': userId, // Same UUID as Auth user
      'user_name': name,
      'user_phone': phone,
      'user_email': email,
      'role': 'admin',
      'admin_id': adminId, // ✅ store admin_id here
    });

    /// ✅ Show success popup
    showCustomAlert(
      context,
      isSuccess: true,
      title: "Registration Successful",
      description: "Admin registered and linked with authentication.",
      nextScreen: AdminHomeScreen(role: widget.role, adminId: adminId)
    );

    /// ✅ Clear fields
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();

  } on AuthException catch (error) {
    showCustomAlert(
      context,
      isSuccess: false,
      title: "Authentication Error",
      description: error.message,
    );
  } on PostgrestException catch (error) {
    showCustomAlert(
      context,
      isSuccess: false,
      title: "Database Error",
      description: error.message,
    );
  } catch (e) {
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
            "Register Admin",
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

TextField(
  controller: nameController,
  style: const TextStyle(
    color: KDRTColors.black,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
  decoration: customInputDecoration(
    "Admin Name",
    prefixIcon: const Icon(Icons.person, color: KDRTColors.darkBlue),
  ),
),
const SizedBox(height: 16),

TextField(
  controller: phoneController,
  keyboardType: TextInputType.phone,
  style: const TextStyle(
    color: KDRTColors.black,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
  decoration: customInputDecoration(
    "Admin Phone",
    prefixIcon: const Icon(Icons.phone, color: KDRTColors.darkBlue),
  ),
),
const SizedBox(height: 16),

TextField(
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  style: const TextStyle(
    color: KDRTColors.black,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
  decoration: customInputDecoration(
    "Admin Email",
    prefixIcon: const Icon(Icons.email, color: KDRTColors.darkBlue),
  ),
),
const SizedBox(height: 16),

TextField(
  controller: passwordController,
  obscureText: true,
  style: const TextStyle(
    color: KDRTColors.black,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
  decoration: customInputDecoration(
    "Password",
    prefixIcon: const Icon(Icons.lock, color: KDRTColors.darkBlue),
  ),
),
const SizedBox(height: 20),

                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButtonField(
                        label: "Register Admin",
                        width: double.infinity,
                        height: 50,
                        onPressed: registerAdmin,
                      ),
              ],
            ),
          ),
        ),
      ), 
    );
  }
}
