import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../services/cloudinary_service.dart';
import '../services/firestore_service.dart';

import 'file_upload_screen.dart';
import 'gallery_upload_screen.dart';
import 'camera_upload_screen.dart';
import 'drive_upload_screen.dart';

class UploadDocumentsScreen extends StatefulWidget {
  final String docType;

  const UploadDocumentsScreen({super.key, required this.docType});

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  String selectedName = 'Select Patient';
  String selectedAge = 'Select Age';

  List<String> patientNames = ['Select Patient', 'Hardik', 'Mihir', 'Sneha'];
  List<String> patientAges = ['Select Age', '22', '29', '35'];

  Future<void> pickAndUploadFile() async {
    // Ensure the user selected patient name & age first
    if (selectedName == 'Select Patient' || selectedAge == 'Select Age') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please select patient name and age')),
      );
      return;
    }

    // Pick a file from local storage
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);

      // Now we expect a Map<String, dynamic>? from CloudinaryService
      final uploadResult = await CloudinaryService.uploadImage(file);

      if (uploadResult != null) {
        // Extract the secure URL and public_id from the map
        final secureUrl = uploadResult['url'] as String;
        final publicId = uploadResult['public_id'] as String;

        // Save to Firestore
        await FirestoreService.saveUploadedDoc(
          url: secureUrl,
          docType: widget.docType,
          patientName: selectedName,
          age: int.tryParse(selectedAge) ?? 0, // Convert age to int
          publicId: publicId,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Uploaded & saved: $secureUrl')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Upload failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload ${widget.docType}',
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Select an option to upload ${widget.docType}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildUploadOption(
                  context,
                  label: 'File',
                  image: 'assets/Images/file_image.png',
                  onTap: pickAndUploadFile,
                ),
                _buildUploadOption(
                  context,
                  label: 'Gallery',
                  image: 'assets/Images/gallery_image.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            GalleryUploadScreen(docType: widget.docType),
                      ),
                    );
                  },
                ),
                _buildUploadOption(
                  context,
                  label: 'Camera',
                  image: 'assets/Images/camera_image.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CameraUploadScreen(docType: widget.docType),
                      ),
                    );
                  },
                ),
                _buildUploadOption(
                  context,
                  label: 'Drive',
                  image: 'assets/Images/google_drive.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DriveUploadScreen(docType: widget.docType),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Patient Name and Age',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // -- Patient Name Dropdown --
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade100,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedName,
                        isExpanded: true,
                        items: patientNames.map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedName = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // -- Patient Age Dropdown --
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedAge,
                        isExpanded: true,
                        items: patientAges.map((age) {
                          return DropdownMenuItem(
                            value: age,
                            child: Text(age),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedAge = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption(
      BuildContext context, {
        required String label,
        required String image,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 40),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
