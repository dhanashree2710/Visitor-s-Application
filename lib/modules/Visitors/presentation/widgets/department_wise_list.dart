// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:visitors_and_grievance_application/modules/Visitors/presentation/widgets/day_wise_list.dart';
// import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

// class DepartmentWiseVisitorsList extends StatefulWidget {
//   final String? selectedDepartment;

//   const DepartmentWiseVisitorsList({Key? key, this.selectedDepartment})
//       : super(key: key);

//   @override
//   _DepartmentWiseVisitorsListState createState() =>
//       _DepartmentWiseVisitorsListState();
// }

// class _DepartmentWiseVisitorsListState
//     extends State<DepartmentWiseVisitorsList> {
//   final TextEditingController _searchController = TextEditingController();
//   bool isLoading = true;

//   List<Map<String, dynamic>> allVisitors = [];
//   List<Map<String, dynamic>> _filteredVisitors = [];

//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     fetchVisitors();
//   }

//   void _filterVisitors(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredVisitors = allVisitors;
//       } else {
//         _filteredVisitors = allVisitors.where((visitor) {
//           final name =
//               (visitor['visitor_name'] ?? '').toString().toLowerCase();
//           final phone = (visitor['visitor_phone'] ?? '').toString();
//           return name.contains(query.toLowerCase()) || phone.contains(query);
//         }).toList();
//       }
//     });
//   }

//   Future<void> fetchVisitors() async {
//     try {
//       setState(() => isLoading = true);

//       final response =
//           await Supabase.instance.client.from('visitor').select();

//       DateTime today = DateTime.now();
//       String todayDate =
//           "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

//       List<Map<String, dynamic>> visitors =
//           List<Map<String, dynamic>>.from(response);

//       // Apply date + department filter
//       visitors = visitors.where((visitor) {
//         final isToday = visitor['visit_date'] == todayDate;
//         final isDeptMatch = widget.selectedDepartment == null
//             ? true
//             : visitor['department'] == widget.selectedDepartment;
//         return isToday && isDeptMatch;
//       }).toList();

//       setState(() {
//         allVisitors = visitors;
//         _filteredVisitors = visitors;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//       debugPrint("❌ Error fetching visitors: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             "Today's Visitors",
//             style: TextStyle(color: Colors.white),
//           ),
//           backgroundColor: KDRTColors.darkBlue,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//         backgroundColor: Colors.white,
//         body: Column(
//           children: [
//             /// Search & Filter Bar
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                         border:
//                             Border.all(color: KDRTColors.darkBlue, width: 2),
//                       ),
//                       child: TextField(
//                         controller: _searchController,
//                         onChanged: _filterVisitors,
//                         decoration: const InputDecoration(
//                           hintText: "Search visitors...",
//                           border: InputBorder.none,
//                           prefixIcon: Icon(Icons.search,
//                               color: KDRTColors.darkBlue),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   GestureDetector(
//                     onTap: () {
//                       // TODO: Add custom filter dialog if needed
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         gradient: const LinearGradient(
//                           colors: [KDRTColors.darkBlue, KDRTColors.cyan],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                       ),
//                       child: const Icon(Icons.filter_list, color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             /// Visitors List/Grid
//             Expanded(
//               child: RefreshIndicator(
//                 onRefresh: fetchVisitors,
//                 child: isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : _filteredVisitors.isEmpty
//                         ? const Center(
//                             child: Text("No visitors found!",
//                                 style: TextStyle(color: Colors.grey)),
//                           )
//                         : LayoutBuilder(
//                             builder: (context, constraints) {
//                               bool isWideScreen = constraints.maxWidth > 800;

//                               if (isWideScreen) {
//                                 // Desktop / Large screen → Grid view
//                                 return GridView.builder(
//                                   controller: _scrollController,
//                                   padding: const EdgeInsets.all(16),
//                                   gridDelegate:
//                                       SliverGridDelegateWithFixedCrossAxisCount(
//                                     crossAxisCount: constraints.maxWidth > 1200
//                                         ? 4
//                                         : 3, // 4 columns for very wide
//                                     mainAxisSpacing: 12,
//                                     crossAxisSpacing: 12,
//                                     childAspectRatio: 1.4,
//                                   ),
//                                   itemCount: _filteredVisitors.length,
//                                   itemBuilder: (context, index) {
//                                     final visitor = _filteredVisitors[index];
//                                     return DayWiseVisitorsStatusUpdate(
//                                         visitor: visitor);
//                                   },
//                                 );
//                               } else {
//                                 // Mobile → Scrollable list of cards
//                                 return ListView.builder(
//                                   controller: _scrollController,
//                                   padding: const EdgeInsets.all(16),
//                                   itemCount: _filteredVisitors.length,
//                                   itemBuilder: (context, index) {
//                                     final visitor = _filteredVisitors[index];
//                                     return Padding(
//                                       padding:
//                                           const EdgeInsets.only(bottom: 12),
//                                       child: DayWiseVisitorsStatusUpdate(
//                                           visitor: visitor),
//                                     );
//                                   },
//                                 );
//                               }
//                             },
//                           ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/modules/Visitors/presentation/widgets/day_wise_list.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class DepartmentWiseVisitorsList extends StatefulWidget {
  String? selectedDepartment;

  DepartmentWiseVisitorsList({super.key, this.selectedDepartment});

  @override
  _DepartmentWiseVisitorsListState createState() =>
      _DepartmentWiseVisitorsListState();
}

class _DepartmentWiseVisitorsListState
    extends State<DepartmentWiseVisitorsList> {
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = true;

  List<Map<String, dynamic>> _allVisitors = [];
  List<Map<String, dynamic>> _filteredVisitors = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchVisitors();
  }

  Future<void> fetchVisitors({bool resetFilter = false}) async {
    try {
      setState(() => isLoading = true);

      if (resetFilter) widget.selectedDepartment = null;

      final response = await Supabase.instance.client.from('visitor').select();
      List<Map<String, dynamic>> visitors = List<Map<String, dynamic>>.from(response);

      DateTime today = DateTime.now();
      String todayDate =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      visitors = visitors.where((visitor) {
        final isToday = visitor['visit_date'] == todayDate;
        final isDeptMatch = widget.selectedDepartment == null
            ? true
            : visitor['department'] == widget.selectedDepartment;
        return isToday && isDeptMatch;
      }).toList();

      setState(() {
        _allVisitors = visitors;
        _filteredVisitors = visitors;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ Error fetching visitors: $e");
    }
  }

  /// Search filter by name or phone
  void _filterVisitors(String query) {
    final lowerQuery = query.trim().toLowerCase();

    setState(() {
      if (lowerQuery.isEmpty) {
        _filteredVisitors = List.from(_allVisitors);
      } else {
        _filteredVisitors = _allVisitors.where((visitor) {
          final name = (visitor['visitor_name'] ?? '').toString().toLowerCase();
          final phone = (visitor['visitor_phone'] ?? '').toString();
          return name.contains(lowerQuery) || phone.contains(lowerQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
          title: const Text(
            "Today's Visitors",
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
          // ---------------- Search Bar ----------------
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterVisitors,
              decoration: InputDecoration(
                hintText: "Search by name or phone",
                prefixIcon: const Icon(Icons.search, color: KDRTColors.darkBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: KDRTColors.darkBlue, width: 3),
                ),
              ),
            ),
          ),

          // ---------------- Visitor List/Grid ----------------
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => fetchVisitors(resetFilter: true),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredVisitors.isEmpty
                      ? const Center(child: Text("No visitors found!"))
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            bool isWideScreen = constraints.maxWidth > 800;
                            if (isWideScreen) {
                              return GridView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      constraints.maxWidth > 1200 ? 4 : 3,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 4 / 3,
                                ),
                                itemCount: _filteredVisitors.length,
                                itemBuilder: (context, index) {
                                  return DayWiseVisitorsStatusUpdate(
                                      visitor: _filteredVisitors[index]);
                                },
                              );
                            } else {
                              return ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredVisitors.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: DayWiseVisitorsStatusUpdate(
                                        visitor: _filteredVisitors[index]),
                                  );
                                },
                              );
                            }
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
