import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class EncryptionController extends GetxController {
  final TextEditingController inputController = TextEditingController();
  final TextEditingController secretKeyController = TextEditingController();
  final TextEditingController ivController = TextEditingController();

  // Reactive variables
  var encryptedText = ''.obs;
  var decryptedText = ''.obs;
  var secretKeyDisplay = ''.obs;
  var qrTransparent = false.obs;
  var ivBase64 = ''.obs;

  @override
  void onInit() {
    super.onInit();
    generateSecretKey();
  }

  void generateSecretKey() {
    // Generate 32 random bytes for a 256-bit key
    final keyBytes = Uint8List.fromList(
        List<int>.generate(32, (_) => Random.secure().nextInt(256)));

    // Generate random IV
    final ivBytes = Uint8List.fromList(
        List<int>.generate(16, (_) => Random.secure().nextInt(256)));

    // Store both as base64
    secretKeyDisplay.value = base64Encode(keyBytes);
    ivBase64.value = base64Encode(ivBytes);

    // Update the text field
    secretKeyController.text = secretKeyDisplay.value;
    ivController.text = ivBase64.value;
  }

  void encryptText(BuildContext context) {
    FocusScope.of(context).unfocus();

    final inputText = inputController.text;
    if (inputText.isEmpty) {
      Get.showSnackbar(GetSnackBar(
        title: 'Error',
        message: 'Please enter text to encrypt.',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ));
      return;
    }

    try {
      // Get current key and IV
      final keyBytes = base64Decode(secretKeyController.text);
      final ivBytes = base64Decode(ivBase64.value);

      // Create key and IV objects
      final key = encrypt.Key(keyBytes);
      final iv = encrypt.IV(ivBytes);

      // Create encrypter with CBC mode
      final encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

      // Perform encryption
      final encrypted = encrypter.encrypt(inputText, iv: iv);

      // Store results
      encryptedText.value = encrypted.base64;
      secretKeyDisplay.value = secretKeyController.text;

      // Clear decrypted text when encrypting new content
      decryptedText.value = '';
    } catch (e) {
      printInfo(info: "Encryption error: $e");
      Get.showSnackbar(GetSnackBar(
        title: 'Error',
        message: 'Encryption failed: ${e.toString()}',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  enteredIV(value) {
    ivBase64.value = value;
  }

  void decryptText(BuildContext context) {
    FocusScope.of(context).unfocus();

    final cipherText = encryptedText.value.isNotEmpty
        ? encryptedText.value
        : inputController.text;

    if (cipherText.isEmpty) {
      Get.showSnackbar(GetSnackBar(
        title: 'Error',
        message: 'No encrypted text available.',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ));
      return;
    }

    try {
      // Get current key and IV
      final keyBytes = base64Decode(secretKeyController.text);
      final ivBytes = base64Decode(ivBase64.value);

      // Create key and IV objects
      final key = encrypt.Key(keyBytes);
      final iv = encrypt.IV(ivBytes);

      // Create encrypter with CBC mode
      final encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

      // Perform decryption
      final decrypted = encrypter.decrypt64(cipherText, iv: iv);

      // Store result
      decryptedText.value = decrypted;
    } catch (e) {
      printInfo(info: "Decryption error: $e");
      Get.showSnackbar(GetSnackBar(
        title: 'Error',
        message: 'Decryption failed: ${e.toString()}',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void resetAll() {
    inputController.clear();
    encryptedText.value = '';
    decryptedText.value = '';
    generateSecretKey();
  }

  void copySecretKey() {
    Clipboard.setData(ClipboardData(text: secretKeyDisplay.value));
    Get.showSnackbar(GetSnackBar(
      title: 'Copied',
      message: 'Secret key copied to clipboard.',
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }

  void copyAll() {
    final data =
        'Encrypted: ${encryptedText.value}\nDecrypted: ${decryptedText.value}\nSecret key: ${secretKeyDisplay.value}\nIV: ${ivBase64.value}';
    Clipboard.setData(ClipboardData(text: data));
    Get.showSnackbar(GetSnackBar(
      title: 'Copied',
      message: 'All encryption data copied to clipboard.',
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }

  void copyEncryptedText() {
    Clipboard.setData(ClipboardData(text: encryptedText.value));
    Get.showSnackbar(GetSnackBar(
      title: 'Copied',
      message: 'Encrypted text copied to clipboard.',
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }

  void toggleQRBackground() {
    qrTransparent.value = !qrTransparent.value;
  }
}
