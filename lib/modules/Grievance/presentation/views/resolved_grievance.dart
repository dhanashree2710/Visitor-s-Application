import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class ResolvedGrievanceScreen extends StatefulWidget {
  const ResolvedGrievanceScreen({super.key});

  @override
  State<ResolvedGrievanceScreen> createState() => _ResolvedGrievanceScreenState();
}

class _ResolvedGrievanceScreenState extends State<ResolvedGrievanceScreen> {
  final supabase = Supabase.instance.client;

  List grievances = [];
  List departments = [];
  bool isLoading = true;

  // 🔍 Filters
  String searchGrievanceId = "";
  String searchName = "";
  String searchEmail = "";
  String searchPhone = "";
  String selectedStatus = "All";
  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
    _fetchResolvedGrievances();
  }

  /// Fetch department list
  Future<void> _fetchDepartments() async {
    final response = await supabase.from("department").select();
    setState(() {
      departments = response;
    });
  }

  /// Get department name from ID
  String _getDepartmentName(String? deptId) {
    final dept = departments.firstWhere(
      (d) => d['dept_id'] == deptId,
      orElse: () => {'dept_name': 'Unknown'},
    );
    return dept['dept_name'] ?? 'Unknown';
  }

  /// Fetch grievances with filters
  Future<void> _fetchResolvedGrievances() async {
    setState(() => isLoading = true);

    var query = supabase.from("grievance").select().eq("grievance_status", "resolved");

    // Status filter
    if (selectedStatus != "All") {
      query = query.eq("grievance_status", selectedStatus);
    }

    // Category filter
    if (selectedCategory != "All") {
      final category = departments.firstWhere(
        (d) => d['dept_name'] == selectedCategory,
        orElse: () => null,
      );
      if (category != null) {
        query = query.eq("grievance_category", category['dept_id']);
      }
    }

    // Text filters
    if (searchGrievanceId.isNotEmpty) {
      query = query.ilike("grievance_id", "%$searchGrievanceId%");
    }
    if (searchName.isNotEmpty) {
      query = query.ilike("full_name", "%$searchName%");
    }
    if (searchEmail.isNotEmpty) {
      query = query.ilike("email_id", "%$searchEmail%");
    }
    if (searchPhone.isNotEmpty) {
      query = query.ilike("phone_number", "%$searchPhone%");
    }

    final response = await query;
    setState(() {
      grievances = response;
      isLoading = false;
    });
  }

  /// ✅ Bottom sheet for filters
  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Apply Filters",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                TextField(
                  decoration: const InputDecoration(labelText: "Grievance ID"),
                  onChanged: (v) => searchGrievanceId = v,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Name"),
                  onChanged: (v) => searchName = v,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Email"),
                  onChanged: (v) => searchEmail = v,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Phone"),
                  onChanged: (v) => searchPhone = v,
                ),

                const SizedBox(height: 12),
               DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: "Status"),
                  items: ["All", "Resolved", "Pending", "Rejected"]
                      .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedStatus = v ?? "All"),
                ),


                const SizedBox(height: 12),
               DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: "Category"),
                  items: [
                    const DropdownMenuItem<String>(value: "All", child: Text("All")),
                    ...departments.map((d) {
                      final name = d['dept_name']?.toString() ?? "Unknown";
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      );
                    }),
                  ],
                  onChanged: (v) => setState(() => selectedCategory = v ?? "All"),
                ),


                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KDRTColors.darkBlue,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _fetchResolvedGrievances();
                  },
                  child:
                      const Text("Apply", style: TextStyle(color: Colors.white)),
                )
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
        title: const Text("Resolved Grievances",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: KDRTColors.darkBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          // ✅ Buttons below AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                ElevatedButton.icon(
  icon: const Icon(Icons.refresh, color: Colors.white),
  label: const Text(
    "Refresh",
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
  ),
  onPressed: () {
    setState(() {
      searchGrievanceId = "";
      searchName = "";
      searchEmail = "";
      searchPhone = "";
      selectedStatus = "All";
      selectedCategory = "All";
    });
    _fetchResolvedGrievances(); // reload fresh data
  },
),const SizedBox(width: 12),

      // 🔍 Filter button
      ElevatedButton.icon(
        icon: const Icon(Icons.filter_list, color: Colors.white),
        label: const Text(
          "Filter",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: KDRTColors.darkBlue,
        ),
        onPressed: () => _openFilterSheet(context),
      ),
    ],
  ),
),
          // ✅ Table / Loading / Empty states
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : grievances.isEmpty
                    ? const Center(
                        child: Text("No resolved grievances found",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold)))
                    : InteractiveViewer(
                        constrained: false,
                        scaleEnabled: true,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor:
                                WidgetStateProperty.all(Colors.blue[900]),
                            headingTextStyle:
                                const TextStyle(color: Colors.white),
                            columns: const [
                              DataColumn(label: Text("Grievance ID")),
                              DataColumn(label: Text("Name")),
                              DataColumn(label: Text("Email")),
                              DataColumn(label: Text("Phone")),
                              DataColumn(label: Text("Subject")),
                              DataColumn(label: Text("Details")),
                              DataColumn(label: Text("Category")),
                              DataColumn(label: Text("Priority")),
                              DataColumn(label: Text("Status")),
                              DataColumn(label: Text("File")),
                            ],
                            rows: grievances.map((grievance) {
                              return DataRow(cells: [
                                DataCell(Text(
                                    grievance['grievance_id'].toString())),
                                DataCell(Text(grievance['full_name'] ?? "")),
                                DataCell(Text(grievance['email_id'] ?? "")),
                                DataCell(Text(grievance['phone_number'] ?? "")),
                                DataCell(
                                    Text(grievance['grievance_subject'] ?? "")),
                                DataCell(
                                    Text(grievance['grievance_details'] ?? "")),
                                DataCell(Text(_getDepartmentName(
                                    grievance['grievance_category']))),
                                DataCell(Text(grievance['priority_level'] ?? "")),
                                DataCell(
                                  Text(
                                    grievance['grievance_status'] ?? "Resolved",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  grievance['upload_file'] != null
                                      ? ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  KDRTColors.darkBlue),
                                          onPressed: () async {
                                            final Uri fileUri = Uri.parse(
                                                grievance['upload_file']);
                                            if (await canLaunchUrl(fileUri)) {
                                              await launchUrl(fileUri,
                                                  mode: LaunchMode
                                                      .externalApplication);
                                            }
                                          },
                                          child: const Text(
                                            "View",
                                            style: TextStyle(
                                                color: KDRTColors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      : const Text("No File"),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
