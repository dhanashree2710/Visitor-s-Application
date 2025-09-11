import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class DepartmentListScreen extends StatefulWidget {
  const DepartmentListScreen({super.key});

  @override
  State<DepartmentListScreen> createState() => _DepartmentListScreenState();
}

class _DepartmentListScreenState extends State<DepartmentListScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> _departments = [];

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  /// ✅ Fetch Departments from Supabase
  Future<void> fetchDepartments() async {
    try {
      setState(() => isLoading = true);

      final response =
          await Supabase.instance.client.from('department').select();

      setState(() {
        _departments = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });

      debugPrint("✅ Departments fetched: ${_departments.length}");
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ Error fetching departments: $e");
    }
  }

  /// ✅ Responsive Grid Count
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 2; // Mobile
    if (width < 1000) return 3; // Tablet
    return 4; // Desktop
  }

  /// ✅ Responsive Font Size
  double _getFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 14; // Mobile
    if (width < 1000) return 16; // Tablet
    return 18; // Desktop
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Departments",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: KDRTColors.darkBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: fetchDepartments,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _departments.isEmpty
                ? const Center(child: Text("No departments found!"))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _getCrossAxisCount(context),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: _departments.length,
                        itemBuilder: (context, index) {
                          final dept = _departments[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: KDRTColors.darkBlue,
                                width: 2,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.business,
                                      color: KDRTColors.darkBlue, size: 40),
                                  const SizedBox(height: 12),
                                 Text(
  dept['dept_name'] ?? '',
  textAlign: TextAlign.center,
  overflow: TextOverflow.ellipsis, // adds "..." for long names
  maxLines: 1,
  style: TextStyle(
    fontSize: _getFontSize(context),
    fontWeight: FontWeight.bold,
    color: KDRTColors.darkBlue,
  ),
),


                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
