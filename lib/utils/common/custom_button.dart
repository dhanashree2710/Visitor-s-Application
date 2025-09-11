import 'package:flutter/material.dart';

import '../components/kdrt_colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final double width;
  final double height;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.label,
    required this.icon,
    required this.width,
    required this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(WidgetState.hovered)) {
                return KDRTColors.darkBlue; // lighter blue on hover
              }
              return KDRTColors.darkBlue; // dark blue default
            },
          ),
          overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
          elevation: WidgetStateProperty.resolveWith<double>(
            (states) => states.contains(WidgetState.pressed) ? 2 : 6,
          ),
          shadowColor: WidgetStateProperty.all(Colors.black.withOpacity(0.3)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (states) {
              if (states.contains(WidgetState.hovered)) {
                return const BorderSide(
                    color: KDRTColors.darkBlue, width: 2);
              }
              return const BorderSide(color: Colors.transparent, width: 2);
            },
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class CustomButtonField extends StatelessWidget {
  final String label;
  final double width;
  final double height;
  final VoidCallback onPressed;

  const CustomButtonField({
    super.key,
    required this.label,
    required this.width,
    required this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(WidgetState.hovered)) {
                return KDRTColors.darkBlue; // lighter blue on hover
              }
              return KDRTColors.darkBlue; // dark blue default
            },
          ),
          overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
          elevation: WidgetStateProperty.resolveWith<double>(
            (states) => states.contains(WidgetState.pressed) ? 2 : 6,
          ),
          shadowColor: WidgetStateProperty.all(Colors.black.withOpacity(0.3)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (states) {
              if (states.contains(WidgetState.hovered)) {
                return const BorderSide(
                    color: KDRTColors.darkBlue, width: 2);
              }
              return const BorderSide(color: Colors.transparent, width: 2);
            },
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
              fontStyle: FontStyle.normal, fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
