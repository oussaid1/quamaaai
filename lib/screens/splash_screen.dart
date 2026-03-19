import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final appState = Provider.of<AppState>(context, listen: false);
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => appState.user == null ? const LoginScreen() : const MainShell(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9F6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            // Main Logo Box
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(48),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'قواما',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto', // Fallback
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'بَيْنَ ذَٰلِكَ قَوَامًا',
                      style: TextStyle(
                        color: Color(0xFFFBBF24), // Amber color
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Text below logo
            const Text(
              'قواما',
              style: TextStyle(
                color: Color(0xFF064E3B), // Dark emerald
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'وَكَانَ بَيْنَ ذَٰلِكَ قَوَامًا',
              style: TextStyle(
                color: Color(0xFF065F46),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(flex: 2),
            // Bottom dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(true),
                const SizedBox(width: 8),
                _buildDot(false),
                const SizedBox(width: 8),
                _buildDot(false, opacity: 0.3),
              ],
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool active, {double opacity = 1.0}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(active ? 1.0 : (opacity)),
        shape: BoxShape.circle,
      ),
    );
  }
}
