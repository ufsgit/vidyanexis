import 'dart:io'; void main() { var bytes = File('d:/vidyanexis/assets/images/cygnus.pdf').readAsBytesSync(); print('Size: ${bytes.length}'); }
