import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/cloudinary_service.dart';
import '../services/firestore_service.dart';

class CameraUploadScreen extends StatefulWidget {
  final String docType;

  const CameraUploadScreen({super.key, required this.docType});

  @override
  State<CameraUploadScreen> createState() => _CameraUploadScreenState();
}

class _CameraUploadScreenState extends State<CameraUploadScreen> {
  bool isUploading = false;
  double uploadProgress = 0.0;
  String? uploadedFileName;

  Future<void> captureFromCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);

    if (picked != null) {
      // Convert the picked file path into a File
      File file = File(picked.path);

      setState(() {
        isUploading = true;
        uploadProgress = 0.0;
        uploadedFileName = file.path.split('/').last;
      });

      // Call your Cloudinary upload service
      final result = await CloudinaryService.uploadImage(
        file,
        onProgress: (progress) {
          // progress is a double (0.0 to 1.0)
          setState(() => uploadProgress = progress);
        },
      );

      // If the upload is successful, save data to Firestore
      if (result != null) {
        await FirestoreService.saveUploadedDoc(
          url: result['url'],
          docType: widget.docType,
          patientName: 'Hardik',
          age: 22, // Must be int
          publicId: result['public_id'],
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Uploaded & saved: $uploadedFileName')),
        );
      } else {
        // If upload fails
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Upload failed')),
        );
      }

      setState(() {
        isUploading = false;
        uploadProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload ${widget.docType} via Camera'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isUploading && uploadedFileName != null
            ? _fileItem(name: uploadedFileName!)
            : const Center(child: Text('Tap "+" to open camera')),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: captureFromCamera,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _fileItem({required String name}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.camera_alt_outlined, color: Colors.black),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: uploadProgress >= 1.0
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LinearProgressIndicator(
            value: uploadProgress,
            backgroundColor: Colors.grey.shade300,
            color: Colors.green,
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${(uploadProgress * 100).toInt()}%',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
