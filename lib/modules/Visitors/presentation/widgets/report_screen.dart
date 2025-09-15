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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Visitors Report",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: KDRTColors.darkBlue,
        elevation: 6,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      /// --- Visitors by Department ---
                      _buildSectionCard(
                        title: "Visitors by Department",
                        child: SizedBox(
                          height: departmentData.length * 40 + 100, // auto height
                          child: BarChart(
                            BarChartData(
                              barTouchData: BarTouchData(enabled: true),
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: false),

                              /// Titles
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 120,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= 0 &&
                                          index < departmentData.keys.length) {
                                        return Text(
                                          departmentData.keys.elementAt(index),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) => Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),

                              /// Horizontal stacked bars
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
                                      rodStackItems: [
                                        BarChartRodStackItem(
                                          0,
                                          e.value.toDouble() * 0.5,
                                          Colors.blue.shade400,
                                        ),
                                        BarChartRodStackItem(
                                          e.value.toDouble() * 0.5,
                                          e.value.toDouble(),
                                          Colors.blue.shade900,
                                        ),
                                      ],
                                      width: 18,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// --- Purpose of Visits (Pie Chart) ---
                      _buildSectionCard(
                        title: "Purpose of Visits",
                        child: SizedBox(
  height: isWide ? 500 : 400,
  child: Column(
    children: [
      // Legend at the top
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: purposeData.entries.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final e = entry.value;
          final colors = [
            Colors.blue.shade900,
            Colors.indigo.shade600,
            Colors.teal.shade400,
            Colors.orange.shade400,
            Colors.purple.shade300,
            Colors.red.shade400,
          ];
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[index % colors.length],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "${e.key} (${e.value})",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          );
        }).toList(),
      ),

      const SizedBox(height: 16),

      // Pie Chart
      Expanded(
        child: PieChart(
          PieChartData(
            sectionsSpace: 4,
            centerSpaceRadius: 60,
            sections: purposeData.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final e = entry.value;
              final colors = [
                Colors.blue.shade900,
                const Color.fromARGB(255, 6, 11, 48),
                Colors.teal.shade400,
                Colors.orange.shade400,
                Colors.purple.shade300,
                Colors.red.shade400,
              ];
              return PieChartSectionData(
                value: e.value.toDouble(),
                color: colors[index % colors.length],
                title:"${e.key} (${e.value})", 
                titleStyle: TextStyle( fontSize: isWide ? 14 : 12, 
                fontWeight: FontWeight.bold,
                color: Colors.white, ), 
                radius: isWide ? 180 : 120,
                
              );
            }).toList(),
          ),
        ),
      ),
    ],
  ),
)

                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  /// Helper widget for section styling
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
