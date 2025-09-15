import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/views/register_admin.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/views/register_department.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/widgets/manage_grievance.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/widgets/mange_employee_screen.dart';
import 'package:visitors_and_grievance_application/modules/Employee/presentation/views/employee_attendence.dart';
import 'package:visitors_and_grievance_application/modules/Employee/presentation/widgets/mange_visitors_screen.dart';
import 'package:visitors_and_grievance_application/modules/Login/presentation/views/role_page.dart';
import '../components/kdrt_colors.dart';

class CommonScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final String role;
  final String? empId; // ✅ Nullable empId

  const CommonScaffold({
    super.key,
    this.empId, // ✅ Not required anymore
    required this.title,
    required this.body,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: KDRTColors.darkBlue,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(context),
      body: body,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final menuItems = <Widget>[
      DrawerHeader(
        decoration: const BoxDecoration(color: Colors.white),
        child: Image.asset(
          role == "admin"
              ? 'assets/admin_drawer.png'
              : 'assets/employee_drawer.png', // Replace with your image path
          fit: BoxFit.cover,
        ),
      ),
      ListTile(
        leading: const Icon(Icons.home, color: KDRTColors.darkBlue),
        title: const Text("Dashboard"),
        onTap: () => Navigator.pop(context),
      ),
    ];

    if (role == "admin") {
      menuItems.addAll([
        ListTile(
          leading: const Icon(Icons.person_add, color: KDRTColors.darkBlue),
          title: const Text("Register Admin"),
          onTap: () {
             Navigator.push(context,
                MaterialPageRoute(builder: (context) => AdminRegisterPage(role: '',)));
          },
        ),
        ListTile(
          leading: const Icon(Icons.people, color: KDRTColors.darkBlue),
          title: const Text("Manage Employees"),
          onTap: () {
             Navigator.push(context,
                MaterialPageRoute(builder: (context) => ManageEmployeeScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.apartment, color: KDRTColors.darkBlue),
          title: const Text("Add Department"),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DepartmentRegisterPage()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.person_add, color: KDRTColors.darkBlue),
          title: const Text("Manage Visitors"),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => VisitorDashboardPage()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.report_problem, color: KDRTColors.darkBlue),
          title: const Text("Manage Grievances"),
          onTap: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => ManageGrievanceScreen()));
          },
        ),
      ]);
    } else if (role == "employee") {
      menuItems.addAll([
        ListTile(
          leading: const Icon(Icons.people, color: KDRTColors.darkBlue),
          title: const Text("Attendance"),
          onTap: () {
            if (empId != null && empId!.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeeAttendanceScreen(empId: empId!),
                ),
              );
            } else {
              debugPrint("empId is null or empty, cannot navigate");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Employee ID is missing. Cannot open Attendance."),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.person_add, color: KDRTColors.darkBlue),
          title: const Text("Manage Visitors"),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => VisitorDashboardPage()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.report_problem, color: KDRTColors.darkBlue),
          title: const Text("Manage Grievances"),
          onTap: () {
             Navigator.push(context,
                MaterialPageRoute(builder: (context) => ManageGrievanceScreen()));
          },
        ),
      ]);
    }

    

    /// ✅ Logout option for all roles
    menuItems.add(
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text("Logout", style: TextStyle(color: Colors.red)),
        onTap: () => _showLogoutConfirmation(context),
      ),
    );

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(children: menuItems),
    );
  }

  /// ✅ Logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: KDRTColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/confirmation.json',
                  height: 120, width: 120, fit: BoxFit.contain),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await Supabase.instance.client.auth.signOut();
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => RoleSelectionPage()),
                          (route) => false,
                        );

                        if (UniversalPlatform.isDesktop) {
                          exit(0);
                        } else if (UniversalPlatform.isMobile) {
                          SystemNavigator.pop();
                        }
                      } catch (e) {
                        debugPrint('Logout error: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: KDRTColors.darkBlue,
                    ),
                    child: const Text('Yes'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: KDRTColors.cyan,
                    ),
                    child: const Text('No'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
