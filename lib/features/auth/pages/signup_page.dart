import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _signup(BuildContext context) async {
    if (_passwordController.text != _confirmController.text) {
      setState(() { _error = 'Passwords do not match'; });
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (context.mounted) context.go('/home');
    } catch (e) {
      setState(() { _error = 'Registration failed'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Icon(Icons.person_add_alt_1, size: 100, color: Color(0xFFFF6B35)),
              ),
              const SizedBox(height: 32),
              const Text(
                'Sign up',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Create your account below',
                style: TextStyle(fontSize: 17, color: Color(0xFF757575)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isLoading ? null : () => _signup(context),
                  child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Sign up', style: TextStyle(fontSize: 22, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: TextStyle(color: Color(0xFF757575))),
                  GestureDetector(
                    onTap: () {
                      context.go('/login');
                    },
                    child: const Text('Log in', style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
