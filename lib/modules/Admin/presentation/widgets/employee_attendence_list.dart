import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class EmployeeAttendanceListScreen extends StatefulWidget {
  const EmployeeAttendanceListScreen({super.key});

  @override
  State<EmployeeAttendanceListScreen> createState() =>
      _EmployeeAttendanceListScreenState();
}

class _EmployeeAttendanceListScreenState
    extends State<EmployeeAttendanceListScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> attendanceList = [];

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  /// ✅ Fetch all attendance with employee name
  Future<void> fetchAttendanceData() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('employee_attendance')
          .select(
              'attendance_id, attendance_date, in_time, out_time, employee!inner(emp_name)')
          .order('attendance_date', ascending: false);

      setState(() {
        attendanceList = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching attendance data: $e");
      setState(() => isLoading = false);
    }
  }

  /// ✅ Delete attendance record
  Future<void> deleteAttendance(String attendanceId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('employee_attendance')
          .delete()
          .eq('attendance_id', attendanceId);

      setState(() {
        attendanceList
            .removeWhere((record) => record['attendance_id'] == attendanceId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Record deleted successfully")),
      );
    } catch (e) {
      debugPrint("Error deleting record: $e");
    }
  }

  /// ✅ Parse time safely from ISO or HH:mm
  TimeOfDay? parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;

    try {
      // Try parsing full ISO datetime
      final dateTime = DateTime.tryParse(timeString);
      if (dateTime != null) {
        return TimeOfDay.fromDateTime(dateTime);
      }

      // If it's plain "HH:mm"
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (e) {
      debugPrint("Error parsing time: $e");
    }
    return null;
  }

  /// ✅ Show edit dialog with Time Pickers
  void editAttendance(Map<String, dynamic> record) {
    TimeOfDay? selectedInTime = parseTime(record['in_time']);
    TimeOfDay? selectedOutTime = parseTime(record['out_time']);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Edit Attendance - ${record['employee']?['emp_name']}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                        "In Time: ${selectedInTime != null ? selectedInTime?.format(context) : 'Not Set'}"),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedInTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          selectedInTime = picked;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                        "Out Time: ${selectedOutTime != null ? selectedOutTime?.format(context) : 'Not Set'}"),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedOutTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          selectedOutTime = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: KDRTColors.darkBlue),
                  onPressed: () async {
                    Navigator.pop(context);
                    await updateAttendance(
                      record['attendance_id'],
                      selectedInTime,
                      selectedOutTime,
                    );
                  },
                  child: const Text("Update", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// ✅ Update attendance in Supabase
  Future<void> updateAttendance(
      String attendanceId, TimeOfDay? inTime, TimeOfDay? outTime) async {
    try {
      final supabase = Supabase.instance.client;
      DateTime today = DateTime.now();

      DateTime? inDateTime;
      DateTime? outDateTime;

      if (inTime != null) {
        inDateTime = DateTime(today.year, today.month, today.day, inTime.hour, inTime.minute);
      }
      if (outTime != null) {
        outDateTime = DateTime(today.year, today.month, today.day, outTime.hour, outTime.minute);
      }

      await supabase.from('employee_attendance').update({
        'in_time': inDateTime?.toIso8601String(),
        'out_time': outDateTime?.toIso8601String(),
      }).eq('attendance_id', attendanceId);

      await fetchAttendanceData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance updated successfully")),
      );
    } catch (e) {
      debugPrint("Error updating attendance: $e");
    }
  }

  /// ✅ Format time in 12-hour format
  String formatTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final dateTime = DateTime.tryParse(isoString);
      if (dateTime != null) {
        return DateFormat('hh:mm a').format(dateTime);
      }
      // If plain HH:mm
      final parts = isoString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final dt = DateTime(2000, 1, 1, hour, minute);
        return DateFormat('hh:mm a').format(dt);
      }
    } catch (e) {
      debugPrint("Error formatting time: $e");
    }
    return '-';
  }

  /// ✅ Format date
  String formatDate(String? isoString) {
    if (isoString == null) return '-';
    final date = DateTime.parse(isoString);
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Employee Attendance",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: KDRTColors.darkBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : attendanceList.isEmpty
              ? const Center(child: Text("No attendance records found."))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minWidth: constraints.maxWidth),
                          child: SingleChildScrollView(
                            child: DataTable(
                              columnSpacing: 20,
                              headingRowColor:
                                  WidgetStateProperty.all(KDRTColors.darkBlue),
                              headingTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              columns: const [
                                DataColumn(label: Text("Employee Name")),
                                DataColumn(label: Text("Date")),
                                DataColumn(label: Text("In Time")),
                                DataColumn(label: Text("Out Time")),
                                DataColumn(label: Text("Actions")),
                              ],
                              rows: attendanceList.map((record) {
                                final empName =
                                    record['employee']?['emp_name'] ?? 'N/A';
                                final date =
                                    formatDate(record['attendance_date']);
                                final inTime = formatTime(record['in_time']);
                                final outTime = formatTime(record['out_time']);

                                return DataRow(cells: [
                                  DataCell(Text(empName)),
                                  DataCell(Text(date)),
                                  DataCell(Text(inTime)),
                                  DataCell(Text(outTime)),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () => editAttendance(record),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => deleteAttendance(
                                            record['attendance_id']),
                                      ),
                                    ],
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
