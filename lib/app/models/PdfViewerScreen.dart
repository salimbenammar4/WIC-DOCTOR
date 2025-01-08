import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;

  PdfViewerScreen({required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Viewer"),
      ),
      body: PDFView(
        filePath: pdfUrl,
        autoSpacing: true,
        pageFling: true,
        pageSnap: true,
        onPageChanged: (int? current, int? total) {
          print('Page $current of $total');
        },
      ),
    );
  }
}
