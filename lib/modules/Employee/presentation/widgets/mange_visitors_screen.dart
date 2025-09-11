import 'package:flutter/material.dart';
import 'package:visitors_and_grievance_application/modules/Visitors/presentation/views/register_visitors.dart';
import 'package:visitors_and_grievance_application/modules/Visitors/presentation/widgets/all_visitors_list.dart';
import 'package:visitors_and_grievance_application/modules/Visitors/presentation/widgets/report_screen.dart';
import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';
import 'package:visitors_and_grievance_application/utils/components/kdrt_colors.dart';


class VisitorDashboardPage extends StatelessWidget {
  
  const VisitorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
          title: const Text(
            "Manage Visitors ",
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
                  // ---------------- Visitors List Button ----------------
                  CustomButton(
                    label: "Visitors List",
                    icon: Icons.list_alt,
                    width: isMobile ? double.infinity : (isTablet ? 200 : 250),
                    height: 60,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllVisitorsList(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: isMobile ? 16 : 0, width: isMobile ? 0 : 16),

                  // ---------------- Register Visitor Button ----------------
                  CustomButton(
                    label: "Register Visitor",
                    icon: Icons.person_add,
                    width: isMobile ? double.infinity : (isTablet ? 200 : 250),
                    height: 60,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VisitorRegistrationScreen(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: isMobile ? 16 : 0, width: isMobile ? 0 : 16),

                  // ---------------- Reports Button ----------------
                  CustomButton(
                    label: "Reports",
                    icon: Icons.analytics,
                    width: isMobile ? double.infinity : (isTablet ? 200 : 250),
                    height: 60,
                    onPressed: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  VisitorReportScreen(),
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
