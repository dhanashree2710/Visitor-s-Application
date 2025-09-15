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
  List<Map<String, dynamic>> _filteredDepartments = [];
  final TextEditingController _searchController = TextEditingController();

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
        _filteredDepartments = _departments; // default show all
        isLoading = false;
      });

      debugPrint("✅ Departments fetched: ${_departments.length}");
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ Error fetching departments: $e");
    }
  }

  /// ✅ Apply search filter
  void _filterDepartments(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDepartments = _departments;
      } else {
        _filteredDepartments = _departments
            .where((dept) =>
                dept['dept_name']
                        ?.toString()
                        .toLowerCase()
                        .contains(query.toLowerCase()) ??
                false)
            .toList();
      }
    });
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

  /// ✅ Check if device is desktop/tablet
  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1000;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);

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
      body: Column(
        children: [
          /// 🔹 Search + Refresh Row
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                /// Search field
                Expanded(
                 child: TextField(
  controller: _searchController,
  onChanged: _filterDepartments,
  decoration: InputDecoration(
    hintText: "Search by department name...",
    prefixIcon: const Icon(Icons.search, color: KDRTColors.darkBlue),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: KDRTColors.darkBlue,
        width: 2,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: KDRTColors.darkBlue,
        width: 2.5,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
  ),
),

                ),
                const SizedBox(width: 12),

                /// Refresh button (only Desktop/Tablet)
                if (isDesktop)
                  ElevatedButton.icon(
                    onPressed: fetchDepartments,
                   
                   
        label: const Text("Refresh",
        style: const TextStyle(
            fontSize: 12,
            color: KDRTColors.white,
            fontWeight: FontWeight.bold,
          ),),
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
          ),

          /// 🔹 Departments Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchDepartments, // only visible on mobile scroll
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredDepartments.isEmpty
                      ? const Center(child: Text("No departments found!"))
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _getCrossAxisCount(context),
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.2,
                              ),
                              itemCount: _filteredDepartments.length,
                              itemBuilder: (context, index) {
                                final dept = _filteredDepartments[index];
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.business,
                                            color: KDRTColors.darkBlue,
                                            size: 40),
                                        const SizedBox(height: 12),
                                        Text(
                                          dept['dept_name'] ?? '',
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
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
          ),
        ],
      ),
    );
  }
}
