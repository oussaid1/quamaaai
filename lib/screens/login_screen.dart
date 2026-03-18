import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../l10n/translations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.indigo,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Q',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 40)),
              ),
              const SizedBox(height: 24),
              Text(
                context.tr('app_name'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your Smart Home Assistant',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 48),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    try {
                      await appState.signInWithGoogle();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login failed: $e')),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                    height: 24,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.login),
                  ),
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.textPrimary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppTheme.border),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
