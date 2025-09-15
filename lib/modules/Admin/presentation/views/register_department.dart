import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/views/home_dashboard.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/widgets/department_list.dart';
import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';
import 'package:visitors_and_grievance_application/utils/common/pop_up_screen.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class DepartmentRegisterPage extends StatefulWidget {
  

  const DepartmentRegisterPage({super.key});

  @override
  State<DepartmentRegisterPage> createState() => _DepartmentRegisterPageState();
}

class _DepartmentRegisterPageState extends State<DepartmentRegisterPage> {
  final TextEditingController deptNameController = TextEditingController();
  final supabase = Supabase.instance.client;

  bool isLoading = false;

  /// ✅ Register Department
  Future<void> registerDepartment() async {
    String deptName = deptNameController.text.trim();

    if (deptName.isEmpty) {
      showCustomAlert(
        context,
        isSuccess: false,
        title: "Missing Field",
        description: "Please enter Department Name.",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await supabase.from('department').insert({
        'dept_name': deptName,
      });

      showCustomAlert(
        context,
        isSuccess: true,
        title: "Registration Successful",
        description: "Department has been registered successfully.",
        nextScreen: DepartmentListScreen(),
      );

      deptNameController.clear();
    } on PostgrestException catch (error) {
      showCustomAlert(
        context,
        isSuccess: false,
        title: "Error",
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
    labelStyle: const TextStyle(color: KDRTColors.darkBlue),
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
            "Register Department",
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
  controller: deptNameController,
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: KDRTColors.black,
  ),
  decoration: customInputDecoration(
    "Department Name",
    prefixIcon: const Icon(Icons.business, color: KDRTColors.darkBlue),
  ),
),

const SizedBox(height: 20),


                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButtonField(
                        label: "Register Department",
                        width: double.infinity,
                        height: 50,
                        onPressed: registerDepartment,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
