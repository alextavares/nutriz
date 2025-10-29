import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'user_preferences.dart';

/// Service responsible for managing in-app purchases and subscriptions via RevenueCat
///
/// This service handles:
/// - RevenueCat SDK initialization
/// - Product offerings retrieval
/// - Purchase flow
/// - Subscription status verification
/// - Purchase restoration
///
/// Setup required:
/// 1. Create account at https://www.revenuecat.com
/// 2. Configure products in RevenueCat dashboard
/// 3. Link to Google Play Console and App Store Connect
/// 4. Replace API keys in this file
class PurchaseService {
  static const String _revenueCatApiKeyAndroid = 'YOUR_ANDROID_API_KEY_HERE';
  static const String _revenueCatApiKeyIos = 'YOUR_IOS_API_KEY_HERE';

  // Entitlement identifier configured in RevenueCat dashboard
  static const String _proEntitlementId = 'pro';

  static bool _isInitialized = false;

  /// Initialize RevenueCat SDK
  /// Must be called before any other purchase operations
  ///
  /// Returns true if initialization was successful
  static Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Configure RevenueCat with platform-specific API keys
      final configuration = PurchasesConfiguration(
        defaultTargetPlatform == TargetPlatform.android
            ? _revenueCatApiKeyAndroid
            : _revenueCatApiKeyIos,
      );

      await Purchases.configure(configuration);

      // Enable debug logs in development mode
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      _isInitialized = true;

      // Sync subscription status immediately after initialization
      await syncSubscriptionStatus();

      return true;
    } catch (e) {
      debugPrint('❌ PurchaseService initialization failed: $e');
      return false;
    }
  }

  /// Get available subscription offerings from RevenueCat
  ///
  /// Returns list of available packages or empty list if none available
  static Future<List<Package>> getOfferings() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final offerings = await Purchases.getOfferings();

      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages;
      }

      debugPrint('⚠️ No offerings available from RevenueCat');
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching offerings: $e');
      return [];
    }
  }

  /// Purchase a subscription package
  ///
  /// Returns PurchaseResult with success status and optional error message
  static Future<PurchaseResult> purchasePackage(Package package) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final customerInfo = await Purchases.purchasePackage(package);

      // Check if user now has active pro entitlement
      final isPro = customerInfo.entitlements.active.containsKey(_proEntitlementId);

      if (isPro) {
        // Save premium status locally
        final entitlement = customerInfo.entitlements.active[_proEntitlementId]!;
        await UserPreferences.setPremiumStatus(
          true,
          planId: package.identifier,
          purchaseDate: entitlement.latestPurchaseDate != null
              ? DateTime.parse(entitlement.latestPurchaseDate!)
              : DateTime.now(),
        );

        return PurchaseResult(
          success: true,
          isPremium: true,
          message: 'Assinatura ativada com sucesso!',
        );
      } else {
        return PurchaseResult(
          success: false,
          isPremium: false,
          message: 'Compra não confirmada. Tente novamente.',
        );
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      // User cancelled the purchase
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult(
          success: false,
          isPremium: false,
          message: 'Compra cancelada',
        );
      }

      // Network error
      if (errorCode == PurchasesErrorCode.networkError) {
        return PurchaseResult(
          success: false,
          isPremium: false,
          message: 'Erro de conexão. Verifique sua internet.',
        );
      }

      // Payment pending (awaiting approval)
      if (errorCode == PurchasesErrorCode.paymentPendingError) {
        return PurchaseResult(
          success: false,
          isPremium: false,
          message: 'Pagamento pendente de aprovação',
        );
      }

      // Store problem
      if (errorCode == PurchasesErrorCode.storeProblemError) {
        return PurchaseResult(
          success: false,
          isPremium: false,
          message: 'Erro na loja. Tente novamente mais tarde.',
        );
      }

      debugPrint('❌ Purchase error: ${e.code} - ${e.message}');
      return PurchaseResult(
        success: false,
        isPremium: false,
        message: 'Erro ao processar compra: ${e.message}',
      );
    } catch (e) {
      debugPrint('❌ Unexpected purchase error: $e');
      return PurchaseResult(
        success: false,
        isPremium: false,
        message: 'Erro inesperado. Tente novamente.',
      );
    }
  }

  /// Restore previous purchases
  ///
  /// Useful when user reinstalls app or switches devices
  /// Returns PurchaseResult with restored subscription status
  static Future<PurchaseResult> restorePurchases() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final customerInfo = await Purchases.restorePurchases();

      final isPro = customerInfo.entitlements.active.containsKey(_proEntitlementId);

      if (isPro) {
        final entitlement = customerInfo.entitlements.active[_proEntitlementId]!;
        await UserPreferences.setPremiumStatus(
          true,
          planId: entitlement.productIdentifier,
          purchaseDate: entitlement.latestPurchaseDate != null
              ? DateTime.parse(entitlement.latestPurchaseDate!)
              : null,
        );

        return PurchaseResult(
          success: true,
          isPremium: true,
          message: 'Assinatura restaurada com sucesso!',
        );
      } else {
        // No active subscription found
        await UserPreferences.setPremiumStatus(false);

        return PurchaseResult(
          success: true,
          isPremium: false,
          message: 'Nenhuma assinatura ativa encontrada',
        );
      }
    } catch (e) {
      debugPrint('❌ Error restoring purchases: $e');
      return PurchaseResult(
        success: false,
        isPremium: false,
        message: 'Erro ao restaurar compras. Tente novamente.',
      );
    }
  }

  /// Sync subscription status with RevenueCat
  ///
  /// Should be called:
  /// - On app startup
  /// - After coming back from background
  /// - Periodically to ensure status is up-to-date
  static Future<void> syncSubscriptionStatus() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final customerInfo = await Purchases.getCustomerInfo();

      final isPro = customerInfo.entitlements.active.containsKey(_proEntitlementId);

      // Update local storage
      if (isPro) {
        final entitlement = customerInfo.entitlements.active[_proEntitlementId]!;
        await UserPreferences.setPremiumStatus(
          true,
          planId: entitlement.productIdentifier,
          purchaseDate: entitlement.latestPurchaseDate != null
              ? DateTime.parse(entitlement.latestPurchaseDate!)
              : null,
        );
      } else {
        // User's subscription expired or was cancelled
        final currentStatus = await UserPreferences.getPremiumStatus();
        if (currentStatus) {
          // Only update if currently marked as premium
          await UserPreferences.setPremiumStatus(false);
          debugPrint('ℹ️ Subscription expired or cancelled');
        }
      }
    } catch (e) {
      debugPrint('❌ Error syncing subscription status: $e');
      // Don't update local status if sync fails
      // Keep whatever status was previously stored
    }
  }

  /// Check if user has active premium subscription
  ///
  /// This checks both local storage and syncs with RevenueCat
  static Future<bool> isPremium() async {
    try {
      // First check local storage (fast)
      final localStatus = await UserPreferences.getPremiumStatus();

      // Then sync with RevenueCat in background (accurate)
      syncSubscriptionStatus().catchError((e) {
        debugPrint('Background sync failed: $e');
      });

      return localStatus;
    } catch (e) {
      debugPrint('❌ Error checking premium status: $e');
      return false;
    }
  }

  /// Get customer information including subscription details
  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('❌ Error getting customer info: $e');
      return null;
    }
  }

  /// Set user ID for RevenueCat analytics
  ///
  /// Call this after user logs in
  static Future<void> setUserId(String userId) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('❌ Error setting user ID: $e');
    }
  }

  /// Clear user ID (logout)
  static Future<void> clearUserId() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      await Purchases.logOut();
    } catch (e) {
      debugPrint('❌ Error clearing user ID: $e');
    }
  }
}

/// Result of a purchase operation
class PurchaseResult {
  final bool success;
  final bool isPremium;
  final String message;

  const PurchaseResult({
    required this.success,
    required this.isPremium,
    required this.message,
  });
}
