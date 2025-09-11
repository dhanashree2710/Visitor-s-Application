import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class VisitorReportScreen extends StatefulWidget {
  const VisitorReportScreen({super.key});

  @override
  State<VisitorReportScreen> createState() => _VisitorReportScreenState();
}

class _VisitorReportScreenState extends State<VisitorReportScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> visitors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVisitors();
  }

  Future<void> _fetchVisitors() async {
    final response = await supabase.from("visitor").select();
    setState(() {
      visitors = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  // Count visitors per department
  Map<String, int> getVisitorsByDepartment() {
    final Map<String, int> data = {};
    for (var v in visitors) {
      final dept = v["department"] ?? "Unknown";
      data[dept] = (data[dept] ?? 0) + 1;
    }
    return data;
  }

  // Count visitors per purpose
  Map<String, int> getVisitorsByPurpose() {
    final Map<String, int> data = {};
    for (var v in visitors) {
      final purpose = v["purpose"] ?? "Other";
      data[purpose] = (data[purpose] ?? 0) + 1;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final departmentData = getVisitorsByDepartment();
    final purposeData = getVisitorsByPurpose();

    return  Scaffold(
      appBar: AppBar(
        title: const Text(
          "Visitors Report",
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Visitors by Department (Bar Chart)
                  const Text("Visitors by Department",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 350,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceEvenly,
                        barGroups: departmentData.entries
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final e = entry.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.toDouble(),
                                color: Colors.blue.shade900,
                                width: 28,
                                borderRadius: BorderRadius.circular(6),
                              )
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 &&
                                    index < departmentData.keys.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      departmentData.keys.elementAt(index),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: true),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Purpose of Visits (Pie Chart)
                  const Text("Purpose of Visits",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 550,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 40,
                        sections: purposeData.entries.toList().asMap().entries.map((entry) {
                          final index = entry.key;
                          final e = entry.value;
                          final colors = [
                            Colors.blue.shade900,
                            Colors.blue.shade700,
                            Colors.blue.shade500,
                            Colors.blue.shade300,
                            Colors.blue.shade100,
                          ];
                          return PieChartSectionData(
                            value: e.value.toDouble(),
                            color: colors[index % colors.length],
                            title: "${e.key} (${e.value})",
                            titleStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            radius: 200,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
