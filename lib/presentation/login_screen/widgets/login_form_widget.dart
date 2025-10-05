import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/design_tokens.dart';

class LoginFormWidget extends StatefulWidget {
  final Function(String email, String password) onLogin;
  final bool isLoading;

  const LoginFormWidget({
    Key? key,
    required this.onLogin,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _isValidEmail(_emailController.text);

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    if (!_isValidEmail(value)) {
      return 'Email inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() == true && _isFormValid) {
      widget.onLogin(_emailController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantics = context.semanticColors;
    final textStyles = Theme.of(context).textTheme;
    final borderRadius = BorderRadius.circular(2.w);

    OutlineInputBorder outline(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: color, width: width),
        );

    InputDecoration decoration({
      required String label,
      required String hint,
      required Widget prefixIcon,
      Widget? suffixIcon,
    }) {
      final borderColor = colors.outlineVariant.withValues(alpha: 0.5);
      return InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: outline(borderColor),
        enabledBorder: outline(borderColor),
        focusedBorder: outline(colors.primary, 2),
        errorBorder: outline(colors.error),
        focusedErrorBorder: outline(colors.error, 2),
        fillColor: colors.surfaceContainerHigh,
        filled: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 2.h,
        ),
      );
    }

    Widget icon(String name) => Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: name,
            color: colors.onSurfaceVariant,
            size: 5.w,
          ),
        );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: textStyles.bodyLarge,
            decoration: decoration(
              label: 'Email',
              hint: 'Digite seu email',
              prefixIcon: icon('email'),
            ),
            validator: _validateEmail,
          ),
          SizedBox(height: 2.h),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            style: textStyles.bodyLarge,
            decoration: decoration(
              label: 'Senha',
              hint: 'Digite sua senha',
              prefixIcon: icon('lock'),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: _isPasswordVisible
                        ? 'visibility'
                        : 'visibility_off',
                    color: colors.onSurfaceVariant,
                    size: 5.w,
                  ),
                ),
              ),
            ),
            validator: _validatePassword,
            onFieldSubmitted: (_) => _handleLogin(),
          ),
          SizedBox(height: 1.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Funcionalidade em desenvolvimento'),
                    backgroundColor: semantics.warning,
                  ),
                );
              },
              child: Text(
                'Esqueci minha senha?',
                style: textStyles.bodyMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed:
                  _isFormValid && !widget.isLoading ? _handleLogin : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isFormValid ? colors.primary : colors.outlineVariant,
                foregroundColor: colors.onPrimary,
                disabledBackgroundColor:
                    colors.outlineVariant.withValues(alpha: 0.4),
                disabledForegroundColor: colors.onSurfaceVariant,
                elevation: _isFormValid ? 2 : 0,
                shadowColor: colors.shadow,
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius,
                ),
              ),
              child: widget.isLoading
                  ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      'Entrar',
                      style: textStyles.labelLarge?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.onPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

}
