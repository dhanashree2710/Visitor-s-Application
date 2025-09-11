import 'package:flutter/material.dart';
import 'package:visitors_and_grievance_application/modules/Grievance/presentation/views/grievance_list.dart';
import 'package:visitors_and_grievance_application/modules/Grievance/presentation/views/register_grievance.dart';
import 'package:visitors_and_grievance_application/modules/Grievance/presentation/views/resolved_grievance.dart';
import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';

class ManageGrievanceScreen extends StatelessWidget {
  const ManageGrievanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manage Grievances",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: KDRTColors.darkBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: KDRTColors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// ---------------- Grievance List Button ----------------
                  CustomButton(
                    label: "Grievance List",
                    icon: Icons.list_alt,
                    width: isMobile ? double.infinity : (isTablet ? 200 : 250),
                    height: 60,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminGrievanceScreen(), // ✅ Navigate to Grievance List
                        ),
                      );
                    },
                  ),

                  SizedBox(height: isMobile ? 16 : 0, width: isMobile ? 0 : 16),

                  /// ---------------- Register Grievance Button ----------------
                  CustomButton(
                    label: "Register Grievance",
                    icon: Icons.add_comment,
                    width: isMobile ? double.infinity : (isTablet ? 200 : 250),
                    height: 60,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterGrievancePage(), // ✅ Navigate to Register Grievance
                        ),
                      );
                    },
                  ),

                  SizedBox(height: isMobile ? 16 : 0, width: isMobile ? 0 : 16),

                  /// ---------------- Resolved Grievances Button ----------------
                  CustomButton(
                    label: "Resolved Grievances",
                    icon: Icons.check_circle,
                    width: isMobile ? double.infinity : (isTablet ? 200 : 250),
                    height: 60,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResolvedGrievanceScreen(), // ✅ Navigate to Resolved Grievances
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
