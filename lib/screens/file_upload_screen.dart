import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'upload_documents_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class FileUploadScreen extends StatelessWidget {
  final String docType;

  const FileUploadScreen({super.key, required this.docType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Uploaded $docType Files'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('uploaded_documents')
            .where('docType', isEqualTo: docType)
            .orderBy('uploadedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading documents'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No documents uploaded yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final url = data['url'] ?? '';
              final name = data['patientName'] ?? 'Unknown';
              final age = data['age'] ?? 'N/A';

              return _fileTile(
                name: name,
                age: age,
                url: url,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => UploadDocumentsScreen(docType: docType),
            ),
          );
        },
      ),
    );
  }

  Widget _fileTile({
    required String name,
    required String age,
    required String url,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.black),
        title: Text('$name (Age: $age)', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Text("Tap to view"),
        trailing: const Icon(Icons.open_in_new),
        onTap: () async {
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }
}
