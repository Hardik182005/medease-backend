import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/cloudinary_service.dart';
import '../services/firestore_service.dart';

class GalleryUploadScreen extends StatefulWidget {
  final String docType;

  const GalleryUploadScreen({super.key, required this.docType});

  @override
  State<GalleryUploadScreen> createState() => _GalleryUploadScreenState();
}

class _GalleryUploadScreenState extends State<GalleryUploadScreen> {
  bool isUploading = false;
  double uploadProgress = 0.0;
  String? uploadedFileName;

  Future<void> pickFromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      File file = File(picked.path);

      setState(() {
        isUploading = true;
        uploadProgress = 0.0;
        uploadedFileName = file.path.split('/').last;
      });

      final result = await CloudinaryService.uploadImage(
        file,
        onProgress: (progress) {
          setState(() => uploadProgress = progress);
        },
      );

      if (result != null) {
        await FirestoreService.saveUploadedDoc(
          url: result['url'],
          docType: widget.docType,
          patientName: 'Hardik', // replace with real input later
          age: 22, // ✅ fixed: must be int
          publicId: result['public_id'],
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
        title: Text('Upload ${widget.docType} via Gallery'),
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
            ? _fileProgressItem(name: uploadedFileName!, progress: uploadProgress)
            : const Center(child: Text('Tap "+" to select an image from gallery')),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: pickFromGallery,
      ),
    );
  }

  Widget _fileProgressItem({required String name, required double progress}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.image, color: Colors.black),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: progress >= 1.0 ? const Icon(Icons.check_circle, color: Colors.green) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            color: Colors.blue,
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('${(progress * 100).toInt()}%',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
      ],
    );
  }
}
