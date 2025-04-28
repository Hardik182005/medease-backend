import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../services/cloudinary_service.dart';
import '../services/firestore_service.dart';

class DriveUploadScreen extends StatefulWidget {
  final String docType;

  const DriveUploadScreen({super.key, required this.docType});

  @override
  State<DriveUploadScreen> createState() => _DriveUploadScreenState();
}

class _DriveUploadScreenState extends State<DriveUploadScreen> {
  bool isUploading = false;
  double uploadProgress = 0.0;
  String? uploadedFileName;

  Future<void> pickDriveFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);

      setState(() {
        isUploading = true;
        uploadProgress = 0.0;
        uploadedFileName = file.path.split('/').last;
      });

      final resultMap = await CloudinaryService.uploadImage(
        file,
        onProgress: (progress) {
          setState(() => uploadProgress = progress);
        },
      );

      if (resultMap != null) {
        await FirestoreService.saveUploadedDoc(
          url: resultMap['url'],
          docType: widget.docType,
          patientName: 'Hardik', // You can make dynamic
          age: 22, // ✅ FIXED: must be int
          publicId: resultMap['public_id'],
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Uploaded & saved: $uploadedFileName')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Upload failed')),
          );
        }
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
        title: Text('Upload ${widget.docType} via Drive'),
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
            : const Center(child: Text('Tap "+" to pick a file from Drive')),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: pickDriveFile,
      ),
    );
  }

  Widget _fileItem({required String name}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.insert_drive_file_outlined, color: Colors.black),
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
