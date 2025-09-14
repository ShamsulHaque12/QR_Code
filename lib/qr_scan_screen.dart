import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart'
    show FlutterContacts, Contact;
import 'package:mobile_scanner/mobile_scanner.dart' hide Phone, Email;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  bool hasPermission = false;
  bool isFlashOn = false;
  late MobileScannerController scannerController;

  @override
  void initState() {
    super.initState();
    scannerController = MobileScannerController();
    _checkPermission();
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      hasPermission = status.isGranted;
    });
  }

  Future<void> _processScannedData(String? data) async {
    if (data == null) return;
    scannerController.stop();

    String type = "text";
    if (data.startsWith("BEGIN:VCARD")) {
      type = "contact";
    } else if (data.startsWith("http://") || data.startsWith("https://")) {
      type = "url";
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                "Scanned Result:",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 15),
              Text(
                "Type: ${type.toUpperCase()}",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        data,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 25),
                      if (type == "url")
                        ElevatedButton.icon(
                          onPressed: () => _launchURL(data),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text("Open URL"),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(60),
                          ),
                        ),
                      if (type == "contact")
                        ElevatedButton.icon(
                          onPressed: () => _saveContact(data),
                          icon: const Icon(Icons.save),
                          label: const Text("Save Contact"),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(60),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Share.share(data);
                      },
                      icon: const Icon(Icons.share),
                      label: const Text("Share"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        scannerController.start();
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text("Scan Again"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _saveContact(String vcardData) async {
    final lines = vcardData.split("\n");
    String? name, phone, email;
    for (var line in lines) {
      if (line.startsWith("FN:")) name = line.substring(3);
      if (line.startsWith("TEL:"))
        phone = line.substring(4); // "TEL:" is 4 chars
      if (line.startsWith("EMAIL:"))
        email = line.substring(6); // "EMAIL:" is 6 chars
    }

    if (await FlutterContacts.requestPermission()) {
      final contact = Contact()
        ..name.first = name ?? ""
        ..phones = phone != null ? [Phone(phone)] : []
        ..emails = email != null ? [Email(email)] : [];

      await contact.insert();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contact saved successfully")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        elevation: 0,
        title: const Text("QR Code Scanner"),
      ),
      body: hasPermission
          ? MobileScanner(
              controller: scannerController,
              onDetect: (barcodeCapture) {
                final barcode = barcodeCapture.barcodes.first;
                _processScannedData(barcode.rawValue);
              },
            )
          : const Center(
              child: Text(
                "Camera permission not granted",
                style: TextStyle(color: Colors.white),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(
          isFlashOn ? Icons.flash_on : Icons.flash_off,
          color: Colors.indigo,
        ),
        onPressed: () {
          setState(() {
            isFlashOn = !isFlashOn;
          });
          scannerController.toggleTorch();
        },
      ),
    );
  }
}
