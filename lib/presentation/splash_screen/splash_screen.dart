import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/initialization_service.dart';
import './widgets/loading_indicator_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showLoadingIndicator = false;
  // removed unused: _initializationComplete
  String? _errorMessage;
  // ignore: unused_field
  InitializationResult? _initResult;

  @override
  void initState() {
    super.initState();
    _hideStatusBar();
    _startInitialization();
  }

  void _hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  void _restoreStatusBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  Future<void> _startInitialization() async {
    try {
      // Start logo animation first
      await Future.delayed(const Duration(milliseconds: 500));

      // Show loading indicator after logo animation starts
      if (mounted) {
        setState(() {
          _showLoadingIndicator = true;
        });
      }

      // Check for force update
      final bool requiresUpdate =
          await InitializationService.checkForceUpdate();
      if (requiresUpdate) {
        _showForceUpdateDialog();
        return;
      }

      // Initialize app services
      final result = await InitializationService.initialize();

      if (mounted) {
        setState(() {
          _initResult = result;
          // flag not used in UI
          if (!result.success) {
            _errorMessage = result.error;
          }
        });
      }

      // Wait minimum splash time for better UX
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted && result.success) {
        _navigateToNextScreen(result.nextRoute);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)?.splashUnexpectedError ?? 'Unexpected error during initialization';
          // flag not used in UI
        });
      }
    }
  }

  void _navigateToNextScreen(String route) {
    _restoreStatusBar();

    // Handle deep links or stored intents here if needed
    Navigator.pushReplacementNamed(context, route);
  }

  void _showForceUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryBackgroundDark,
        title: Text(
          AppLocalizations.of(context)?.splashForceUpdateTitle ?? 'Update Required',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)?.splashForceUpdateBody ?? 'A new version of NutriTracker is available. Please update the app to continue.',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // In real implementation, this would open app store
              SystemNavigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.activeBlue,
            ),
            child: Text(
              AppLocalizations.of(context)?.splashUpdate ?? 'Update',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _retryInitialization() {
    setState(() {
      _errorMessage = null;
      _showLoadingIndicator = false;
    });
    _startInitialization();
  }

  @override
  void dispose() {
    _restoreStatusBar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundDark,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: AnimatedLogoWidget(
                  onAnimationComplete: () {
                    // Logo animation completed
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: _buildBottomSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    if (_errorMessage != null) {
      return _buildErrorSection();
    }

    // Make the bottom area resilient to small heights to avoid overflow
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing =
            math.max(8.0, math.min(4.h, constraints.maxHeight * 0.2));
        final content = Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingIndicatorWidget(
              isVisible: _showLoadingIndicator,
            ),
            SizedBox(height: spacing),
            _buildVersionInfo(),
          ],
        );

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: content),
          ),
        );
      },
    );
  }

  Widget _buildErrorSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconWidget(
          iconName: 'error_outline',
          color: AppTheme.errorRed,
          size: 6.w,
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            _errorMessage ?? (AppLocalizations.of(context)?.splashUnknownError ?? 'Unknown error'),
            textAlign: TextAlign.center,
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 11.sp,
            ),
          ),
        ),
        SizedBox(height: 3.h),
        ElevatedButton(
          onPressed: _retryInitialization,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.activeBlue,
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 1.5.h,
            ),
          ),
          child: Text(
            AppLocalizations.of(context)?.splashRetry ?? 'Try Again',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        Text(
          'NutriTracker',
          style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.textSecondary.withValues(alpha: 0.7),
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          AppLocalizations.of(context)?.versionLabel('1.0.0') ?? 'Version 1.0.0',
          style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
            fontSize: 9.sp,
          ),
        ),
      ],
    );
  }
}
