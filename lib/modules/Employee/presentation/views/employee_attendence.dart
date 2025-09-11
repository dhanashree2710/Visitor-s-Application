import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';
import 'package:visitors_and_grievance_application/utils/common/pop_up_screen.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  final String empId;

  const EmployeeAttendanceScreen({super.key, required this.empId});

  @override
  State<EmployeeAttendanceScreen> createState() =>
      _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  bool isLoading = false;
  String? employeeName;
  String? inTime;
  String? outTime;
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    fetchEmployeeData();
  }

  /// ✅ Fetch Employee Name & Today's Attendance
  Future<void> fetchEmployeeData() async {
    try {
      final supabase = Supabase.instance.client;

      // Fetch employee name
      final empResponse = await supabase
          .from('employee')
          .select('emp_name')
          .eq('emp_id', widget.empId)
          .maybeSingle();

      // Fetch today's attendance
      final attendanceResponse = await supabase
          .from('employee_attendance')
          .select('in_time, out_time')
          .eq('emp_id', widget.empId)
          .eq('attendance_date', today)
          .maybeSingle();

      setState(() {
        employeeName = empResponse?['emp_name'] ?? "Employee";
        inTime = attendanceResponse?['in_time'];
        outTime = attendanceResponse?['out_time'];
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() {
        employeeName = "Employee";
      });
    }
  }

  /// ✅ Check-In Function
  Future<void> checkIn() async {
    setState(() => isLoading = true);
    try {
      final supabase = Supabase.instance.client;

      final existing = await supabase
          .from('employee_attendance')
          .select()
          .eq('emp_id', widget.empId)
          .eq('attendance_date', today);

      if (existing.isNotEmpty) {
        showCustomAlert(context,
            isSuccess: false,
            title: 'Already Checked In',
            description: 'You have already checked in today.');
      } else {
        final now = DateTime.now().toIso8601String();
        await supabase.from('employee_attendance').insert({
          'emp_id': widget.empId,
          'attendance_date': today,
          'in_time': now,
        });

        setState(() {
          inTime = now;
        });

        showCustomAlert(context,
            isSuccess: true,
            title: 'Check-In Successful',
            description: 'Your check-in has been recorded.');
      }
    } catch (e) {
      showCustomAlert(context,
          isSuccess: false, title: 'Error', description: e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ✅ Check-Out Function
  Future<void> checkOut() async {
    setState(() => isLoading = true);
    try {
      final supabase = Supabase.instance.client;

      final existing = await supabase
          .from('employee_attendance')
          .select()
          .eq('emp_id', widget.empId)
          .eq('attendance_date', today)
          .isFilter('out_time', null);

      if (existing.isEmpty) {
        showCustomAlert(context,
            isSuccess: false,
            title: 'Cannot Check Out',
            description:
                'You have not checked in today or already checked out.');
      } else {
        final now = DateTime.now().toIso8601String();
        await supabase
            .from('employee_attendance')
            .update({'out_time': now})
            .eq('emp_id', widget.empId)
            .eq('attendance_date', today)
            .isFilter('out_time', null);

        setState(() {
          outTime = now;
        });

        showCustomAlert(context,
            isSuccess: true,
            title: 'Check-Out Successful',
            description: 'Your check-out has been recorded.');
      }
    } catch (e) {
      showCustomAlert(context,
          isSuccess: false, title: 'Error', description: e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ✅ Convert ISO time to 12-hour format
  String formatDateTime(String? isoString) {
    if (isoString == null) return '-';
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('hh:mm a').format(dateTime); // Example: 02:45 PM
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KDRTColors.white,
      appBar: AppBar(
        title: Text(
          "${employeeName ?? 'Loading...'} Attendance",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: KDRTColors.darkBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.blue)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Check-In Time: ${formatDateTime(inTime)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Check-Out Time: ${formatDateTime(outTime)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 40),
                  CustomButtonField(
                    label: 'Check In',
                    width: 200,
                    height: 50,
                    onPressed: checkIn,
                  ),
                  const SizedBox(height: 20),
                  CustomButtonField(
                    label: 'Check Out',
                    width: 200,
                    height: 50,
                    onPressed: checkOut,
                  ),
                ],
              ),
      ),
    );
  }
}
