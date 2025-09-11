import 'package:flutter/material.dart';
import 'package:visitors_and_grievance_application/modules/Grievance/presentation/views/register_grievance.dart';
import 'package:visitors_and_grievance_application/modules/Login/presentation/views/otp_login.dart';
import 'package:visitors_and_grievance_application/utils/common/custom_button.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Select Role"),
      //   centerTitle: true,
      //   backgroundColor: Colors.blue,
      // ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          bool isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomButton(
                    label: "Admin",
                    icon: Icons.admin_panel_settings,
                    width: isMobile ? double.infinity : (isTablet ? 200 : 250),
                    height: 60,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>UserLoginPage()));
                    },
                  ),
                  SizedBox(height: isMobile ? 16 : 0, width: isMobile ? 0 : 16),
                  CustomButton(
                    label: "Employee",
                    icon: Icons.people,
                    width: isMobile ? double.infinity : (isTablet ? 200 : 250),
                    height: 60,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>UserLoginPage()));
                    },
                  ),
                  SizedBox(height: isMobile ? 16 : 0, width: isMobile ? 0 : 16),
                  CustomButton(
                    label: "Grievance",
                    icon: Icons.report_problem,
                    width: isMobile ? double.infinity : (isTablet ? 200 : 250),
                    height: 60,
                    onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterGrievancePage()));
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
