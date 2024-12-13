import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.signInWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );
        Navigator.pushReplacementNamed(context, '/map');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
      Navigator.pushReplacementNamed(context, '/map');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Enter an email' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Enter a password' : null,
                  ),
                  SizedBox(height: 24),
                  if (_isLoading)
                    CircularProgressIndicator()
                  else ...[
                    ElevatedButton(
                      onPressed: _login,
                      child: Text('Login'),
                    ),
                    SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _signInWithGoogle,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.g_mobiledata, size: 24),
                            SizedBox(width: 8),
                            Text('Sign in with Google'),
                          ],
                        ),
                      ),
                    ),
                  ],
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: Text('Create Account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 