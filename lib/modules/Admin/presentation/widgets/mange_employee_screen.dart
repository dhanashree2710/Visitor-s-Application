import 'package:flutter/material.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/views/register_employee.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/widgets/employee_attendence_list.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/widgets/employee_list.dart';

import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class ManageEmployeeScreen extends StatelessWidget {
  const ManageEmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manage Employee",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: KDRTColors.darkBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: KDRTColors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// ---------------- Employee List Button ----------------
                  CustomButton(
                    label: "Employee List",
                    icon: Icons.list_alt,
                    width: isMobile ? double.infinity : (isTablet ? 200 : 250),
                    height: 60,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmployeeListScreen(), // ✅ Navigate to Employee List
                        ),
                      );
                    },
                  ),

                  SizedBox(height: isMobile ? 16 : 0, width: isMobile ? 0 : 16),

                  /// ---------------- Register Employee Button ----------------
                  CustomButton(
                    label: "Register Employee",
                    icon: Icons.person_add,
                    width: isMobile ? double.infinity : (isTablet ? 200 : 250),
                    height: 60,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmployeeRegisterPage(role: '',), // ✅ Navigate to Register Employee
                        ),
                      );
                    },
                  ),

                  SizedBox(height: isMobile ? 16 : 0, width: isMobile ? 0 : 16),

                  /// ---------------- Employee Attendance Button ----------------
                  CustomButton(
                    label: "Employee Attendance",
                    icon: Icons.analytics,
                    width: isMobile ? double.infinity : (isTablet ? 200 : 250),
                    height: 60,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmployeeAttendanceListScreen(), // ✅ Navigate to Attendance List
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
