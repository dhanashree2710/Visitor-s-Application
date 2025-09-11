import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> _allData = [];
  List<Map<String, dynamic>> _filteredData = [];
  final TextEditingController _searchController = TextEditingController();

  final LinearGradient gradient = LinearGradient(
    colors: [KDRTColors.darkBlue, Colors.cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  /// Fetch Employees and Visitors from Supabase
  Future<void> _fetchAllData() async {
    try {
      List<Map<String, dynamic>> combinedData = [];

      /// Fetch Employees
      final employeeResponse = await Supabase.instance.client
          .from('employee')
          .select();

      for (var data in employeeResponse) {
        data['type'] = 'Employee';
        combinedData.add(Map<String, dynamic>.from(data));
      }

      /// Fetch Visitors
      final visitorResponse = await Supabase.instance.client
          .from('visitor')
          .select();

      for (var data in visitorResponse) {
        data['type'] = 'Visitor';
        combinedData.add(Map<String, dynamic>.from(data));
      }

      setState(() {
        _allData = combinedData;
        _filteredData = combinedData;
      });
    } catch (e) {
      debugPrint("Error fetching data from Supabase: $e");
    }
  }

  /// Search Logic (by Name, Department, Visitor Name)
  void _searchData(String query) {
    setState(() {
      _filteredData = _allData.where((data) {
        String name =
            (data['emp_name'] ?? data['visitor_name'] ?? '').toLowerCase();
        String dept = (data['emp_dept'] ?? '').toLowerCase();
        return name.contains(query.toLowerCase()) ||
            dept.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: gradient),
          ),
        ),
      ),
      backgroundColor: KDRTColors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Gradient Text Title
            Center(
              child: GradientText(
                "Search",
                gradient: gradient,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            /// Search Bar
            TextField(
              controller: _searchController,
              onChanged: _searchData,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search by Name, Dept, or Visitor",
                hintStyle: const TextStyle(color: Colors.black54),
                prefixIcon: Icon(Icons.search, color: KDRTColors.darkBlue),
                filled: true,
                fillColor: KDRTColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: KDRTColors.darkBlue, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// Results List
            Expanded(
              child: _filteredData.isEmpty
                  ? const Center(
                      child: Text("No results found!",
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _filteredData.length,
                      itemBuilder: (context, index) {
                        var data = _filteredData[index];
                        return _buildDataCard(data);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Data Card (Employee / Visitor)
  Widget _buildDataCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientText(
              data['type'] == "Employee"
                  ? data['emp_name'] ?? "Unknown"
                  : data['visitor_name'] ?? "Unknown",
              gradient: gradient,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Type: ${data['type']}"),
            if (data['emp_dept'] != null)
              Text("Department: ${data['emp_dept']}"),
            if (data['emp_email'] != null) Text("Email: ${data['emp_email']}"),
            if (data['emp_phone'] != null) Text("Phone: ${data['emp_phone']}"),
            if (data['visitor_purpose'] != null)
              Text("Purpose: ${data['visitor_purpose']}"),
          ],
        ),
      ),
    );
  }
}

/// Gradient Text Widget
class GradientText extends StatelessWidget {
  final String text;
  final LinearGradient gradient;
  final TextStyle style;

  const GradientText(this.text, {super.key, required this.gradient, required this.style});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}
