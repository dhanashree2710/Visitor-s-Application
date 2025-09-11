import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class AdminGrievanceScreen extends StatefulWidget {
  const AdminGrievanceScreen({super.key});

  @override
  State<AdminGrievanceScreen> createState() => _AdminGrievanceScreenState();
}

class _AdminGrievanceScreenState extends State<AdminGrievanceScreen> {
  final supabase = Supabase.instance.client;

  List grievances = [];
  List departments = [];
  bool isLoading = true;

  // Filters
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
    _fetchGrievances();
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

  /// Fetch all grievances
  Future<void> _fetchGrievances() async {
    setState(() => isLoading = true);
    final response = await supabase.from("grievance").select();
    setState(() {
      grievances = response;
      isLoading = false;
    });
  }

  /// Update grievance status
  Future<void> _updateStatus(
      String grievanceId, String newStatus, Map grievanceData) async {
    try {
      await supabase
          .from("grievance")
          .update({"grievance_status": newStatus}).eq("grievance_id", grievanceId);

      _sendMessage(grievanceData, newStatus);
      _fetchGrievances();
    } catch (e) {
      print("❌ Error updating status: $e");
    }
  }

/// Send WhatsApp message to client
Future<void> _sendMessage(Map grievance, String status) async {
  String grievanceId = grievance['grievance_id']?.toString() ?? "";
  String shortId = grievanceId.length > 4
      ? grievanceId.substring(grievanceId.length - 4)
      : grievanceId;

  // Closing line changes based on status
  String closingMessage;
  if (status == "Resolved") {
    closingMessage = "✅ Your grievance has been resolved. Thank you for your patience.";
  } else if (status == "Invalid") {
    closingMessage = "❌ Your grievance has been marked as invalid. Please contact support for clarification.";
  } else {
    closingMessage = "Thank you for reaching out to us. We will review it shortly.";
  }

  String message = """
Dear ${grievance['full_name']},

Your grievance has been registered/updated successfully.

• Grievance ID: $shortId
• Status: $status
• Subject: ${grievance['grievance_subject']}
• Details: ${grievance['grievance_details']}
• Category: ${_getDepartmentName(grievance['grievance_category'])}

$closingMessage
""";

  String phone = grievance['phone_number'];
  if (!phone.startsWith("+")) {
    phone = "+91$phone"; // default India
  }

  final Uri whatsappUri =
      Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");

  if (await canLaunchUrl(whatsappUri)) {
    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    print("✅ WhatsApp message opened");
  } else {
    print("❌ Could not open WhatsApp");
  }
}



  /// Open filter dialog
  void _openFilterDialog() {
    String tempGrievanceId = searchGrievanceId;
    String tempName = searchName;
    String tempEmail = searchEmail;
    String tempPhone = searchPhone;
    String tempStatus = selectedStatus;
    String tempCategory = selectedCategory;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Apply Filters"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Grievance ID"),
                  onChanged: (val) => tempGrievanceId = val.toLowerCase(),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Name"),
                  onChanged: (val) => tempName = val.toLowerCase(),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Email"),
                  onChanged: (val) => tempEmail = val.toLowerCase(),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Phone"),
                  onChanged: (val) => tempPhone = val.toLowerCase(),
                ),
                DropdownButton<String>(
                  value: tempStatus,
                  isExpanded: true,
                  items: [
                    "All",
                    "Pending",
                    "In Progress",
                    "Resolved",
                    "Invalid"
                  ]
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) tempStatus = val;
                  },
                ),
                DropdownButton<String>(
                  value: tempCategory,
                  isExpanded: true,
                  items: [
                    "All",
                    ...departments.map((d) => d['dept_name'] as String)
                  ]
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) tempCategory = val;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                    color: KDRTColors.darkBlue, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  searchGrievanceId = tempGrievanceId;
                  searchName = tempName;
                  searchEmail = tempEmail;
                  searchPhone = tempPhone;
                  selectedStatus = tempStatus;
                  selectedCategory = tempCategory;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: KDRTColors.darkBlue,
              ),
              child: const Text(
                "Apply",
                style: TextStyle(
                    color: KDRTColors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text("Admin Grievance Dashboard", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: KDRTColors.darkBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔹 Filter & Refresh buttons row
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.filter_list, color: Colors.white),
                        label: const Text(
                          "Filter",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KDRTColors.darkBlue,
                        ),
                        onPressed: _openFilterDialog,
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text(
                          "Refresh",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
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
                          _fetchGrievances();
                        },
                      ),
                    ],
                  ),
                ),

                // 📋 Data Table with scrollable + zoom support
                Expanded(
                  child: InteractiveViewer(
                    constrained: false,
                    scaleEnabled: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            WidgetStateProperty.all(Colors.blue[900]),
                        headingTextStyle: const TextStyle(color: Colors.white),
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
                          DataColumn(label: Text("Actions")),
                        ],
                        rows: grievances.where((g) {
                          bool matchesId = g['grievance_id']
                              .toString()
                              .toLowerCase()
                              .contains(searchGrievanceId);
                          bool matchesName =
                              g['full_name'].toLowerCase().contains(searchName);
                          bool matchesEmail = g['email_id']
                              .toLowerCase()
                              .contains(searchEmail);
                          bool matchesPhone = g['phone_number']
                              .toLowerCase()
                              .contains(searchPhone);
                          bool matchesStatus = selectedStatus == "All" ||
                              g['grievance_status'] == selectedStatus;
                          bool matchesCategory = selectedCategory == "All" ||
                              _getDepartmentName(g['grievance_category']) ==
                                  selectedCategory;

                          return matchesId &&
                              matchesName &&
                              matchesEmail &&
                              matchesPhone &&
                              matchesStatus &&
                              matchesCategory;
                        }).map((grievance) {
                          return DataRow(cells: [
                            DataCell(Text(grievance['grievance_id'].toString())),
                            DataCell(Text(grievance['full_name'])),
                            DataCell(Text(grievance['email_id'])),
                            DataCell(Text(grievance['phone_number'])),
                            DataCell(Text(grievance['grievance_subject'])),
                            DataCell(Text(grievance['grievance_details'])),
                            DataCell(Text(_getDepartmentName(
                                grievance['grievance_category']))),
                            DataCell(Text(grievance['priority_level'])),
                           DataCell(
  Text(
    grievance['grievance_status'] ?? "Pending",
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: () {
        switch (grievance['grievance_status']) {
          case "Pending":
            return Colors.orange;   // 🟠 Pending
          case "In Progress":
            return Colors.blue;     // 🔵 In Progress
          case "Resolved":            return Colors.green;    // 🟢 Resolved
          case "Invalid":
            return Colors.red;      // 🔴 Invalid
          default:
            return Colors.black;    // Default fallback
        }
      }(),
    ),
  ),
),

                            DataCell(
                              grievance['upload_file'] != null
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: KDRTColors.darkBlue),
                                      onPressed: () async {
                                        final Uri fileUri =
                                            Uri.parse(grievance['upload_file']);
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
                            DataCell(
                              DropdownButton<String>(
                                value: grievance['grievance_status'] ?? "Pending",
                                items: [
                                  "Pending",
                                  "In Progress",
                                  "Resolved",
                                  "Invalid"
                                ]
                                    .map((s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    _updateStatus(
                                        grievance['grievance_id'], val, grievance);
                                  }
                                },
                              ),
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
