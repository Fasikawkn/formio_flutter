import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageCompressionService {
  static const int _defaultMaxFileSizeKB = 1024; // 1MB

  /// Compress image if needed. Returns null if image is too large after 2 attempts
  Future<String?> compressImageIfNeeded(
    String imagePath, {
    int quality = 85,
    int? maxFileSizeKB,
  }) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Image file not found');
    }

    final fileSize = await file.length();
    final maxSizeBytes = (maxFileSizeKB ?? _defaultMaxFileSizeKB) * 1024;

    // Return original if under size limit
    if (fileSize <= maxSizeBytes) {
      return imagePath;
    }

    // Attempt compression
    return await _compressImage(imagePath,
        quality: quality, maxFileSizeBytes: maxSizeBytes);
  }

  /// Compress multiple images. Returns only successfully compressed images
  Future<List<String>> compressImagesIfNeeded(
    List<String> imagePaths, {
    int quality = 85,
    int? maxFileSizeKB,
  }) async {
    final compressedPaths = <String>[];

    for (final imagePath in imagePaths) {
      final compressedPath = await compressImageIfNeeded(
        imagePath,
        quality: quality,
        maxFileSizeKB: maxFileSizeKB,
      );
      if (compressedPath != null) {
        compressedPaths.add(compressedPath);
      }
    }

    return compressedPaths;
  }

  /// Internal compression method - tries twice, returns null if still too large
  Future<String?> _compressImage(String imagePath,
      {int quality = 85, required int maxFileSizeBytes}) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = path.basename(imagePath);
    final fileExtension = path.extension(fileName).toLowerCase();
    final nameWithoutExtension = path.basenameWithoutExtension(fileName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final targetPath = path.join(
      tempDir.path,
      '${nameWithoutExtension}_compressed_$timestamp$fileExtension',
    );

    // Determine image format
    CompressFormat format = CompressFormat.jpeg;
    if (fileExtension == '.png') format = CompressFormat.png;
    if (fileExtension == '.heic') format = CompressFormat.heic;
    if (fileExtension == '.webp') format = CompressFormat.webp;

    // Attempt 1: 85% quality
    final result1 = await FlutterImageCompress.compressAndGetFile(
      imagePath,
      targetPath,
      quality: quality,
      format: format,
      minWidth: 1920,
      minHeight: 1920,
    );

    if (result1 != null) {
      final size1 = await result1.length();
      if (size1 <= maxFileSizeBytes) {
        return result1.path; // Success on first attempt
      }
      await File(result1.path).delete(); // Delete oversized file
    }

    // Attempt 2: 50% quality
    final targetPath2 = path.join(
      tempDir.path,
      '${nameWithoutExtension}_compressed_${timestamp}_2$fileExtension',
    );
    final result2 = await FlutterImageCompress.compressAndGetFile(
      imagePath,
      targetPath2,
      quality: 50,
      format: format,
      minWidth: 1920,
      minHeight: 1920,
    );

    if (result2 != null) {
      final size2 = await result2.length();
      if (size2 <= maxFileSizeBytes) {
        return result2.path; // Success on second attempt
      }
      await File(result2.path).delete(); // Delete oversized file
    }

    return null; // Failed after 2 attempts
  }
}
