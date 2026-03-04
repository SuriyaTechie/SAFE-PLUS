import 'package:flutter/material.dart';

class EmergencyButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const EmergencyButtonWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
        child: const Text('TRIGGER EMERGENCY'),
      ),
    );
  }
}
