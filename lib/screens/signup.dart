import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../error_dialog.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  late BuildContext _scaffoldContext;

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      FocusScope.of(context).unfocus();

      try {
        await _authService.signUp(_email, _password);
        _navigateToPersonalInventoryForm();
      } catch (e) {
        showDialog(
          context: _scaffoldContext,
          builder: (context) => ErrorDialog(message: e.toString()),
        );
      }
    }
  }

  void _navigateToPersonalInventoryForm() {
    Navigator.pushNamedAndRemoveUntil(
        _scaffoldContext, '/personal_inventory_form', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldContext = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter your email' : null,
                onSaved: (value) => _email = value?.trim() ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter your password'
                    : null,
                onSaved: (value) => _password = value?.trim() ?? '',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Sign Up'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login_screen'),
                child: const Text('Already have an account? Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
