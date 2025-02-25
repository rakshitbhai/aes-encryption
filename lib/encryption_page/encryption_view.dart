



import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:end/encryption_page/encryption_controller.dart';
import 'package:end/theme/theme_controller.dart';
import 'package:end/utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EncryptionScreen extends StatelessWidget {
  const EncryptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EncryptionController controller = Get.put(EncryptionController());
    final ThemeController themeController = Get.find<ThemeController>();
    // Global key for capturing the QR code widget.
    final GlobalKey qrKey = GlobalKey();

    Future<void> captureAndDownloadQRCode() async {
      try {
        RenderRepaintBoundary boundary =
            qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final buffer = byteData.buffer;
          final base64Image = base64Encode(Uint8List.view(buffer));
          html.AnchorElement(href: 'data:image/png;base64,$base64Image')
            ..setAttribute(
                'download',
                controller.qrTransparent.value
                    ? 'qr_code_transparent.png'
                    : 'qr_code.png')
            ..click();
        }
      } catch (e) {
        Get.showSnackbar(GetSnackBar(
          title: 'Error',
          message: 'Failed to download QR Code: $e',
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AES Encryption'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => themeController.toggleTheme(),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: controller.inputController,
                decoration: const InputDecoration(
                  labelText: 'Enter text',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => controller.encryptText(context),
                    child: const Text('Encrypt'),
                  ),
                  beautifulIconButton(
                    icon: Icons.refresh,
                    tooltip: 'Reset',
                    onPressed: () {
                      // Call your reset functionality here.
                      controller.resetAll();
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => controller.decryptText(context),
                    child: const Text('Decrypt'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: SelectableText(
                          'Encrypted: ${controller.encryptedText.value}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: controller.copyEncryptedText,
                      )
                    ],
                  )),
              const SizedBox(height: 10),
              Obx(() => Text('Decrypted: ${controller.decryptedText.value}',
                  textAlign: TextAlign.center)),
              const SizedBox(height: 20),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: SelectableText(
                          'Secret Key: ${controller.secretKeyDisplay.value}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: controller.copySecretKey,
                      )
                    ],
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: controller.copyAll,
                    child: const Text('Copy All'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Toggle for QR Code background type.
              Obx(() => SwitchListTile(
                    title: const Text('Transparent QR Background'),
                    value: controller.qrTransparent.value,
                    onChanged: (value) => controller.toggleQRBackground(),
                  )),
              const SizedBox(height: 20),
              // Display QR Code if encrypted text exists.
              Obx(() {
                if (controller.encryptedText.value.isEmpty) {
                  return const Text(
                      'QR Code will appear here once text is encrypted.');
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RepaintBoundary(
                        key: qrKey,
                        child: QrImageView(
                          data: controller.encryptedText.value,
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: controller.qrTransparent.value
                              ? Colors.transparent
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: captureAndDownloadQRCode,
                        child: const Icon(Icons.download),
                      ),
                    ],
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
