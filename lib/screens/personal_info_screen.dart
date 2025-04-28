import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();

  bool _loading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _emailController.text = data['email'] ?? '';
        _dobController.text = data['dob'] ?? '';
      }
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveUserInfo() async {
    if (_userId == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'dob': _dobController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Information updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating info: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = DateTime.tryParse(_dobController.text) ?? DateTime(1990);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
      setState(() {
        _dobController.text = formattedDate;
      });
    }
  }

  Widget _buildField(String label, TextEditingController controller, {bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.edit),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildField('First Name', _firstNameController),
            _buildField('Last Name', _lastNameController),
            _buildField('Email Address', _emailController),
            _buildField(
              'Date of Birth',
              _dobController,
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveUserInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E47FF),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save Changes'),
            )
          ],
        ),
      ),
    );
  }
}
