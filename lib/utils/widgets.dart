import 'package:flutter/material.dart';

Future<void> hideKeyboard() async {
  // await SystemChannels.textInput.invokeMethod('TextInput.hide');
  FocusManager.instance.primaryFocus?.unfocus();
}

bool isDarkMode(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

