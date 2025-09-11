// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:visitors_and_grievance_application/modules/Visitors/presentation/views/register_visitors.dart';
// import 'package:visitors_and_grievance_application/modules/Visitors/presentation/widgets/department_wise_list.dart';
// import 'package:visitors_and_grievance_application/utils/common/appbar_drawer.dart';
// import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

// class EmployeeDashboard extends StatefulWidget {
//   final String role;
//  final String empId;

//   const EmployeeDashboard({super.key, required this.role, required this.empId});



//   @override
//   State<EmployeeDashboard> createState() => _EmployeeDashboardState();
// }

// class _EmployeeDashboardState extends State<EmployeeDashboard>
//     with SingleTickerProviderStateMixin {
//   final supabase = Supabase.instance.client;

//   List<Map<String, dynamic>> _allVisitors = [];
//   List<Map<String, dynamic>> departmentList = [];
//   int todayVisitorsCount = 0;
//   Map<String, int> departmentVisitorCounts = {};

//   late AnimationController _animationController;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     fetchDepartments();

//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//       lowerBound: 0.0,
//       upperBound: 0.1,
//     )..addListener(() {
//         setState(() {});
//       });

//     _animation = Tween<double>(begin: 1.0, end: 0.9).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> fetchDepartments() async {
//     try {
//       final response = await supabase
//           .from('department')
//           .select()
//           .order('dept_name', ascending: true);

//       final data = response as List<dynamic>;

//       setState(() {
//         departmentList = data.map((e) => e as Map<String, dynamic>).toList();
//       });

//       await fetchVisitors();
//     } catch (e) {
//       debugPrint("Error fetching departments: $e");
//     }
//   }

//   Future<void> fetchVisitors() async {
//     try {
//       final response = await supabase
//           .from('visitor')
//           .select()
//           .order('visit_date', ascending: false);

//       final data = response as List<dynamic>;

//       List<Map<String, dynamic>> visitors =
//           data.map((e) => e as Map<String, dynamic>).toList();

//       DateTime today = DateTime.now();
//       String todayDate =
//           "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

//       List<Map<String, dynamic>> todayVisitors = visitors
//           .where((visitor) => visitor['visit_date'] == todayDate)
//           .toList();

//       Map<String, int> deptCounts = {};
//       for (var dept in departmentList) {
//         int count = todayVisitors
//             .where((visitor) => visitor['department'] == dept['dept_name'])
//             .length;
//         deptCounts[dept['dept_name']] = count;
//       }

//       setState(() {
//         _allVisitors = visitors;
//         todayVisitorsCount = todayVisitors.length;
//         departmentVisitorCounts = deptCounts;
//       });

//       debugPrint(
//           "Fetched ${visitors.length} visitors, today's count: ${todayVisitors.length}");
//     } catch (e) {
//       debugPrint("Error fetching visitors: $e");
//     }
//   }

//   void _navigateToDetails(String? department) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) =>
//             DepartmentWiseVisitorsList(selectedDepartment: department),
//       ),
//     );
//   }

//   void _onFabTapDown(TapDownDetails details) => _animationController.forward();
//   void _onFabTapUp(TapUpDetails details) => _animationController.reverse();
//   void _navigateToRegisterVisitor() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) =>  VisitorRegistrationScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     DateTime now = DateTime.now();
//     String formattedDate = "${now.day}-${now.month}-${now.year}";
//     String dayOfWeek = [
//       "Sunday",
//       "Monday",
//       "Tuesday",
//       "Wednesday",
//       "Thursday",
//       "Friday",
//       "Saturday"
//     ][now.weekday - 1];

//     return WillPopScope(
//       onWillPop: () async => false,
//       child: CommonScaffold(
//         title: "Employee Dashboard",
//         role: widget.role,
//         body: Stack(
//           children: [
//             RefreshIndicator(
//               onRefresh: fetchDepartments,
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Center(
//                       child: Text(
//                         "$dayOfWeek, $formattedDate",
//                         style: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: KDRTColors.darkBlue),
//                       ),
//                     ),
//                     const SizedBox(height: 12),

//                     /// Full width for today's visitors
//                     SizedBox(
//                       width: double.infinity,
//                       child: _buildCard("Today's Visitors", todayVisitorsCount,
//                           () {
//                         _navigateToDetails(null);
//                       }, fullWidth: true),
//                     ),

//                     const SizedBox(height: 12),
//                     const Center(
//                       child: Text(
//                         "Visitors by Department",
//                         style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: KDRTColors.darkBlue),
//                       ),
//                     ),
//                     const SizedBox(height: 8),

//                     LayoutBuilder(builder: (context, constraints) {
//                       // ✅ Responsive Grid
//                       int crossAxisCount = constraints.maxWidth < 600
//                           ? 2
//                           : constraints.maxWidth < 1000
//                               ? 3
//                               : 4;
//                       double childAspectRatio =
//                           constraints.maxWidth < 600 ? 1.3 : 1.5;

//                       return GridView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: crossAxisCount,
//                           childAspectRatio: childAspectRatio,
//                           crossAxisSpacing: 8,
//                           mainAxisSpacing: 8,
//                         ),
//                         itemCount: departmentList.length,
//                         itemBuilder: (context, index) {
//                           String deptName = departmentList[index]['dept_name'];
//                           int deptCount =
//                               departmentVisitorCounts[deptName] ?? 0;
//                           return _buildCard(deptName, deptCount, () {
//                             _navigateToDetails(deptName);
//                           });
//                         },
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//             ),

//             /// ✅ Floating Action Button fixed at bottom right
//             Positioned(
//               bottom: 16,
//               right: 16,
//               child: GestureDetector(
//                 onTapDown: _onFabTapDown,
//                 onTapUp: _onFabTapUp,
//                 onTapCancel: () => _animationController.reverse(),
//                 onTap: _navigateToRegisterVisitor,
//                 child: Transform.scale(
//                   scale: _animation.value,
//                   child: Container(
//                     height: 60,
//                     width: 60,
//                     decoration: BoxDecoration(
//                       color: KDRTColors.darkBlue,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: KDRTColors.darkBlue.withOpacity(0.6),
//                           blurRadius: 10,
//                           spreadRadius: 2,
//                         ),
//                       ],
//                     ),
//                     child: const Icon(Icons.add, color: Colors.white, size: 30),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// ✅ Card Builder
//   Widget _buildCard(String title, int count, VoidCallback onTap,
//       {bool fullWidth = false}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(2),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: KDRTColors.darkBlue,
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Center(
//                 child: Text(title,
//                     style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: KDRTColors.darkBlue),
//                     textAlign: TextAlign.center),
//               ),
//               const SizedBox(height: 4),
//               Text(count.toString(),
//                   style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: KDRTColors.darkBlue),
//                   textAlign: TextAlign.center),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/modules/Visitors/presentation/views/register_visitors.dart';
import 'package:visitors_and_grievance_application/modules/Visitors/presentation/widgets/department_wise_list.dart';
import 'package:visitors_and_grievance_application/utils/common/appbar_drawer.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class EmployeeDashboard extends StatefulWidget {
  final String role;
  final String empId;   // ✅ Employee ID
   // ✅ Admin ID

  const EmployeeDashboard({
    super.key,
    required this.role,
    required this.empId,
   
  });

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _allVisitors = [];
  List<Map<String, dynamic>> departmentList = [];
  int todayVisitorsCount = 0;
  Map<String, int> departmentVisitorCounts = {};

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    fetchDepartments();

    // ✅ Print empId and adminId in console
    debugPrint("EmployeeDashboard initialized with empId: ${widget.empId}");
  
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });

    _animation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// ✅ Fetch Departments
  Future<void> fetchDepartments() async {
    try {
      final response = await supabase
          .from('department')
          .select()
          .order('dept_name', ascending: true);

      final data = response as List<dynamic>;

      setState(() {
        departmentList = data.map((e) => e as Map<String, dynamic>).toList();
      });

      await fetchVisitors();
    } catch (e) {
      debugPrint("Error fetching departments: $e");
    }
  }

  /// ✅ Fetch Visitors
  Future<void> fetchVisitors() async {
    try {
      final response = await supabase
          .from('visitor')
          .select()
          .order('visit_date', ascending: false);

      final data = response as List<dynamic>;

      List<Map<String, dynamic>> visitors =
          data.map((e) => e as Map<String, dynamic>).toList();

      DateTime today = DateTime.now();
      String todayDate =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      List<Map<String, dynamic>> todayVisitors = visitors
          .where((visitor) => visitor['visit_date'] == todayDate)
          .toList();

      Map<String, int> deptCounts = {};
      for (var dept in departmentList) {
        int count = todayVisitors
            .where((visitor) => visitor['department'] == dept['dept_name'])
            .length;
        deptCounts[dept['dept_name']] = count;
      }

      setState(() {
        _allVisitors = visitors;
        todayVisitorsCount = todayVisitors.length;
        departmentVisitorCounts = deptCounts;
      });

      debugPrint(
          "Fetched ${visitors.length} visitors, today's count: ${todayVisitors.length}");
    } catch (e) {
      debugPrint("Error fetching visitors: $e");
    }
  }

  /// ✅ Insert Attendance into Supabase
  Future<void> markAttendance() async {
    try {
      final response = await supabase.from('employee_attendance').insert({
        'emp_id': widget.empId,
        'attendance_date': DateTime.now().toIso8601String().substring(0, 10),
        'in_time': DateTime.now().toIso8601String(),
       // ✅ Extra column for admin if needed
      });

      debugPrint("Attendance response: $response");

      // ✅ Show confirmation popup
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Attendance Marked"),
          content: const Text("Your attendance has been successfully recorded."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint("Error marking attendance: $e");

      // ✅ Error popup
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text("Failed to mark attendance: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _navigateToDetails(String? department) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DepartmentWiseVisitorsList(selectedDepartment: department),
      ),
    );
  }

  void _onFabTapDown(TapDownDetails details) => _animationController.forward();
  void _onFabTapUp(TapUpDetails details) => _animationController.reverse();
  void _navigateToRegisterVisitor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VisitorRegistrationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = "${now.day}-${now.month}-${now.year}";
    String dayOfWeek = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ][now.weekday - 1];

    return WillPopScope(
      onWillPop: () async => false,
      child: CommonScaffold(
        title: "Employee Dashboard",
        role: widget.role,
        empId: widget.empId,
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: fetchDepartments,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "$dayOfWeek, $formattedDate",
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: KDRTColors.darkBlue),
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// Full width for today's visitors
                    SizedBox(
                      width: double.infinity,
                      child: _buildCard("Today's Visitors", todayVisitorsCount,
                          () {
                        _navigateToDetails(null);
                      }, fullWidth: true),
                    ),

                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        "Visitors by Department",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: KDRTColors.darkBlue),
                      ),
                    ),
                    const SizedBox(height: 8),

                    LayoutBuilder(builder: (context, constraints) {
                      // ✅ Responsive Grid
                      int crossAxisCount = constraints.maxWidth < 600
                          ? 2
                          : constraints.maxWidth < 1000
                              ? 3
                              : 4;
                      double childAspectRatio =
                          constraints.maxWidth < 600 ? 1.3 : 1.5;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: departmentList.length,
                        itemBuilder: (context, index) {
                          String deptName = departmentList[index]['dept_name'];
                          int deptCount =
                              departmentVisitorCounts[deptName] ?? 0;
                          return _buildCard(deptName, deptCount, () {
                            _navigateToDetails(deptName);
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),

            /// ✅ Floating Action Button fixed at bottom right
            Positioned(
              bottom: 16,
              right: 16,
              child: GestureDetector(
                onTapDown: _onFabTapDown,
                onTapUp: _onFabTapUp,
                onTapCancel: () => _animationController.reverse(),
                onTap: _navigateToRegisterVisitor,
                child: Transform.scale(
                  scale: _animation.value,
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: KDRTColors.darkBlue,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: KDRTColors.darkBlue.withOpacity(0.6),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Card Builder
  Widget _buildCard(String title, int count, VoidCallback onTap,
      {bool fullWidth = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: KDRTColors.darkBlue,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: KDRTColors.darkBlue),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(height: 4),
              Text(count.toString(),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: KDRTColors.darkBlue),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}