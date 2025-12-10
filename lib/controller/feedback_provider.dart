import 'package:flutter/material.dart';

class FeedbackProvider extends ChangeNotifier {
  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;

  Future<void> submitFeedback(
      String feedback, String customerId, String taskId) async {
    print(customerId);
    print(taskId);

    _isSubmitting = true;
    notifyListeners();

    // Simulate API request delay
    await Future.delayed(const Duration(seconds: 1));

    _isSubmitting = false;
    notifyListeners();
  }
}
