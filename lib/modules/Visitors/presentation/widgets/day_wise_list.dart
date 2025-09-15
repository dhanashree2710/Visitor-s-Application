// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:visitors_and_grievance_application/modules/Visitors/presentation/widgets/visitor_details_list.dart';
// import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

// class DayWiseVisitorsStatusUpdate extends StatefulWidget {
//   final Map<String, dynamic> visitor;

//   const DayWiseVisitorsStatusUpdate({Key? key, required this.visitor})
//       : super(key: key);

//   @override
//   State<DayWiseVisitorsStatusUpdate> createState() =>
//       _DayWiseVisitorsStatusUpdateState();
// }

// class _DayWiseVisitorsStatusUpdateState
//     extends State<DayWiseVisitorsStatusUpdate> {
//   late Map<String, dynamic> visitor;

//   @override
//   void initState() {
//     super.initState();
//     visitor = widget.visitor;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       onRefresh: _refreshVisitorData,
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         child: GestureDetector(
//           onTap: () {
//             if (visitor['visitor_email'] != null) {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       VisitorDetailsScreen(email: visitor['visitor_email']),
//                 ),
//               );
//             }
//           },
//           child: Container(
//             margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: KDRTColors.darkBlue.withOpacity(0.4),
//                   blurRadius: 8,
//                   spreadRadius: 2,
//                   offset: const Offset(2, 3),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildProfileRow(),
//                 Divider(color: Colors.grey.shade300, thickness: 1, height: 20),
//                 _buildDetailsSection(),
//                 const SizedBox(height: 10),
//                 _buildUpdateButton(context),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   /// Profile row
//   Widget _buildProfileRow() {
//     return Row(
//       children: [
//         CircleAvatar(
//           radius: 30,
//           backgroundColor: Colors.grey[300],
//           backgroundImage: visitor['profile_img'] != null
//               ? NetworkImage(visitor['profile_img'])
//               : null,
//           child: visitor['profile_img'] == null
//               ? const Icon(Icons.person, size: 30, color: Colors.white)
//               : null,
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(
//             visitor['visitor_name'] ?? 'Unknown',
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//         ),
//         const Icon(Icons.arrow_forward_ios,
//             color: KDRTColors.darkBlue, size: 18),
//       ],
//     );
//   }

//   /// Details section
//   Widget _buildDetailsSection() {
//     return Column(
//       children: [
//         _buildDetailRow(Icons.email, "Email", visitor['visitor_email'] ?? '-'),
//         _buildDetailRow(Icons.phone, "Phone", visitor['visitor_phone'] ?? '-'),
//         _buildDetailRow(Icons.apartment, "Department", visitor['department'] ?? '-'),
//         _buildDetailRow(Icons.description, "Purpose", visitor['purpose'] ?? '-'),
//         _buildDetailRow(Icons.calendar_today, "Date",
//             visitor['visit_date']?.toString() ?? '-'),
//         _buildDetailRow(Icons.timer, "In Time",
//             _formatTime(visitor['in_time']) ?? '-'),
//         _buildDetailRow(Icons.exit_to_app, "Out Time",
//             _formatTime(visitor['out_time']) ?? '-'),
//       ],
//     );
//   }

//   Widget _buildDetailRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Icon(icon, color: KDRTColors.darkBlue, size: 20),
//           const SizedBox(width: 8),
//           Text("$label: ",
//               style:
//                   const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
//           Expanded(child: Text(value, style: const TextStyle(color: Colors.black54))),
//         ],
//       ),
//     );
//   }

//   /// Update Button
//   Widget _buildUpdateButton(BuildContext context) {
//     return Center(
//       child: ElevatedButton.icon(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: KDRTColors.darkBlue,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
//         ),
//         icon: const Icon(Icons.exit_to_app, size: 20),
//         label: const Text("Update Out-Time", style: TextStyle(fontSize: 14)),
//         onPressed: () => _updateOutTime(context),
//       ),
//     );
//   }

//   /// Update Out-Time in Supabase and update UI
//   Future<void> _updateOutTime(BuildContext context) async {
//     String currentTime = DateFormat('hh:mm a').format(DateTime.now());

//     try {
//       final response = await Supabase.instance.client
//           .from('visitor')
//           .update({'out_time': DateTime.now().toIso8601String()})
//           .eq('visitor_email', visitor['visitor_email'])
//           .select()
//           .single();

//       setState(() {
//         visitor['out_time'] = response['out_time'];
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Out-Time updated: $currentTime")),
//       );
//     } catch (e) {
//       debugPrint("Failed to update Out-Time: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to update Out-Time")),
//       );
//     }
//   }

//   /// Refresh visitor data from Supabase
//   Future<void> _refreshVisitorData() async {
//     try {
//       final response = await Supabase.instance.client
//           .from('visitor')
//           .select()
//           .eq('visitor_email', visitor['visitor_email'])
//           .single();

//       setState(() {
//         visitor = response;
//       });
//     } catch (e) {
//       debugPrint("Failed to refresh data: $e");
//     }
//   }

//   /// Format time safely
//   String? _formatTime(dynamic timestamp) {
//     if (timestamp == null) return null;
//     try {
//       DateTime date = DateTime.parse(timestamp.toString());
//       return DateFormat('hh:mm a').format(date);
//     } catch (_) {
//       return timestamp.toString();
//     }
//   }
// }



import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/modules/Visitors/presentation/widgets/visitor_details_list.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class DayWiseVisitorsStatusUpdate extends StatefulWidget {
  final Map<String, dynamic> visitor;
  final VoidCallback? onOutTimeUpdated;

  const DayWiseVisitorsStatusUpdate({
    super.key,
    required this.visitor,
    this.onOutTimeUpdated,
  });

  @override
  State<DayWiseVisitorsStatusUpdate> createState() =>
      _DayWiseVisitorsStatusUpdateState();
}

class _DayWiseVisitorsStatusUpdateState
    extends State<DayWiseVisitorsStatusUpdate> {
  late Map<String, dynamic> visitor;
    bool isLoading = true;
  List<Map<String, dynamic>> _allVisitors = [];
  List<Map<String, dynamic>> _departments = []; // fetched departments
  final ScrollController _scrollController = ScrollController();

  String? _selectedDept; // filter dept
  String _searchName = ""; // filter visitor name

  @override
  void initState() {
    super.initState();
    visitor = widget.visitor;
    
   
    fetchDepartments();
    fetchVisitors();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1100) {
          return _buildDesktopView();
        } else if (constraints.maxWidth > 600) {
          return _buildTabletView();
        } else {
          return _buildMobileView();
        }
      },
    );
  }

  Widget _buildMobileView() => _buildCard(padding: 12, fontSize: 14);
  Widget _buildTabletView() => Center(
        child: SizedBox(width: 600, child: _buildCard(padding: 18, fontSize: 16)),
      );
  Widget _buildDesktopView() => Center(
        child: SizedBox(width: 800, child: _buildCard(padding: 22, fontSize: 18)),
      );

  Widget _buildCard({required double padding, required double fontSize}) {
    return GestureDetector(
      onTap: () {
        if (visitor['visitor_email'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VisitorDetailsScreen(email: visitor['visitor_email']),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: KDRTColors.darkBlue.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileRow(fontSize),
              Divider(color: Colors.grey.shade300, thickness: 1, height: 20),
              _buildDetailsSection(fontSize),
              const SizedBox(height: 10),
              _buildUpdateButton(fontSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(double fontSize) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[300],
          backgroundImage: visitor['profile_img'] != null
              ? NetworkImage(visitor['profile_img'])
              : null,
          child: visitor['profile_img'] == null
              ? const Icon(Icons.person, size: 30, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            visitor['visitor_name'] ?? 'Unknown',
            style: TextStyle(
              fontSize: fontSize + 2,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const Icon(Icons.arrow_forward_ios,
            color: KDRTColors.darkBlue, size: 18),
      ],
    );
  }

  Widget _buildDetailsSection(double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(Icons.email, "Email", visitor['visitor_email'] ?? '-', fontSize),
        _buildDetailRow(Icons.phone, "Phone", visitor['visitor_phone'] ?? '-', fontSize),
        _buildDetailRow(Icons.apartment, "Department", visitor['department'] ?? '-', fontSize),
        _buildDetailRow(Icons.description, "Purpose", visitor['purpose'] ?? '-', fontSize),
        _buildDetailRow(Icons.calendar_today, "Date",
            visitor['visit_date']?.toString() ?? '-', fontSize),
        _buildDetailRow(Icons.timer, "In Time",
            _formatTime(visitor['in_time']) ?? '-', fontSize),
        _buildDetailRow(Icons.exit_to_app, "Out Time",
            _formatTime(visitor['out_time']) ?? '-', fontSize),
      ],
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: KDRTColors.darkBlue, size: fontSize + 4),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: fontSize),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black54, fontSize: fontSize),
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton(double fontSize) {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: KDRTColors.darkBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: fontSize + 5),
        ),
        icon: const Icon(Icons.exit_to_app, size: 20),
        label: Text("Update Out-Time", style: TextStyle(fontSize: fontSize)),
        onPressed: () => _updateOutTime(context),
      ),
    );
  }

  Future<void> _updateOutTime(BuildContext context) async {
    String currentTime = DateFormat('hh:mm a').format(DateTime.now());

    try {
      // 1️⃣ Fetch latest visitor record by email
      final latestVisitor = await Supabase.instance.client
          .from('visitor')
          .select('visitor_id')
          .eq('visitor_email', visitor['visitor_email'])
          .order('visit_date', ascending: false)
          .order('in_time', ascending: false)
          .limit(1)
          .single();

      // 2️⃣ Update only that row
      final response = await Supabase.instance.client
          .from('visitor')
          .update({'out_time': DateTime.now().toIso8601String()})
          .eq('visitor_id', latestVisitor['visitor_id'])
          .select()
          .single();

      setState(() {
        visitor['out_time'] = response['out_time'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Out-Time updated: $currentTime")),
      );

      if (widget.onOutTimeUpdated != null) {
        widget.onOutTimeUpdated!();
      }
    } catch (e) {
      debugPrint("Failed to update Out-Time: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update Out-Time")),
      );
    }
  }

  String? _formatTime(dynamic timestamp) {
    if (timestamp == null) return null;
    try {
      DateTime date = DateTime.parse(timestamp.toString());
      return DateFormat('hh:mm a').format(date);
    } catch (_) {
      return timestamp.toString();
    }
  }


  /// ✅ Fetch visitors with optional filters
  Future<void> fetchVisitors() async {
    try {
      setState(() => isLoading = true);

      var query = Supabase.instance.client.from('visitor').select();

      if (_searchName.isNotEmpty) {
        query = query.ilike('visitor_name', '%$_searchName%'); // case-insensitive
      }

      if (_selectedDept != null && _selectedDept!.isNotEmpty) {
        query = query.eq('department', _selectedDept!);
      }

      final response = await query.order('visit_date', ascending: false);
      final visitors = List<Map<String, dynamic>>.from(response as List);

      setState(() {
        _allVisitors = visitors;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ Error fetching visitors: $e");
    }
  }

  /// ✅ Fetch departments for dropdown
  Future<void> fetchDepartments() async {
    try {
      final response =
          await Supabase.instance.client.from('department').select();

      setState(() {
        _departments = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("❌ Error fetching departments: $e");
    }
  }

  /// ✅ Filter dialog with Dept + Name
  void _openFilterDialog() {
    String? tempDept = _selectedDept;
    String tempName = _searchName;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Filter Visitors"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Visitor Name input
                TextField(
                  controller: TextEditingController(text: tempName),
                  decoration: const InputDecoration(
                    labelText: "Visitor Name",
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (val) {
                    tempName = val;
                  },
                ),
                const SizedBox(height: 16),

                /// Department dropdown
                DropdownButtonFormField<String>(
                  value: tempDept,
                  items: _departments
                      .map((dept) => DropdownMenuItem<String>(
                            value: dept['dept_name'] as String,
                            child: Text(dept['dept_name'] as String),
                          ))
                      .toList(),
                  onChanged: (value) {
                    tempDept = value;
                  },
                  decoration: const InputDecoration(labelText: "Department"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedDept = tempDept;
                  _searchName = tempName;
                });
                Navigator.pop(ctx);
                fetchVisitors();
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
  }


}
