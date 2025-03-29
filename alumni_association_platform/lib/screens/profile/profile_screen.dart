import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserModel _user;
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing && _formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // Save to Firestore
                FirebaseService.firestore
                  .collection('users')
                  .doc(user?.uid)
                  .update(_user.toFirestore());
              }
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseService.firestore
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          _user = UserModel.fromFirestore(
            snapshot.data!.data() as Map<String, dynamic>,
            snapshot.data!.id,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Text(_user.name[0]),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: _user.name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    enabled: _isEditing,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => _user = _user.copyWith(name: value!),
                  ),
                  TextFormField(
                    initialValue: _user.email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    enabled: false,
                  ),
                  TextFormField(
                    initialValue: _user.bio,
                    decoration: const InputDecoration(labelText: 'Bio'),
                    enabled: _isEditing,
                    maxLines: 3,
                    onSaved: (value) => _user = _user.copyWith(bio: value),
                  ),
                  if (_user.role == 'alumni') ...[
                    TextFormField(
                      initialValue: _user.company,
                      decoration: const InputDecoration(labelText: 'Company'),
                      enabled: _isEditing,
                      onSaved: (value) => _user = _user.copyWith(company: value),
                    ),
                  ],
                  TextFormField(
                    initialValue: _user.graduationYear,
                    decoration: const InputDecoration(labelText: 'Graduation Year'),
                    enabled: _isEditing,
                    onSaved: (value) => _user = _user.copyWith(graduationYear: value),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}