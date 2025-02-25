import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PdfContainer extends StatelessWidget {
  final String url;

  const PdfContainer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(pdfUrl: url),
            ),
          );
        },
        icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
      ),
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  const PdfViewerScreen({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const PDF().cachedFromUrl(
        pdfUrl,
        placeholder: (progress) => Center(
          child: CircularProgressIndicator(
            value: progress / 100,
          ),
        ),
        errorWidget: (error) => const Center(child: Text("Failed to load PDF")),
     ),
);
}
}
