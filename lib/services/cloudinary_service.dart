import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'djlroyjjs';
  static const String uploadPreset = 'medvault_upload';

  /// Uploads the image and returns a map containing both the secure URL and public ID.
  /// If [onProgress] is provided, upload progress (0.0 to 1.0) is reported.
  static Future<Map<String, dynamic>?> uploadImage(
      File file, {
        Function(double progress)? onProgress,
      }) async {
    final uploadUrl = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    try {
      final request = http.MultipartRequest('POST', uploadUrl)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();

      http.Response response;
      if (onProgress != null) {
        // Manually track progress.
        final totalBytes = streamedResponse.contentLength ?? 0;
        int bytesTransferred = 0;
        final responseBytes = <int>[];

        await for (final chunk in streamedResponse.stream) {
          responseBytes.addAll(chunk);
          bytesTransferred += chunk.length;
          if (totalBytes > 0) {
            onProgress(bytesTransferred / totalBytes);
          }
        }
        final responseBody = utf8.decode(responseBytes);
        response = http.Response(responseBody, streamedResponse.statusCode);
      } else {
        // If no progress tracking is needed, use a simpler approach.
        response = await http.Response.fromStream(streamedResponse);
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'url': data['secure_url'],
          'public_id': data['public_id'],
        };
      } else {
        print("❌ Upload failed: ${response.statusCode}");
        print("❌ Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Exception during upload: $e");
      return null;
    }
  }
}
