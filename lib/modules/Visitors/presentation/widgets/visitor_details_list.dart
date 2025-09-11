// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

// class VisitorDetailsScreen extends StatefulWidget {
//   final String email;

//   const VisitorDetailsScreen({Key? key, required this.email}) : super(key: key);

//   @override
//   _VisitorDetailsScreenState createState() => _VisitorDetailsScreenState();
// }

// class _VisitorDetailsScreenState extends State<VisitorDetailsScreen> {
//   List<Map<String, dynamic>> visitors = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchVisitorData();
//   }

//   Future<void> _fetchVisitorData() async {
//     try {
//       final response = await Supabase.instance.client
//           .from('visitor')
//           .select()
//           .eq('visitor_email', widget.email); // ✅ Match table schema

//       setState(() {
//         visitors = List<Map<String, dynamic>>.from(response);
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//       debugPrint("Failed to fetch visitor data: $e");
//     }
//   }

//   String _formatDate(dynamic date) {
//     if (date == null) return '-';
//     try {
//       return DateFormat('dd MMM yyyy').format(DateTime.parse(date.toString()));
//     } catch (_) {
//       return date.toString();
//     }
//   }

//   String _formatTime(dynamic timestamp) {
//     if (timestamp == null) return '-';
//     try {
//       return DateFormat('hh:mm a').format(DateTime.parse(timestamp.toString()));
//     } catch (_) {
//       return timestamp.toString();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Center(
//           child: Container(
//             margin: EdgeInsets.only(right: 50),
//             child: const Text(
//               "Visitor Details",
//               style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ),
//         backgroundColor: KDRTColors.darkBlue,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: _fetchVisitorData,
//               child: visitors.isEmpty
//                   ? const SingleChildScrollView(
//                       physics: AlwaysScrollableScrollPhysics(),
//                       child: Center(
//                         heightFactor: 10,
//                         child: Text("No visit records found"),
//                       ),
//                     )
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(16),
//                       itemCount: visitors.length,
//                       itemBuilder: (context, index) {
//                         return _buildVisitorCard(visitors[index]);
//                       },
//                     ),
//             ),
//     );
//   }

//   /// Build Visitor Card
//   Widget _buildVisitorCard(Map<String, dynamic> visitor) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 5,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             /// Visitor Profile Image
//             CircleAvatar(
//               radius: 50,
//               backgroundImage: (visitor['profile_img'] != null &&
//                       visitor['profile_img'].toString().isNotEmpty)
//                   ? NetworkImage(visitor['profile_img'])
//                   : const AssetImage('assets/images/default_avatar.png')
//                       as ImageProvider,
//             ),
//             const SizedBox(height: 16),

//             /// Visitor Details
//             _buildDetailRow(Icons.person, "Name", visitor['visitor_name']),
//             _buildDetailRow(Icons.email, "Email ID", visitor['visitor_email']),
//             _buildDetailRow(Icons.calendar_today, "Date", _formatDate(visitor['visit_date'])),
//             _buildDetailRow(Icons.access_time, "In-Time", _formatTime(visitor['in_time'])),
//             _buildDetailRow(Icons.exit_to_app, "Out-Time", _formatTime(visitor['out_time'])),
//             _buildDetailRow(Icons.description, "Purpose", visitor['purpose']),
//             _buildDetailRow(Icons.apartment, "Department", visitor['department']),
//             _buildDetailRow(Icons.phone, "Phone", visitor['visitor_phone']),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Row with Icon + Label + Value
//   Widget _buildDetailRow(IconData icon, String label, dynamic value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Icon(icon, size: 22, color: KDRTColors.darkBlue),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               "$label: ${value ?? '-'}",
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

/// ---------------- VISITOR DETAILS SCREEN ----------------
class VisitorDetailsScreen extends StatefulWidget {
  final String email;

  const VisitorDetailsScreen({super.key, required this.email});

  @override
  _VisitorDetailsScreenState createState() => _VisitorDetailsScreenState();
}

class _VisitorDetailsScreenState extends State<VisitorDetailsScreen> {
  List<Map<String, dynamic>> visitors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVisitorData();
  }

  Future<void> _fetchVisitorData() async {
    try {
      final response = await Supabase.instance.client
          .from('visitor')
          .select()
          .eq('visitor_email', widget.email);

      setState(() {
        visitors = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Failed to fetch visitor data: $e");
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date.toString()));
    } catch (_) {
      return date.toString();
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '-';
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(timestamp.toString()));
    } catch (_) {
      return timestamp.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
          title: const Text(
            "Visitors Details",
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
       
      
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchVisitorData,
              child: visitors.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 100),
                        Center(
                          child: Text(
                            "No visit records found",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        double maxWidth = constraints.maxWidth > 800
                            ? 800
                            : constraints.maxWidth > 600
                                ? 600
                                : double.infinity;

                        return Center(
                          child: SizedBox(
                            width: maxWidth,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: visitors.length,
                              itemBuilder: (context, index) {
                                return _buildVisitorCard(visitors[index]);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildVisitorCard(Map<String, dynamic> visitor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: (visitor['profile_img'] != null &&
                        visitor['profile_img'].toString().isNotEmpty)
                    ? NetworkImage(visitor['profile_img'])
                    : const AssetImage('assets/images/default_avatar.png')
                        as ImageProvider,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.person, "Name", visitor['visitor_name']),
              _buildDetailRow(Icons.email, "Email", visitor['visitor_email']),
              _buildDetailRow(Icons.calendar_today, "Date",
                  _formatDate(visitor['visit_date'])),
              _buildDetailRow(Icons.access_time, "In-Time",
                  _formatTime(visitor['in_time'])),
              _buildDetailRow(Icons.exit_to_app, "Out-Time",
                  _formatTime(visitor['out_time'])),
              _buildDetailRow(Icons.description, "Purpose", visitor['purpose']),
              _buildDetailRow(Icons.apartment, "Department",
                  visitor['department']),
              _buildDetailRow(Icons.phone, "Phone", visitor['visitor_phone']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: KDRTColors.darkBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$label: ${value ?? '-'}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- DAY-WISE VISITORS STATUS UPDATE ----------------
class DayWiseVisitorsStatusUpdate extends StatefulWidget {
  final List<Map<String, dynamic>> visitors;
  final VoidCallback? onOutTimeUpdated;

  const DayWiseVisitorsStatusUpdate({
    super.key,
    required this.visitors,
    this.onOutTimeUpdated,
  });

  @override
  State<DayWiseVisitorsStatusUpdate> createState() =>
      _DayWiseVisitorsStatusUpdateState();
}

class _DayWiseVisitorsStatusUpdateState
    extends State<DayWiseVisitorsStatusUpdate> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1100) {
          return _buildDesktopGrid();
        } else if (constraints.maxWidth > 600) {
          return _buildTabletList();
        } else {
          return _buildMobileList();
        }
      },
    );
  }

  /// Desktop → Grid View
  Widget _buildDesktopGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: widget.visitors.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          return _buildVisitorCard(widget.visitors[index]);
        },
      ),
    );
  }

  /// Tablet → Single column centered
  Widget _buildTabletList() {
    return Center(
      child: SizedBox(
        width: 600,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: widget.visitors.length,
          itemBuilder: (context, index) {
            return _buildVisitorCard(widget.visitors[index]);
          },
        ),
      ),
    );
  }

  /// Mobile → Full width single column
  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.visitors.length,
      itemBuilder: (context, index) {
        return _buildVisitorCard(widget.visitors[index]);
      },
    );
  }

  /// Visitor Card
  Widget _buildVisitorCard(Map<String, dynamic> visitor) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileRow(visitor),
            Divider(color: Colors.grey.shade300, thickness: 1, height: 20),
            _buildDetailsSection(visitor),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(Map<String, dynamic> visitor) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
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
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        const Icon(Icons.arrow_forward_ios, color: KDRTColors.darkBlue, size: 18),
      ],
    );
  }

  Widget _buildDetailsSection(Map<String, dynamic> visitor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow("Email", visitor['visitor_email']),
        _buildDetailRow("Phone", visitor['visitor_phone']),
        _buildDetailRow("Department", visitor['department']),
        _buildDetailRow("Purpose", visitor['purpose']),
        _buildDetailRow("Date", visitor['visit_date']),
        _buildDetailRow("In Time", visitor['in_time']),
        _buildDetailRow("Out Time", visitor['out_time']),
      ],
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        "$label: ${value ?? '-'}",
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }
}
