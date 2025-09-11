import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/views/register_employee.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> employeeList = [];
  Map<String, String> deptMap = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await fetchDepartments();
    await fetchEmployees();
  }

  /// ✅ Fetch departments and build map
  Future<void> fetchDepartments() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('department').select();
    for (var dept in response) {
      deptMap[dept['dept_id'].toString()] = dept['dept_name'];
    }
  }

  /// ✅ Fetch employees
  Future<void> fetchEmployees() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('employee').select();

      setState(() {
        employeeList = List<Map<String, dynamic>>.from(response.map((emp) {
          emp['dept_name'] = deptMap[emp['dept'].toString()] ?? '-';
          return emp;
        }));
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching employees: $e");
      setState(() => isLoading = false);
    }
  }

  /// ✅ Delete employee
  Future<void> deleteEmployee(String empId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('employee').delete().eq('emp_id', empId);

      setState(() {
        employeeList.removeWhere((emp) => emp['emp_id'] == empId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Employee deleted successfully")),
      );
    } catch (e) {
      debugPrint("Error deleting employee: $e");
    }
  }

  /// ✅ Edit employee on same page using Bottom Sheet
  void editEmployee(Map<String, dynamic> employee) {
    TextEditingController nameController =
        TextEditingController(text: employee['emp_name']);
    TextEditingController emailController =
        TextEditingController(text: employee['emp_email']);
    TextEditingController phoneController =
        TextEditingController(text: employee['emp_phone']);
    String selectedDept = employee['dept'].toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Edit Employee",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedDept,
                  decoration: const InputDecoration(labelText: "Department"),
                  items: deptMap.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedDept = value!;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final supabase = Supabase.instance.client;
                      await supabase.from('employee').update({
                        'emp_name': nameController.text.trim(),
                        'emp_email': emailController.text.trim(),
                        'emp_phone': phoneController.text.trim(),
                        'dept': selectedDept,
                      }).eq('emp_id', employee['emp_id']);

                      Navigator.pop(context);
                      fetchEmployees();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Employee updated successfully")),
                      );
                    } catch (e) {
                      debugPrint("Error updating employee: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KDRTColors.darkBlue,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Update", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Employee Details",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: KDRTColors.darkBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: KDRTColors.darkBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EmployeeRegisterPage(role: '')),
          ).then((value) => fetchEmployees());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : employeeList.isEmpty
              ? const Center(child: Text("No employees found."))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: SingleChildScrollView(
                            child: DataTable(
                              columnSpacing: 20,
                              headingRowColor:
                                  WidgetStateProperty.all(KDRTColors.darkBlue),
                              headingTextStyle: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                              columns: const [
                                DataColumn(label: Text("Emp ID")),
                                DataColumn(label: Text("Name")),
                                DataColumn(label: Text("Email ID")),
                                DataColumn(label: Text("Department")),
                                DataColumn(label: Text("Mobile")),
                                DataColumn(label: Text("Actions")),
                              ],
                              rows: employeeList.map((emp) {
                                return DataRow(cells: [
                                  DataCell(Text(emp['emp_id'].toString())),
                                  DataCell(Text(emp['emp_name'] ?? '-')),
                                  DataCell(Text(emp['emp_email'] ?? '-')),
                                  DataCell(Text(emp['dept_name'] ?? '-')),
                                  DataCell(Text(emp['emp_phone'] ?? '-')),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => editEmployee(emp),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () =>
                                            deleteEmployee(emp['emp_id']),
                                      ),
                                    ],
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
