import 'dart:html' as html;

void stopMediaStreamHelper(dynamic stream) {
  if (stream is html.MediaStream) {
    for (var track in stream.getTracks()) {
      track.stop();
    }
  }
}
