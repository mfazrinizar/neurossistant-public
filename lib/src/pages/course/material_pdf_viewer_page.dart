import 'package:flutter/material.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class MaterialPdfViewerPage extends StatelessWidget {
  final String pdfUrl;
  const MaterialPdfViewerPage({Key? key, required this.pdfUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 211, 227, 253)
                : Colors.white),
        title: Text(
            AppLocalizations.of(context)!.translate('course_pdf_material1') ??
                'PDF Material',
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromARGB(255, 211, 227, 253)
                    : Colors.white)),
      ),
      body: SfPdfViewer.network(pdfUrl),
    );
  }
}
