import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/utils/common/appbar_drawer.dart';
import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';
import 'package:visitors_and_grievance_application/utils/common/pop_up_screen.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class UserRegisterPage extends StatefulWidget {
  final String role;
  const UserRegisterPage({super.key, required this.role,});

  @override
  State<UserRegisterPage> createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final supabase = Supabase.instance.client;

  bool isLoading = false;
  String selectedRole = "visitor"; // default role

  Future<void> registerUser() async {
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      showCustomAlert(
        context,
        isSuccess: false,
        title: "Missing Fields",
        description:
            "Please fill all required fields (Name, Phone, Email, Password).",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      /// ✅ Step 1: Create user in Supabase Authentication
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception("Failed to create authentication user.");
      }

      final userId = authResponse.user!.id;

      /// ✅ Step 2: Insert user details into `users` table
      await supabase.from('users').insert({
        'user_id': userId, // link to auth user
        'user_name': name,
        'user_phone': phone,
        'user_email': email,
        'role': selectedRole,
      });

      showCustomAlert(
        context,
        isSuccess: true,
        title: "Registration Successful",
        description: "User has been registered successfully.",
      );

      nameController.clear();
      phoneController.clear();
      emailController.clear();
      passwordController.clear();
      setState(() => selectedRole = "visitor");
    } on AuthException catch (error) {
      showCustomAlert(
        context,
        isSuccess: false,
        title: "Auth Error",
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
    return CommonScaffold(
      title: "User Registration",
      role: widget.role,
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
                  style: TextStyle(
                    color: KDRTColors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: customInputDecoration("User Name"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    color: KDRTColors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: customInputDecoration("User Phone"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: KDRTColors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: customInputDecoration("User Email"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(
                    color: KDRTColors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: customInputDecoration("Password"),
                ),
                const SizedBox(height: 16),

                /// Dropdown for Role Selection
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: customInputDecoration("Select Role"),
                  items: const [
                    DropdownMenuItem(value: "admin", child: Text("Admin")),
                    DropdownMenuItem(
                        value: "employee", child: Text("Employee")),
                    DropdownMenuItem(value: "visitor", child: Text("Visitor")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),

                /// Button
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButtonField(
                        label: "Register User",
                        width: double.infinity,
                        height: 50,
                        onPressed: registerUser,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
