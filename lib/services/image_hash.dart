import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Hex-encoded SHA-256 digest of raw image bytes.
String sha256Hex(Uint8List bytes) => sha256.convert(bytes).toString();
