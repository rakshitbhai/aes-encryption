import 'dart:convert';
import 'dart:math';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class EncryptionController extends GetxController {
  final TextEditingController inputController = TextEditingController();
  late encrypt.Key key;
  late encrypt.Encrypter encrypter;
  final encrypt.IV iv = encrypt.IV.fromLength(16);

  // Reactive variables for encrypted/decrypted text and secret key display.
  var encryptedText = ''.obs;
  var decryptedText = ''.obs;
  var secretKeyDisplay = ''.obs;

  // Reactive boolean for QR background (true means transparent)
  var qrTransparent = false.obs;

  @override
  void onInit() {
    super.onInit();
    generateSecretKey();
  }

  generateSecretKey() {
    // Generate 32 random bytes for a 256-bit key.
    final keyBytes = Uint8List.fromList(
        List<int>.generate(32, (_) => Random.secure().nextInt(256)));
    key = encrypt.Key(keyBytes);
    // Use AES with SIC mode (similar to CTR).
    encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.sic));
    secretKeyDisplay.value = base64Encode(keyBytes);
  }

  void encryptText(BuildContext context) {
    FocusScope.of(context).unfocus();
    final text = inputController.text;
    if (text.isEmpty) {
      Get.showSnackbar(GetSnackBar(
        title: 'Error',
        message: 'Please enter text to encrypt.',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ));
      return;
    }
    try {
      final encrypted = encrypter.encrypt(text, iv: iv);
      encryptedText.value = encrypted.base64;
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        title: 'Error',
        message: 'Encryption failed: $e',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void decryptText(BuildContext context) {
    FocusScope.of(context).unfocus();
    final cipherText = encryptedText.value;
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
      final decrypted = encrypter.decrypt64(cipherText, iv: iv);
      decryptedText.value = decrypted;
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        title: 'Error',
        message: 'Decryption failed: $e',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void resetAll() {
    // Clear input and result fields.
    inputController.clear();
    encryptedText.value = '';
    decryptedText.value = '';
    // Update the secret key display.
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
        'Encrypted: ${encryptedText.value}\nDecrypted: ${decryptedText.value}\nSecretkey: ${secretKeyDisplay.value}';
    Clipboard.setData(ClipboardData(text: data));
    Get.showSnackbar(GetSnackBar(
      title: 'Copied',
      message: 'Encrypted and Decrypted texts copied to clipboard.',
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
