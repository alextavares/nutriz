import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/app_logo_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/register_link_widget.dart';
import './widgets/social_login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // Mock credentials for testing
  final Map<String, String> _mockCredentials = {
    'admin@nutritracker.com': 'admin123',
    'user@nutritracker.com': 'user123',
    'demo@nutritracker.com': 'demo123',
  };

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Check mock credentials
      if (_mockCredentials.containsKey(email) &&
          _mockCredentials[email] == password) {
        // Success haptic feedback
        HapticFeedback.lightImpact();

        // Show success message
        if (mounted) {
          // Persist authenticated session
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_authenticated', true);
          await prefs.setString('user_email', email);
          await prefs.setBool('premium_status', false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Login realizado com sucesso!'),
              backgroundColor: AppTheme.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
          );

          // Navigate to dashboard
          Navigator.pushReplacementNamed(context, '/daily-tracking-dashboard');
        }
      } else {
        // Error haptic feedback
        HapticFeedback.mediumImpact();

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Credenciais inválidas. Verifique seu email e senha.'),
              backgroundColor: AppTheme.errorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Network error handling
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro de rede. Verifique sua conexão.'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate social login process
      await Future.delayed(const Duration(seconds: 1));

      // Success haptic feedback
      HapticFeedback.lightImpact();

      if (mounted) {
        // Persist authenticated session for social login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_authenticated', true);
        await prefs.setString('user_email', 'social@$provider');
        await prefs.setBool('premium_status', false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login com $provider realizado com sucesso!'),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
        );

        // Navigate to dashboard
        Navigator.pushReplacementNamed(context, '/daily-tracking-dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no login com $provider'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundDark,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 8.h),

                      // App Logo
                      const AppLogoWidget(),

                      SizedBox(height: 6.h),

                      // Login Form
                      LoginFormWidget(
                        onLogin: _handleLogin,
                        isLoading: _isLoading,
                      ),

                      SizedBox(height: 4.h),

                      // Social Login Options
                      SocialLoginWidget(
                        onSocialLogin: _handleSocialLogin,
                        isLoading: _isLoading,
                      ),

                      const Spacer(),

                      // Register Link
                      const RegisterLinkWidget(),

                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
