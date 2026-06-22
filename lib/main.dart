import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/views/register_admin.dart';
import 'package:visitors_and_grievance_application/modules/Admin/presentation/views/register_user.dart';
import 'package:visitors_and_grievance_application/modules/Employee/presentation/views/employee_home_dashboard.dart';
import 'package:visitors_and_grievance_application/modules/Login/presentation/views/reset_password.dart';
import 'package:visitors_and_grievance_application/modules/Login/presentation/views/role_page.dart';
import 'package:visitors_and_grievance_application/modules/Visitors/presentation/widgets/all_visitors_list.dart';
import 'package:visitors_and_grievance_application/modules/Visitors/presentation/widgets/report_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://oinlnlvdlmwjbtcwgjgp.supabase.co',
    anonKey:
'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9pbmxubHZkbG13amJ0Y3dnamdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE5MzcxNzAsImV4cCI6MjA5NzUxMzE3MH0.RypzxhZGtIPkgZYq7o4tKaK88_z4cPJrKtIbBSnpE44'  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
 
  final supabase = Supabase.instance.client;
 



  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      title: 'Visitor Application',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
   // home: UserRegisterPage(role: 'admin',),
     home: RoleSelectionPage(),
  
    );
  }
}

