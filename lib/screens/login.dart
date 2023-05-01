import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../error_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
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
        await _authService.signIn(_email, _password);
        _navigateToMainScreen();
      } catch (e) {
        showDialog(
          context: _scaffoldContext,
          builder: (context) => ErrorDialog(message: e.toString()),
        );
      }
    }
  }

  void _navigateToMainScreen() {
    Navigator.pushNamedAndRemoveUntil(
        _scaffoldContext, '/main_screen', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldContext = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/signup_screen'),
                child: const Text('Don\'t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
