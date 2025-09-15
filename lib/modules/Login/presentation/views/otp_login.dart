// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:visitors_and_grievance_application/modules/Admin/presentation/views/home_dashboard.dart';
// import 'package:visitors_and_grievance_application/modules/Admin/presentation/views/register_department.dart';
// import 'package:visitors_and_grievance_application/modules/Employee/presentation/views/employee_home_dashboard.dart';
// import 'package:visitors_and_grievance_application/utils/common/pop_up_screen.dart';
// import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';
// import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';

// class UserLoginPage extends StatefulWidget {
//   const UserLoginPage({super.key});

//   @override
//   State<UserLoginPage> createState() => _UserLoginPageState();
// }

// class _UserLoginPageState extends State<UserLoginPage> {
//   final supabase = Supabase.instance.client;
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool isLoading = false;

//   /// ✅ Main login function
//   Future<void> loginUser() async {
//     final email = emailController.text.trim();
//     final password = passwordController.text.trim();

//     if (email.isEmpty || password.isEmpty) {
//       _showError("Please enter both email and password");
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       /// ✅ Authenticate user in Supabase Auth
//       final response = await supabase.auth.signInWithPassword(
//         email: email,
//         password: password,
//       );

//       if (response.session == null) {
//         _showError("Invalid email or password");
//         return;
//       }

//       /// ✅ Now fetch user role from `users` table
//       await _fetchUserRoleAndNavigate(email);
//     } on AuthException catch (e) {
//       _showError(e.message);
//     } catch (e) {
//       _showError("Error during login: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   /// ✅ Fetch role and navigate accordingly
//   Future<void> _fetchUserRoleAndNavigate(String email) async {
//     try {
//       final userData = await supabase
//           .from('users')
//           .select('role')
//           .eq('user_email', email)
//           .maybeSingle();

//       if (userData == null) {
//         _showError("User record not found in database");
//         return;
//       }

//       final role = userData['role'];

//       if (role == 'admin') {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => AdminHomeScreen(role: role),
//           ),
//         );
//       } else if (role == 'employee') {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => EmployeeDashboard(role: role),
//           ),
//         );
//       // } else {
//       //   Navigator.pushReplacement(
//       //     context,
//       //     MaterialPageRoute(
//       //       builder: (_) => VisitorHomeScreen(role: role),
//       //     ),
//       //   );
//        }
//     } catch (e) {
//       _showError("Failed to fetch role: $e");
//     }
//   }

//   void _showError(String msg) {
//     showCustomAlert(context,
//         isSuccess: false, title: "Error", description: msg);
//   }

//   void _showSuccess(String msg) {
//     showCustomAlert(context,
//         isSuccess: true, title: "Success", description: msg);
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
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: KDRTColors.darkBlue,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: Center(child: Container(margin: EdgeInsets.only(right: 50),
//           child: const Text("Login", style: TextStyle(color: Colors.white),textAlign: TextAlign.center,))),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 400),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 40),
//                 TextField(
//                   controller: emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: customInputDecoration("Email Address"),
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: passwordController,
//                   obscureText: true,
//                   decoration: customInputDecoration("Password"),
//                 ),
//                 const SizedBox(height: 10),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () async {
//                       final email = emailController.text.trim();
//                       if (email.isNotEmpty) {
//                         await supabase.auth.resetPasswordForEmail(email);
//                         _showSuccess("Password reset email sent to $email");
//                       } else {
//                         _showError("Enter email to reset password");
//                       }
//                     },
//                     child: Text(
//                       "Forgot Password?",
//                       style: TextStyle(color: KDRTColors.darkBlue),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : CustomButtonField(
//                         label: "Login",
//                         width: double.infinity,
//                         height: 50,
//                         onPressed: loginUser,
//                       ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// // }

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/views/home_dashboard.dart';
import 'package:visitors_and_grievance_application/modules/Employee/presentation/views/employee_home_dashboard.dart';
import 'package:visitors_and_grievance_application/modules/Login/presentation/views/forgot_password.dart';
import 'package:visitors_and_grievance_application/utils/common/pop_up_screen.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';
import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  /// ✅ Main login function
  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Please enter both email and password");
      return;
    }

    setState(() => isLoading = true);

    try {
      /// ✅ Authenticate user in Supabase Auth
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        _showError("Invalid email or password");
        return;
      }

      /// ✅ Now fetch user role and navigate
      await _fetchUserRoleAndNavigate(email);
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError("Error during login: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ✅ Fetch role and ID (adminId or empId) and navigate accordingly
  Future<void> _fetchUserRoleAndNavigate(String email) async {
    try {
      print("🔍 Fetching role and IDs for email: $email");

      final userData = await supabase
          .from('users')
          .select('role, emp_id, admin_id')
          .eq('user_email', email)
          .maybeSingle(); // ✅ FIX: no `.users` here!

      print("📦 Supabase response: $userData");

      if (userData == null) {
        _showError("User record not found in database");
        print("❌ No user found for email: $email");
        return;
      }

      final role = userData['role'];
      final empId = userData['emp_id'];
      final adminId = userData['admin_id'];

      print("✅ User role: $role | empId: $empId | adminId: $adminId");

      if (role == 'admin') {
        print("➡️ Navigating to AdminHomeScreen...");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminHomeScreen(role: role, adminId: adminId),
          ),
        );
      } else if (role == 'employee') {
        print("➡️ Navigating to EmployeeDashboard...");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmployeeDashboard(role: role, empId: empId),
          ),
        );
      } else {
        _showError("Invalid role assigned to user");
        print("⚠️ Invalid role: $role");
      }
    } catch (e) {
      _showError("Failed to fetch role: $e");
      print("❌ Error fetching role for $email: $e");
    }
  }

  void _showError(String msg) {
    print("❌ ERROR: $msg");
    showCustomAlert(
      context,
      isSuccess: false,
      title: "Error",
      description: msg,
    );
  }

  void _showSuccess(String msg) {
    print("✅ SUCCESS: $msg");
    showCustomAlert(
      context,
      isSuccess: true,
      title: "Success",
      description: msg,
    );
  }

  InputDecoration customInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: KDRTColors.darkBlue),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: KDRTColors.darkBlue, width: 3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: KDRTColors.darkBlue, width: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: KDRTColors.darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Center(
          child: Text(
            "Login",
            style: TextStyle(color: Colors.white),
          ),
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
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: customInputDecoration("Email Address"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: customInputDecoration("Password"),
                ),
                const SizedBox(height: 10),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: GestureDetector(
                //     onTap: () async {
                //       final email = emailController.text.trim();
                //       if (email.isNotEmpty) {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (_) => const ForgotPasswordView(),
                //           ),
                //         );
                //       } else {
                //         _showError("Enter email to reset password");
                //       }
                //     },
                //     child: Text(
                //       "Forgot Password?",
                //       style: TextStyle(color: KDRTColors.darkBlue),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 20),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButtonField(
                        label: "Login",
                        width: double.infinity,
                        height: 50,
                        onPressed: loginUser,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
