import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class MyPdfViewer extends StatefulWidget {
  final String url;
  const MyPdfViewer({Key? key, required this.url}) : super(key: key);
  @override
  _MyPdfViewerState createState() => _MyPdfViewerState();
}

class _MyPdfViewerState extends State<MyPdfViewer> {
  bool isLoading = false;
  String? localPdfPath;
  Uint8List? pdfThumbnail;

  @override
  void initState() {
    super.initState();
    _generateThumbnail(widget.url);
  }

  Future<void> _generateThumbnail(String url) async {
    String localPath = await _downloadAndSavePdf(url);
    if (localPath.isNotEmpty) {
      final pdfDocument = await PdfDocument.openFile(localPath);
      final page = await pdfDocument.getPage(1);
      final image = await page.render(
        width: 200,
        height: 250,
        format: PdfPageImageFormat.png,
      );

      if (image != null) {
        setState(() {
          pdfThumbnail = image.bytes;
          localPdfPath = localPath;
        });
      }
      await page.close();
    } else {
      print("Error: PDF file path is empty!");
    }
  }

  Future<String> _downloadAndSavePdf(String url) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/temp.pdf');
        await file.writeAsBytes(response.bodyBytes);

        print("PDF saved at: ${file.path}"); // Debugging

        return file.path;
      } else {
        print("Failed to download PDF");
        return "";
      }
    } catch (e) {
      print("Error downloading PDF: $e");
      return "";
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (localPdfPath != null && localPdfPath!.isNotEmpty) {
          print("Opening PDF: $localPdfPath"); // Debugging
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewScreen(pdfPath: localPdfPath!),
            ),
          );
        } else {
          print("PDF file not available yet!");
        }
      },
      child: Container(
        width: 200,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          image: pdfThumbnail != null
              ? DecorationImage(
                  image: MemoryImage(pdfThumbnail!), fit: BoxFit.cover)
              : null,
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : pdfThumbnail == null
                ? const Center(
                    child:
                        Icon(Icons.picture_as_pdf, size: 50, color: Colors.red))
                : null,
      ),
    );
  }
}

class PdfViewScreen extends StatelessWidget {
  final String pdfPath;

  const PdfViewScreen({Key? key, required this.pdfPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PDFView(
        filePath: pdfPath,

        enableSwipe: true,
        // swipeHorizontal: true,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}
