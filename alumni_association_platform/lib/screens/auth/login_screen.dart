import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../theme/theme_manager.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final user = await FirebaseService.signInWithEmail(email, password);
    if (user == null) {
      setState(() {
        _errorMessage = 'Login failed. Please check your credentials.';
      });
    } else {
      // Navigate to the appropriate dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 20),
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}