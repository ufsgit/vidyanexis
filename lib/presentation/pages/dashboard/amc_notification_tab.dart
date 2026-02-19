import 'package:flutter/material.dart';

class AmcNotificationTab extends StatelessWidget {
  const AmcNotificationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
          'AMC Notifications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
