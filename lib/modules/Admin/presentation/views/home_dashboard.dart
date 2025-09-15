import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/views/register_department.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/views/register_employee.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/widgets/department_list.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/widgets/employee_list.dart';
import 'package:visitors_and_grievance_application/modules/Grievance/presentation/views/grievance_list.dart';
import 'package:visitors_and_grievance_application/modules/Visitors/presentation/widgets/all_visitors_list.dart';
import 'package:visitors_and_grievance_application/utils/common/appbar_drawer.dart';
import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';


class AdminHomeScreen extends StatefulWidget {
  final String role;
  final String adminId;

  const AdminHomeScreen({super.key, required this.role, required this.adminId});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final supabase = Supabase.instance.client;

  int _totalEmployees = 0;
  int _totalVisitors = 0;
  int _totalDepartments = 0;
  int _totalGrievances = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final employees = await supabase.from('employee').select('emp_id');
      final visitors = await supabase.from('visitor').select('visitor_id');
      final departments = await supabase.from('department').select('dept_id');
      final grievances = await supabase.from('grievance').select('grievance_id');

      setState(() {
        _totalEmployees = employees.length;
        _totalVisitors = visitors.length;
        _totalDepartments = departments.length;
        _totalGrievances = grievances.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error fetching data: $e");
    }
  }

  Widget _buildOutlinedCard(String title, int count, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF0D47A1),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Color(0xFF0D47A1),
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(count.toString(),
                style: const TextStyle(
                    color: Color(0xFF0D47A1),
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1024) return 4;
    if (width >= 600) return 3;
    return 2;
  }
@override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isDesktop = screenWidth >= 1024;

  return CommonScaffold(
    title: "",
    role: widget.role,
    body: RefreshIndicator(
      onRefresh: _fetchData,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 👇 Row with Welcome + Refresh button (desktop only)
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              "Welcome Admin!!",
                              style: const TextStyle(
                                fontSize: 24,
                                color: KDRTColors.darkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (isDesktop)
                          ElevatedButton.icon(
                            onPressed: () async {
                              setState(() => _isLoading = true);
                              await _fetchData();
                            },
                            icon: const Icon(Icons.refresh, color: KDRTColors.white, size: 16),
                            label: const Text(
                              "Refresh",
                              style: TextStyle(
                                fontSize: 12,
                                color: KDRTColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KDRTColors.darkBlue,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // 👇 Cards Grid
                    GridView.count(
                      crossAxisCount: _getCrossAxisCount(screenWidth),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.2,
                      children: [
                        _buildOutlinedCard("Employees", _totalEmployees, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmployeeListScreen(),
                            ),
                          );
                        }),
                        _buildOutlinedCard("Visitors", _totalVisitors, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllVisitorsList(),
                            ),
                          );
                        }),
                        _buildOutlinedCard("Departments", _totalDepartments, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DepartmentListScreen(),
                            ),
                          );
                        }),
                        _buildOutlinedCard("Grievances", _totalGrievances, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminGrievanceScreen(),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // 👇 Add Employee Button
                    CustomButtonField(
                      label: "Add Employee",
                      width: double.infinity,
                      height: 50,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmployeeRegisterPage(role: widget.role),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // 👇 Add Department Button
                    CustomButtonField(
                      label: "Add Department",
                      width: double.infinity,
                      height: 50,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DepartmentRegisterPage(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
    ),
  );
}
}