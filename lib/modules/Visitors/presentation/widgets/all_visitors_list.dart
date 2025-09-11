// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:visitors_and_grievance_application/modules/Visitors/presentation/widgets/day_wise_list.dart';
// import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

// class AllVisitorsList extends StatefulWidget {
//   const AllVisitorsList({Key? key}) : super(key: key);

//   @override
//   _AllVisitorsListState createState() => _AllVisitorsListState();
// }

// class _AllVisitorsListState extends State<AllVisitorsList> {
//   final TextEditingController _searchController = TextEditingController();

//   bool isLoading = true;

//   List<Map<String, dynamic>> _allVisitors = [];
//   List<Map<String, dynamic>> _filteredVisitors = [];

//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     fetchVisitors();
//   }

//   /// ✅ Fetch ALL visitors (No date or department filter)
//   Future<void> fetchVisitors() async {
//     try {
//       setState(() => isLoading = true);

//       final response = await Supabase.instance.client.from('visitor').select();
//       List<Map<String, dynamic>> visitors =
//           List<Map<String, dynamic>>.from(response);

//       setState(() {
//         _allVisitors = visitors;
//         _filteredVisitors = visitors;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//       debugPrint("❌ Error fetching visitors: $e");
//     }
//   }

//   // /// ✅ Search filter by name or phone
//   // void _filterVisitors(String query) {
//   //   final lowerQuery = query.trim().toLowerCase();

//   //   setState(() {
//   //     if (lowerQuery.isEmpty) {
//   //       _filteredVisitors = List.from(_allVisitors);
//   //     } else {
//   //       _filteredVisitors = _allVisitors.where((visitor) {
//   //         final name = (visitor['visitor_name'] ?? '').toString().toLowerCase();
//   //         final phone = (visitor['visitor_phone'] ?? '').toString();
//   //         return name.contains(lowerQuery) || phone.contains(lowerQuery);
//   //       }).toList();
//   //     }
//   //   });
//   // }

// // Normalizes strings: lowercase, remove punctuation, collapse spaces.
// String _normalize(String s) => s
//     .toLowerCase()
//     .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ') // strip punctuation/symbols
//     .replaceAll(RegExp(r'\s+'), ' ')         // collapse multiple spaces
//     .trim();

// void _filterVisitors(String query) {
//   final q = _normalize(query);

//   setState(() {
//     if (q.isEmpty) {
//       _filteredVisitors = List.from(_allVisitors);
//       return;
//     }

//     // Split query into tokens for multi-word prefix matching (e.g., "rah ku")
//     final qTokens = q.split(' ');

//     _filteredVisitors = _allVisitors.where((visitor) {
//       final rawName = (visitor['visitor_name'] ?? '').toString();
//       final name = _normalize(rawName);

//       if (name.isEmpty) return false;

//       // Token-wise prefix matching ("rah" matches "rahul", "ku" matches "kumar")
//       final nameTokens = name.split(' ');
//       final tokenPrefixMatch = qTokens.every(
//         (t) => nameTokens.any((nTok) => nTok.startsWith(t)),
//       );

//       // Fallback: whole-name substring match (covers "ahu" in "rahul")
//       final looseSubstringMatch = name.contains(q);

//       return tokenPrefixMatch || looseSubstringMatch;
//     }).toList();

//     // Optional: rank results so better matches bubble to the top
//     int rank(Map v) {
//       final n = _normalize((v['visitor_name'] ?? '').toString());
//       if (n == q) return 3;            // exact
//       if (n.startsWith(q)) return 2;   // name starts with query
//       if (n.contains(q)) return 1;     // substring
//       return 0;
//     }
//     _filteredVisitors.sort((a, b) => rank(b).compareTo(rank(a)));
//   });
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "All Visitors",
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: KDRTColors.darkBlue,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           // ---------------- Search Bar ----------------
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: TextField(
//               controller: _searchController,
//               onChanged: _filterVisitors,
//               decoration: InputDecoration(
//                 hintText: "Search by name or phone",
//                 prefixIcon: const Icon(Icons.search, color: KDRTColors.darkBlue),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide:
//                       const BorderSide(color: KDRTColors.darkBlue, width: 3),
//                 ),
//               ),
//             ),
//           ),

//           // ---------------- Visitor List/Grid ----------------
//           Expanded(
//             child: RefreshIndicator(
//               onRefresh: fetchVisitors,
//               child: isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : _filteredVisitors.isEmpty
//                       ? const Center(child: Text("No visitors found!"))
//                       : LayoutBuilder(
//                           builder: (context, constraints) {
//                             bool isWideScreen = constraints.maxWidth > 800;
//                             if (isWideScreen) {
//                               return GridView.builder(
//                                 controller: _scrollController,
//                                 padding: const EdgeInsets.all(16),
//                                 gridDelegate:
//                                     SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount:
//                                       constraints.maxWidth > 1200 ? 4 : 3,
//                                   mainAxisSpacing: 12,
//                                   crossAxisSpacing: 12,
//                                   childAspectRatio: 4 / 3,
//                                 ),
//                                 itemCount: _filteredVisitors.length,
//                                 itemBuilder: (context, index) {
//                                   return DayWiseVisitorsStatusUpdate(
//                                       visitor: _filteredVisitors[index]);
//                                 },
//                               );
//                             } else {
//                               return ListView.builder(
//                                 controller: _scrollController,
//                                 padding: const EdgeInsets.all(16),
//                                 itemCount: _filteredVisitors.length,
//                                 itemBuilder: (context, index) {
//                                   return Padding(
//                                     padding: const EdgeInsets.only(bottom: 12),
//                                     child: DayWiseVisitorsStatusUpdate(
//                                         visitor: _filteredVisitors[index]),
//                                   );
//                                 },
//                               );
//                             }
//                           },
//                         ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:visitors_and_grievance_application/modules/Visitors/presentation/widgets/day_wise_list.dart';
// import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

// class AllVisitorsList extends StatefulWidget {
//   const AllVisitorsList({Key? key}) : super(key: key);

//   @override
//   _AllVisitorsListState createState() => _AllVisitorsListState();
// }

// class _AllVisitorsListState extends State<AllVisitorsList> {
//   bool isLoading = true;

//   List<Map<String, dynamic>> _allVisitors = [];
//   List<Map<String, dynamic>> _filteredVisitors = [];

//   final ScrollController _scrollController = ScrollController();

//   String selectedFilter = '';
//   String filterValue = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchVisitors();
//   }

//   /// ✅ Fetch ALL visitors (no date restriction)
//   Future<void> fetchVisitors() async {
//     try {
//       setState(() => isLoading = true);

//       final response = await Supabase.instance.client
//           .from('visitor')
//           .select()
//           .order('visit_date', ascending: false);

//       List<Map<String, dynamic>> visitors =
//           List<Map<String, dynamic>>.from(response);

//       setState(() {
//         _allVisitors = visitors;
//         _filteredVisitors = visitors;
//         isLoading = false;
//       });

//       debugPrint("✅ Total visitors fetched: ${_allVisitors.length}");
//     } catch (e) {
//       setState(() => isLoading = false);
//       debugPrint("❌ Error fetching visitors: $e");
//     }
//   }

//   /// Normalize strings for search
//   String _normalize(String s) => s
//       .toLowerCase()
//       .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
//       .replaceAll(RegExp(r'\s+'), ' ')
//       .trim();

//   /// ✅ Apply filter
//   void _applyFilter(String type, String value) {
//     final query = _normalize(value);
//     selectedFilter = type;
//     filterValue = value;

//     setState(() {
//       if (query.isEmpty) {
//         _filteredVisitors = List.from(_allVisitors);
//         debugPrint("🔍 No filter applied, showing all visitors.");
//         return;
//       }

//       _filteredVisitors = _allVisitors.where((visitor) {
//         final rawName = (visitor['visitor_name'] ?? '').toString();
//         final rawPhone = (visitor['visitor_phone'] ?? '').toString();
//         final name = _normalize(rawName);
//         final phone = rawPhone;

//         if (type == 'Name') {
//           return name.contains(query);
//         } else if (type == 'Phone') {
//           return phone.contains(query);
//         }
//         return false;
//       }).toList();

//       // Sort ranking for better matching
//       int rank(Map v) {
//         final n = _normalize((v['visitor_name'] ?? '').toString());
//         if (n == query) return 3;
//         if (n.startsWith(query)) return 2;
//         if (n.contains(query)) return 1;
//         return 0;
//       }
//       _filteredVisitors.sort((a, b) => rank(b).compareTo(rank(a)));

//       // ✅ Print filter logs in console
//       debugPrint("🔍 Filter Applied:");
//       debugPrint("   $type filter: '$value'");
//       debugPrint("✅ Filtered Visitors Count: ${_filteredVisitors.length}");
//       debugPrint("✅ Visitors being shown:");
//       for (var v in _filteredVisitors) {
//         debugPrint("   - ${v['visitor_name']} (${v['visitor_phone']})");
//       }
//     });
//   }

//   /// ✅ Reset Filter
//   void _resetFilter() {
//     setState(() {
//       selectedFilter = '';
//       filterValue = '';
//       _filteredVisitors = List.from(_allVisitors);
//     });
//     debugPrint("🔄 Filters reset. Showing all visitors.");
//   }

//   /// ✅ Show Filter Dialog
//   void _showFilterDialog() {
//     String selectedOption = 'Name';
//     String inputValue = '';

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Filter Visitors"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               DropdownButton<String>(
//                 value: selectedOption,
//                 items: ['Name', 'Phone'].map((String option) {
//                   return DropdownMenuItem(value: option, child: Text(option));
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedOption = value!;
//                   });
//                 },
//               ),
//               TextField(
//                 decoration: const InputDecoration(hintText: "Enter value"),
//                 onChanged: (val) {
//                   inputValue = val;
//                 },
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _applyFilter(selectedOption, inputValue);
//               },
//               child: const Text("Apply"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "All Visitors",
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: KDRTColors.darkBlue,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           // ✅ Filter & Reset buttons
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: _showFilterDialog,
//                   icon: const Icon(Icons.filter_list),
//                   label: const Text("Filter"),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: _resetFilter,
//                   icon: const Icon(Icons.refresh),
//                   label: const Text("Reset"),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 ),
//               ],
//             ),
//           ),

//           if (selectedFilter.isNotEmpty && filterValue.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 "Applied Filters: $selectedFilter = $filterValue",
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),

//           Expanded(
//             child: RefreshIndicator(
//               onRefresh: fetchVisitors,
//               child: isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : _filteredVisitors.isEmpty
//                       ? const Center(child: Text("No visitors found!"))
//                       : LayoutBuilder(
//                           builder: (context, constraints) {
//                             bool isWideScreen = constraints.maxWidth > 800;
//                             if (isWideScreen) {
//                               return GridView.builder(
//                                 controller: _scrollController,
//                                 padding: const EdgeInsets.all(16),
//                                 gridDelegate:
//                                     SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount:
//                                       constraints.maxWidth > 1200 ? 4 : 3,
//                                   mainAxisSpacing: 12,
//                                   crossAxisSpacing: 12,
//                                   childAspectRatio: 4 / 3,
//                                 ),
//                                 itemCount: _filteredVisitors.length,
//                                 itemBuilder: (context, index) {
//                                   return DayWiseVisitorsStatusUpdate(
//                                       visitor: _filteredVisitors[index]);
//                                 },
//                               );
//                             } else {
//                               return ListView.builder(
//                                 controller: _scrollController,
//                                 padding: const EdgeInsets.all(16),
//                                 itemCount: _filteredVisitors.length,
//                                 itemBuilder: (context, index) {
//                                   return Padding(
//                                     padding: const EdgeInsets.only(bottom: 12),
//                                     child: DayWiseVisitorsStatusUpdate(
//                                         visitor: _filteredVisitors[index]),
//                                   );
//                                 },
//                               );
//                             }
//                           },
//                         ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/modules/Visitors/presentation/widgets/day_wise_list.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class AllVisitorsList extends StatefulWidget {
  const AllVisitorsList({super.key});

  @override
  _AllVisitorsListState createState() => _AllVisitorsListState();
}

class _AllVisitorsListState extends State<AllVisitorsList> {
  bool isLoading = true;

  List<Map<String, dynamic>> _allVisitors = [];
  List<Map<String, dynamic>> _filteredVisitors = [];

  final ScrollController _scrollController = ScrollController();

  String selectedFilter = '';
  String filterValue = '';

  @override
  void initState() {
    super.initState();
    fetchVisitors();
  }

  /// ✅ Fetch ALL visitors (no date restriction)
  Future<void> fetchVisitors() async {
    try {
      setState(() => isLoading = true);

      final response = await Supabase.instance.client
          .from('visitor')
          .select()
          .order('visit_date', ascending: false);

      List<Map<String, dynamic>> visitors =
          List<Map<String, dynamic>>.from(response);

      setState(() {
        _allVisitors = visitors;
        _filteredVisitors = visitors;
        isLoading = false;
      });

      debugPrint("✅ Total visitors fetched: ${_allVisitors.length}");
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ Error fetching visitors: $e");
    }
  }

  /// Normalize strings for search
  String _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// ✅ Apply filter
  void _applyFilter(String type, String value) {
    final query = _normalize(value);
    selectedFilter = type;
    filterValue = value;

    setState(() {
      if (query.isEmpty) {
        _filteredVisitors = List.from(_allVisitors);
        debugPrint("🔍 No filter applied, showing all visitors.");
        return;
      }

      _filteredVisitors = _allVisitors.where((visitor) {
        final rawName = (visitor['visitor_name'] ?? '').toString();
        final rawPhone = (visitor['visitor_phone'] ?? '').toString();
        final rawDept = (visitor['department'] ?? '').toString();
        final rawPurpose = (visitor['purpose'] ?? '').toString();
        final rawDate = (visitor['visit_date'] ?? '').toString();

        final name = _normalize(rawName);
        final phone = rawPhone;
        final dept = _normalize(rawDept);
        final purpose = _normalize(rawPurpose);
        final date = _normalize(rawDate);

        if (type == 'Name') {
          return name.contains(query);
        } else if (type == 'Phone') {
          return phone.contains(query);
        } else if (type == 'Department') {
          return dept.contains(query);
        } else if (type == 'Purpose') {
          return purpose.contains(query);
        } else if (type == 'Date') {
          return date.contains(query);
        } else if (type == 'All') {
          return name.contains(query) ||
              phone.contains(query) ||
              dept.contains(query) ||
              purpose.contains(query) ||
              date.contains(query);
        }
        return false;
      }).toList();

      // ✅ Sort ranking for better matches
      int rank(Map v) {
        final n = _normalize((v['visitor_name'] ?? '').toString());
        if (n == query) return 3;
        if (n.startsWith(query)) return 2;
        if (n.contains(query)) return 1;
        return 0;
      }
      _filteredVisitors.sort((a, b) => rank(b).compareTo(rank(a)));

      // ✅ Print filter logs
      debugPrint("🔍 Filter Applied:");
      debugPrint("   $type filter: '$value'");
      debugPrint("✅ Filtered Visitors Count: ${_filteredVisitors.length}");
      for (var v in _filteredVisitors) {
        debugPrint("   - ${v['visitor_name']} (${v['visitor_phone']})");
      }
    });
  }

  /// ✅ Reset Filter
  void _resetFilter() {
    setState(() {
      selectedFilter = '';
      filterValue = '';
      _filteredVisitors = List.from(_allVisitors);
    });
    debugPrint("🔄 Filters reset. Showing all visitors.");
  }

  /// ✅ Show Filter Dialog
  void _showFilterDialog() {
    String selectedOption = 'All'; // default to All
    String inputValue = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Filter Visitors"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedOption,
                items: ['All', 'Name', 'Phone', 'Department', 'Purpose', 'Date']
                    .map((String option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(hintText: "Enter value"),
                onChanged: (val) {
                  inputValue = val;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _applyFilter(selectedOption, inputValue);
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Visitors",
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
          // ✅ Filter & Reset buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _showFilterDialog,
                  icon: const Icon(Icons.filter_list),
                  label: const Text("Filter"),
                ),
                ElevatedButton.icon(
                  onPressed: _resetFilter,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ),

          if (selectedFilter.isNotEmpty && filterValue.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Applied Filters: $selectedFilter = $filterValue",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchVisitors,
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
                                    padding:
                                        const EdgeInsets.only(bottom: 12.0),
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
