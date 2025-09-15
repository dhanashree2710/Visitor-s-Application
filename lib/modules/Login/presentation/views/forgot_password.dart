// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:visitors_and_grievance_application/modules/Login/presentation/views/otp_login.dart';
// import 'package:visitors_and_grievance_application/utils/common/pop_up_screen.dart';
// import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';
// class ForgotPasswordView extends StatefulWidget {
//   const ForgotPasswordView({super.key});

//   @override
//   State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
// }

// class _ForgotPasswordViewState extends State<ForgotPasswordView> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   bool isLoading = false;
//   bool obscurePassword = true;

//   /// 🔹 Reset Password in users, admin, employee
// Future<void> _resetPassword() async {
//   if (!_formKey.currentState!.validate()) return;

//   setState(() => isLoading = true);

//   final email = _emailController.text.trim();
//   final newPassword = _passwordController.text.trim();

//   try {
//     final supabase = Supabase.instance.client;

//     // Update in users
//     final userRes = await supabase
//         .from('users')
//         .update({'user_password': newPassword})
//         .eq('user_email', email)
//         .select(); // 👈 force return
//     print("✅ Users table update result: $userRes");

//     // Update in admin
//     final adminRes = await supabase
//         .from('admin')
//         .update({'admin_password': newPassword})
//         .eq('admin_email', email)
//         .select(); // 👈
//     print("✅ Admin table update result: $adminRes");

//     // Update in employee
//     final empRes = await supabase
//         .from('employee')
//         .update({'password': newPassword})
//         .eq('emp_email', email)
//         .select(); // 👈
//     print("✅ Employee table update result: $empRes");

//     if ((userRes as List).isEmpty &&
//         (adminRes as List).isEmpty &&
//         (empRes as List).isEmpty) {
//       showCustomAlert(
//         context,
//         isSuccess: false,
//         title: 'Error',
//         description: 'Email not found. Please check and try again.',
//       );
//     } else {
//       _emailController.clear();
//       _passwordController.clear();
//       showCustomAlert(
//         context,
//         isSuccess: true,
//         title: 'Success',
//         description: 'Password updated successfully everywhere!',
//         nextScreen: UserLoginPage(),
//       );
//     }
//   } catch (e) {
//     print("❌ Error while resetting password: $e");
//     showCustomAlert(
//       context,
//       isSuccess: false,
//       title: 'Error',
//       description: 'Something went wrong: $e',
//     );
//   } finally {
//     setState(() => isLoading = false);
//   }
// }


//   /// 🔹 Form Field (Dark Blue)
//   Widget _buildFormField({
//     required TextEditingController controller,
//     required String hintText,
//     required IconData prefixIcon,
//     IconData? suffixIcon,
//     bool obscureText = false,
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//     VoidCallback? onSuffixTap,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       child: TextFormField(
//         controller: controller,
//         obscureText: obscureText,
//         keyboardType: keyboardType,
//         validator: validator,
//         style: const TextStyle(color: Colors.black),
//         decoration: InputDecoration(
//           hintText: hintText,
//           prefixIcon: Icon(prefixIcon, color: KDRTColors.darkBlue),
//           suffixIcon: suffixIcon != null
//               ? GestureDetector(
//                   onTap: onSuffixTap,
//                   child: Icon(suffixIcon, color: KDRTColors.darkBlue),
//                 )
//               : null,
//           filled: true,
//           fillColor: Colors.grey[100],
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(color: KDRTColors.darkBlue, width: 1),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(color: KDRTColors.darkBlue, width: 1),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(color: KDRTColors.darkBlue, width: 2),
//           ),
//         ),
//       ),
//     );
//   }

//   /// 🔹 Dark Blue Button
//   Widget _buildButton({
//     required String text,
//     required VoidCallback onPressed,
//   }) {
//     return InkWell(
//       onTap: isLoading ? null : onPressed,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         decoration: BoxDecoration(
//           color: KDRTColors.darkBlue,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.shade200,
//               blurRadius: 6,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Center(
//           child: isLoading
//               ? const CircularProgressIndicator(color: Colors.white)
//               : Text(
//                   text,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width > 600;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: KDRTColors.darkBlue,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Forgot Password",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Container(
//           width: isDesktop ? 500 : double.infinity,
//           padding: const EdgeInsets.all(24),
//           margin: isDesktop
//               ? const EdgeInsets.symmetric(horizontal: 0)
//               : const EdgeInsets.all(12),
//           decoration: isDesktop
//               ? BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       blurRadius: 8,
//                       color: Colors.black.withOpacity(0.1),
//                     ),
//                   ],
//                 )
//               : null,
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildFormField(
//                   controller: _emailController,
//                   hintText: 'Enter your email',
//                   prefixIcon: Icons.email,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (val) => val == null || !val.contains('@')
//                       ? 'Enter a valid email'
//                       : null,
//                 ),
//                 _buildFormField(
//                   controller: _passwordController,
//                   hintText: 'Enter new password',
//                   prefixIcon: Icons.lock,
//                   suffixIcon:
//                       obscurePassword ? Icons.visibility : Icons.visibility_off,
//                   obscureText: obscurePassword,
//                   validator: (val) => val == null || val.length < 6
//                       ? 'Password must be at least 6 characters'
//                       : null,
//                   onSuffixTap: () {
//                     setState(() => obscurePassword = !obscurePassword);
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 _buildButton(
//                   text: "Reset Password",
//                   onPressed: _resetPassword,
//                 ),
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
import 'package:visitors_and_grievance_application/modules/Login/presentation/views/otp_login.dart';
import 'package:visitors_and_grievance_application/utils/common/pop_up_screen.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  final supabase = Supabase.instance.client;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final email = _emailController.text.trim();
    final newPassword = _passwordController.text.trim();

    try {
      print("🔍 Starting password reset for: $email");

      // 1️⃣ Update in custom tables
      final userRes = await supabase
          .from('users')
          .update({'user_password': newPassword})
          .eq('user_email', email)
          .select();
      print("✅ Users table update result: $userRes");

      final adminRes = await supabase
          .from('admin')
          .update({'admin_password': newPassword})
          .eq('admin_email', email)
          .select();
      print("✅ Admin table update result: $adminRes");

      final empRes = await supabase
          .from('employee')
          .update({'password': newPassword})
          .eq('emp_email', email)
          .select();
      print("✅ Employee table update result: $empRes");

      // 2️⃣ Update in Supabase Auth
      try {
        final usersList = await supabase.auth.admin.listUsers(); // List<User>

       final User? authUser = usersList.firstWhere(
          (u) => u.email == email,
          orElse: () => null as User, // cast avoids type error
        );

        if (authUser != null) {
          await supabase.auth.admin.updateUserById(
            authUser.id,
            attributes: AdminUserAttributes(password: newPassword),
          );
          print("✅ Supabase Auth password updated for: $email");
        } else {
          print("⚠️ Email not found in Supabase Auth, updating only custom tables");
        }
      } catch (authError) {
        print("❌ Error updating Supabase Auth password: $authError");
      }

      // 3️⃣ Show alert based on results
      if ((userRes as List).isEmpty &&
          (adminRes as List).isEmpty &&
          (empRes as List).isEmpty) {
        print("❌ No records found in custom tables for email: $email");
        showCustomAlert(
          context,
          isSuccess: false,
          title: 'Error',
          description: 'Email not found. Please check and try again.',
        );
      } else {
        _emailController.clear();
        _passwordController.clear();
        print("✅ Password updated successfully everywhere for $email");
        showCustomAlert(
          context,
          isSuccess: true,
          title: 'Success',
          description: 'Password updated successfully everywhere!',
          nextScreen: UserLoginPage(),
        );
      }
    } catch (e) {
      print("❌ Error while resetting password: $e");
      showCustomAlert(
        context,
        isSuccess: false,
        title: 'Error',
        description: 'Something went wrong: $e',
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 🔹 Form Field
  Widget _buildFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    IconData? suffixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    VoidCallback? onSuffixTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, color: KDRTColors.darkBlue),
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Icon(suffixIcon, color: KDRTColors.darkBlue),
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: KDRTColors.darkBlue, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: KDRTColors.darkBlue, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: KDRTColors.darkBlue, width: 2),
          ),
        ),
      ),
    );
  }

  /// 🔹 Dark Blue Button
  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: KDRTColors.darkBlue,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade200,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: KDRTColors.darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Forgot Password",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: isDesktop ? 500 : double.infinity,
          padding: const EdgeInsets.all(24),
          margin: isDesktop
              ? const EdgeInsets.symmetric(horizontal: 0)
              : const EdgeInsets.all(12),
          decoration: isDesktop
              ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                )
              : null,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFormField(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val == null || !val.contains('@')
                      ? 'Enter a valid email'
                      : null,
                ),
                _buildFormField(
                  controller: _passwordController,
                  hintText: 'Enter new password',
                  prefixIcon: Icons.lock,
                  suffixIcon:
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                  obscureText: obscurePassword,
                  validator: (val) => val == null || val.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                  onSuffixTap: () {
                    setState(() => obscurePassword = !obscurePassword);
                  },
                ),
                const SizedBox(height: 24),
                _buildButton(
                  text: "Reset Password",
                  onPressed: _resetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
