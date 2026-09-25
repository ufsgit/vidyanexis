import 'package:flutter/material.dart';

class TaskAudioRecordingWidget extends StatefulWidget {
  const TaskAudioRecordingWidget({Key? key}) : super(key: key);

  @override
  State<TaskAudioRecordingWidget> createState() => _TaskAudioRecordingWidgetState();
}

class _TaskAudioRecordingWidgetState extends State<TaskAudioRecordingWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Row(
        children: [
          Icon(Icons.mic, color: Colors.blue),
          SizedBox(width: 8),
          Text('Audio Recording Widget (Placeholder)'),
        ],
      ),
    );
  }
}
