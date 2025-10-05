import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/design_tokens.dart';
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
    final colors = context.colors;
    final semantics = context.semanticColors;
    setState(() {
      _isLoading = true;
    });

    FocusScope.of(context).unfocus();

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (_mockCredentials.containsKey(email) &&
          _mockCredentials[email] == password) {
        HapticFeedback.lightImpact();

        if (mounted) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_authenticated', true);
          await prefs.setString('user_email', email);
          await prefs.setBool('premium_status', false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Login realizado com sucesso!'),
              backgroundColor: semantics.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
          );

          Navigator.pushReplacementNamed(context, '/daily-tracking-dashboard');
        }
      } else {
        HapticFeedback.mediumImpact();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Credenciais inválidas. Verifique seu email e senha.'),
              backgroundColor: colors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro de rede. Verifique sua conexão.'),
            backgroundColor: colors.error,
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
    final colors = context.colors;
    final semantics = context.semanticColors;
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      HapticFeedback.lightImpact();

      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_authenticated', true);
        await prefs.setString('user_email', 'social@$provider');
        await prefs.setBool('premium_status', false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login com $provider realizado com sucesso!'),
            backgroundColor: semantics.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
        );

        Navigator.pushReplacementNamed(context, '/daily-tracking-dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no login com $provider'),
            backgroundColor: colors.error,
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
    final colors = context.colors;
    final textStyles = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colors.surface,
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
                      const AppLogoWidget(),
                      SizedBox(height: 6.h),
                      LoginFormWidget(
                        onLogin: _handleLogin,
                        isLoading: _isLoading,
                      ),
                      SizedBox(height: 4.h),
                      SocialLoginWidget(
                        onSocialLogin: _handleSocialLogin,
                        isLoading: _isLoading,
                      ),
                      const Spacer(),
                      RegisterLinkWidget(
                        isLoading: _isLoading,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '© ${DateTime.now().year} NutriTracker. Todos os direitos reservados.',
                        textAlign: TextAlign.center,
                        style: textStyles.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: 3.h),
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
