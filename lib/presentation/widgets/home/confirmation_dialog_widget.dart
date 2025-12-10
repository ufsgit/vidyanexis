import 'package:flutter/material.dart';

class ConfirmationDialog extends StatefulWidget {
  final String title;
  final String content;
  final String cancelButtonText;
  final String confirmButtonText;
  final VoidCallback onCancel;
  final Function onConfirm;
  final bool isLoading;
  final Color confirmButtonColor;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.content,
    this.cancelButtonText = 'Cancel',
    this.confirmButtonText = 'Confirm',
    required this.onCancel,
    required this.onConfirm,
    this.isLoading = false,
    this.confirmButtonColor = Colors.red,
  }) : super(key: key);

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading;
  }

  @override
  void didUpdateWidget(ConfirmationDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading) {
      setState(() {
        _isLoading = widget.isLoading;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Text(widget.content),
      actions: <Widget>[
        // Cancel button
        TextButton(
          onPressed: widget.onCancel,
          child: Text(widget.cancelButtonText),
        ),
        // Confirm button
        _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(),
              )
            : TextButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    await widget.onConfirm();
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                child: Text(
                  widget.confirmButtonText,
                  style: TextStyle(color: widget.confirmButtonColor),
                ),
              ),
      ],
    );
  }
}

// Example usage:
void showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  String cancelButtonText = 'Cancel',
  String confirmButtonText = 'Confirm',
  required VoidCallback onCancel,
  required Function onConfirm,
  bool isLoading = false,
  Color confirmButtonColor = Colors.red,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ConfirmationDialog(
        title: title,
        content: content,
        cancelButtonText: cancelButtonText,
        confirmButtonText: confirmButtonText,
        onCancel: onCancel,
        onConfirm: onConfirm,
        isLoading: isLoading,
        confirmButtonColor: confirmButtonColor,
      );
    },
  );
}
