import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:printing/printing.dart';
import 'dart:html' as html;

class PdfViewerScreen extends StatefulWidget {
  final Uint8List pdfData;
  final String title;

  const PdfViewerScreen({
    Key? key,
    required this.pdfData,
    required this.title,
  }) : super(key: key);

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late String _pdfPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initPdfFile();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _initPdfFile() async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/customized_pdf.pdf';
    final file = File(path);
    await file.writeAsBytes(widget.pdfData);
    _pdfPath = path;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () async {
              await Printing.layoutPdf(
                onLayout: (_) async => widget.pdfData,
                name: widget.title,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              if (kIsWeb) {
                // Handle web download
                final blob = html.Blob([widget.pdfData]);
                final url = html.Url.createObjectUrlFromBlob(blob);
                final anchor = html.AnchorElement(href: url)
                  ..setAttribute('download', '${widget.title}.pdf')
                  ..click();
                html.Url.revokeObjectUrl(url);
              } else {
                // Handle mobile download to downloads folder
                final dir = await getExternalStorageDirectory();
                if (dir != null) {
                  final file = File('${dir.path}/${widget.title}.pdf');
                  await file.writeAsBytes(widget.pdfData);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Downloaded to ${file.path}')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : kIsWeb
              ? PdfPreview(
                  build: (format) => widget.pdfData,
                  useActions: false,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                )
              : PDFView(
                  filePath: _pdfPath,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: true,
                  pageFling: true,
                  pageSnap: true,
                  fitPolicy: FitPolicy.BOTH,
                  preventLinkNavigation: false,
                ),
    );
  }
}
