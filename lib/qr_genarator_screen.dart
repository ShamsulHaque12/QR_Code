import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart'; // for QR display

class QrGenaratorScreen extends StatefulWidget {
  const QrGenaratorScreen({super.key});

  @override
  State<QrGenaratorScreen> createState() => _QrGenaratorScreenState();
}

class _QrGenaratorScreenState extends State<QrGenaratorScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();

  String qrData = "";
  String selectedtype = "text";

  final Map<String, TextEditingController> _controller = {
    'name': TextEditingController(),
    'phone': TextEditingController(),
    'email': TextEditingController(),
    'url': TextEditingController(),
  };

  String _generateQRData() {
    switch (selectedtype) {
      case 'contact':
        return '''BEGIN:VCARD
VERSION:3.0
FN:${_controller['name']?.text}
TEL:${_controller['phone']?.text}
EMAIL:${_controller['email']?.text}
END:VCARD''';

      case 'url':
        String url = _controller['url']?.text ?? '';
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          url = 'https://$url';
        }
        return url;

      default:
        return _textEditingController.text;
    }
  }

  Future<void> _shareQrCode() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = "${directory.path}/qr_code.png";
    final capture = await _screenshotController.capture();

    if (capture == null) return;

    File imageFile = File(imagePath);
    await imageFile.writeAsBytes(capture);
    await Share.shareXFiles([XFile(imagePath)], text: "Share QR Code");
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onChanged: (_) {
          setState(() {
            qrData = _generateQRData();
          });
        },
      ),
    );
  }

  Widget _buildInputField() {
    switch (selectedtype) {
      case "contact":
        return Column(
          children: [
            _buildTextField(_controller["name"]!, "Name"),
            _buildTextField(_controller["phone"]!, "Phone"),
            _buildTextField(_controller["email"]!, "Email"),
          ],
        );

      case "url":
        return _buildTextField(_controller["url"]!, "URL");

      default:
        return TextField(
          controller: _textEditingController,
          decoration: InputDecoration(
            labelText: "Enter Text",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onChanged: (_) {
            setState(() {
              qrData = _generateQRData();
            });
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text("Generate QR Code"),
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      SegmentedButton<String>(
                        selected: {selectedtype},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() {
                            selectedtype = selection.first;
                            qrData = "";
                          });
                        },
                        segments: const [
                          ButtonSegment(
                            value: "text",
                            label: Text("Text"),
                            icon: Icon(Icons.text_fields),
                          ),
                          ButtonSegment(
                            value: "url",
                            label: Text("URL"),
                            icon: Icon(Icons.link),
                          ),
                          ButtonSegment(
                            value: "contact",
                            label: Text("Contact"),
                            icon: Icon(Icons.contact_page),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(),
                      const SizedBox(height: 20),
                      if (qrData.isNotEmpty)
                        Column(
                          children: [
                            Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Screenshot(
                                  controller: _screenshotController,
                                  child: QrImageView(
                                    data: qrData,
                                    version: QrVersions.auto,
                                    size: 200,
                                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                                    backgroundColor: Colors
                                        .white, // important for visibility
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: _shareQrCode,
                icon: Icon(Icons.share),
                label: Text("Share QR Code"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
