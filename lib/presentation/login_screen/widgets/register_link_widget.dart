import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/design_tokens.dart';

class RegisterLinkWidget extends StatelessWidget {
  final bool isLoading;

  const RegisterLinkWidget({
    Key? key,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantics = context.semanticColors;
    final textStyles = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Novo usuário? ',
            style: textStyles.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          GestureDetector(
            onTap: isLoading
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Tela de cadastro em desenvolvimento'),
                        backgroundColor: semantics.warning,
                      ),
                    );
                  },
            child: Text(
              'Cadastre-se',
              style: textStyles.bodyMedium?.copyWith(
                color: isLoading
                    ? colors.onSurfaceVariant.withValues(alpha: 0.6)
                    : colors.primary,
                fontWeight: FontWeight.w600,
                decoration: isLoading ? TextDecoration.none : TextDecoration.underline,
                decorationColor: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
