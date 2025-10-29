import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';

import '../../../theme/design_tokens.dart';

class RegisterLinkWidget extends StatelessWidget {
  final bool isLoading;

  const RegisterLinkWidget({
    Key? key,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = context.colors;
    final semantics = context.semanticColors;
    final textStyles = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            t.newUser,
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
                        content: Text(t.registerScreenInDevelopment),
                        backgroundColor: semantics.warning,
                      ),
                    );
                  },
            child: Text(
              t.register,
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
