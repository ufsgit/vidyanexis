import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';

class CustomDropDown extends StatelessWidget {
  const CustomDropDown({
    super.key,
    required this.dashboardProvider,
    this.onChanged,
    this.value,
  });
  final DashboardProvider dashboardProvider;
  final void Function(String?)? onChanged;
  final String? value;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: value,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All')),
            DropdownMenuItem(value: 'tdy', child: Text('This Day')),
            DropdownMenuItem(value: 'th_wk', child: Text('This Week')),
            DropdownMenuItem(value: 'th_mnt', child: Text('This Month')),
          ],
          hint: const Text('Select'),
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down_outlined),
          onChanged: onChanged,
          onTap: () {},
        ),
      ),
    );
  }
}
