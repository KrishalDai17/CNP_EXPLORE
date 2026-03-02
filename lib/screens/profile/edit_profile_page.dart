import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final String fullName;
  final String dob;
  final String age;
  final String gender;
  final String nationality;
  final String email;
  final String contact;

  const EditProfilePage({
    super.key,
    required this.fullName,
    required this.dob,
    required this.age,
    required this.gender,
    required this.nationality,
    required this.email,
    required this.contact,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController fullNameController;
  late TextEditingController dobController;
  late TextEditingController ageController;
  late TextEditingController emailController;
  late TextEditingController contactController;

  String? selectedGender;
  String? selectedNationality;

  final List<String> genderOptions = const ["Male", "Female", "Other"];
  final List<String> nationalityOptions = const [
    "Nepalese",
    "Indian",
    "American",
    "British",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.fullName);
    dobController = TextEditingController(text: widget.dob);
    ageController = TextEditingController(text: widget.age);
    emailController = TextEditingController(text: widget.email);
    contactController = TextEditingController(text: widget.contact);
    
    // Trim values to prevent "Red Screen" errors from hidden spaces in Firebase
    selectedGender = widget.gender.trim();
    selectedNationality = widget.nationality.trim();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    dobController.dispose();
    ageController.dispose();
    emailController.dispose();
    contactController.dispose();
    super.dispose();
  }

  Future<void> pickDateOfBirth() async {
    DateTime initialDate = DateTime.tryParse(dobController.text) ?? DateTime(2000);

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dobController.text = DateFormat('yyyy-MM-dd').format(picked);

      final today = DateTime.now();
      int age = today.year - picked.year;
      if (today.month < picked.month || (today.month == picked.month && today.day < picked.day)) {
        age--;
      }
      ageController.text = age.toString();
      setState(() {});
    }
  }

  Future<void> saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // 1. Update Name in Firebase Auth
          await user.updateDisplayName(fullNameController.text.trim());

          // 2. Update All details in Firestore
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'fullName': fullNameController.text.trim(),
            'dob': dobController.text,
            'age': ageController.text,
            'gender': selectedGender,
            'nationality': selectedNationality,
            'contact': contactController.text.trim(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully!')),
            );
            Navigator.pop(context); 
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update failed: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF4FBF26),
                child: Icon(Icons.person, size: 50, color: Colors.black),
              ),
              const SizedBox(height: 16),

              _textField(fullNameController, "Full Name", 'Please enter your full name'),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: pickDateOfBirth,
                      child: AbsorbPointer(
                        child: _textField(dobController, "Date of Birth", 'Select your date of birth'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: ageController,
                      readOnly: true,
                      decoration: _inputStyle("Age"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // FIXED GENDER DROPDOWN
              DropdownButtonFormField<String>(
                value: genderOptions.contains(selectedGender) ? selectedGender : null,
                decoration: _inputStyle("Gender"),
                items: genderOptions
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                validator: (value) => value == null ? 'Please select your gender' : null,
                onChanged: (val) => setState(() => selectedGender = val),
              ),
              const SizedBox(height: 12),

              // FIXED NATIONALITY DROPDOWN
              DropdownButtonFormField<String>(
                value: nationalityOptions.contains(selectedNationality) ? selectedNationality : null,
                decoration: _inputStyle("Nationality"),
                items: nationalityOptions
                    .map((nat) => DropdownMenuItem(value: nat, child: Text(nat)))
                    .toList(),
                validator: (value) => value == null ? 'Please select your nationality' : null,
                onChanged: (val) => setState(() => selectedNationality = val),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: emailController,
                readOnly: true, // Email remains permanent
                decoration: _inputStyle("Email"),
              ),
              const SizedBox(height: 12),

              _textField(contactController, "Contact No", 'Enter a valid contact number', phone: true),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FBF26),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text('Save Changes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFEFF5EB),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
  );

  TextFormField _textField(TextEditingController controller, String label, String error, {bool phone = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: phone ? TextInputType.phone : TextInputType.text,
      decoration: _inputStyle(label),
      validator: (value) {
        if (value == null || value.isEmpty) return error;
        if (phone && !RegExp(r'^(?:\+977\s\d{10}|\d{10})$').hasMatch(value)) return 'Enter a valid Nepali contact number';
        return null;
      },
    );
  }
}