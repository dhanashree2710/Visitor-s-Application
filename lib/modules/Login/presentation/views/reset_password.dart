import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final supabase = Supabase.instance.client;
  final passwordController = TextEditingController();
  bool loading = false;

  Future<void> updatePassword() async {
    setState(() => loading = true);
    try {
      final response = await supabase.auth.updateUser(
        UserAttributes(password: passwordController.text.trim()),
      );
      if (response.user != null) {
        _showDialog("✅ Password updated successfully! You can log in now.");
      } else {
        _showDialog("❌ Failed to update password.");
      }
    } catch (e) {
      _showDialog("❌ Error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  void _showDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reset Password"),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "New Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : updatePassword,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Update Password"),
            ),
          ],
        ),
      ),
    );
  }
}
