import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class RegisterLinkWidget extends StatelessWidget {
  const RegisterLinkWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Novo usuário? ',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () {
              // Handle registration navigation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tela de cadastro em desenvolvimento'),
                  backgroundColor: AppTheme.warningAmber,
                ),
              );
            },
            child: Text(
              'Cadastre-se',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.activeBlue,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.activeBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
