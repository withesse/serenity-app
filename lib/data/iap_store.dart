import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

import 'error_sink.dart';

/// Product IDs — must match the identifiers registered in App Store
/// Connect (iOS) and Play Console (Android). These are the public IDs the
/// client references; StoreKit/Billing resolves them to store listings and
/// returns localised prices.
const kSerenityMonthlyId = 'com.serenity.premium.monthly';
const kSerenityYearlyId = 'com.serenity.premium.yearly';

const _allProductIds = <String>{kSerenityMonthlyId, kSerenityYearlyId};

@immutable
class IapState {
  const IapState({
    required this.available,
    required this.products,
    required this.purchasing,
    required this.isPremium,
    this.error,
  });

  /// `false` when the store isn't reachable (sandbox misconfigured, device
  /// signed out of App Store, etc). UI should hide CTAs in this case.
  final bool available;
  final List<ProductDetails> products;
  final bool purchasing;
  final bool isPremium;
  final String? error;

  ProductDetails? byId(String id) =>
      products.where((p) => p.id == id).cast<ProductDetails?>().firstWhere(
            (_) => true,
            orElse: () => null,
          );

  IapState copyWith({
    bool? available,
    List<ProductDetails>? products,
    bool? purchasing,
    bool? isPremium,
    String? error,
    bool clearError = false,
  }) =>
      IapState(
        available: available ?? this.available,
        products: products ?? this.products,
        purchasing: purchasing ?? this.purchasing,
        isPremium: isPremium ?? this.isPremium,
        error: clearError ? null : (error ?? this.error),
      );
}

/// Wraps `in_app_purchase` in a shape the UI consumes. Premium entitlement is
/// cached in Hive so the app still reads correctly offline — in production
/// this should be cross-checked with a server that validates the receipt,
/// rather than trusting the local flag alone.
class IapController extends Notifier<IapState> {
  static const _boxName = 'settings';
  static const _premiumKey = 'iap.isPremium';

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  @override
  IapState build() {
    ref.onDispose(() => _purchaseSub?.cancel());
    unawaited(_init());
    return IapState(
      available: false,
      products: const [],
      purchasing: false,
      isPremium: _box.get(_premiumKey, defaultValue: false) as bool,
    );
  }

  Future<void> _init() async {
    try {
      final iap = InAppPurchase.instance;
      final available = await iap.isAvailable();
      state = state.copyWith(available: available);
      if (!available) return;

      _purchaseSub = iap.purchaseStream.listen(
        // _onPurchaseUpdate is async. A stream's `onError` only catches
        // stream-emitted errors, not rejections from the onData Future,
        // so wrap it ourselves and funnel rejects through reportError.
        (updates) => unawaited(_onPurchaseUpdate(updates).catchError(
          (Object e, StackTrace st) {
            reportError(ref, e, st, context: 'iap_purchase_update');
            state = state.copyWith(error: e.toString());
          },
        )),
        onError: (Object e, StackTrace st) {
          reportError(ref, e, st, context: 'iap_purchase_stream');
          state = state.copyWith(error: e.toString());
        },
      );

      final response = await iap.queryProductDetails(_allProductIds);
      if (response.error != null) {
        // Store-side API error (network, bad product ids, missing entitlement
        // capability, etc). Surface via reportError so Sentry sees the real
        // error.details, not just the stringified state.error.
        final err = response.error!;
        reportError(
          ref,
          StateError('queryProductDetails failed: ${err.code} ${err.message}'),
          StackTrace.current,
          context: 'iap_query_products',
          data: {'code': err.code, 'message': err.message},
        );
        state = state.copyWith(error: err.message);
        return;
      }
      state = state.copyWith(products: response.productDetails);
    } catch (e, st) {
      reportError(ref, e, st, context: 'iap_init');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> purchase(ProductDetails product) async {
    state = state.copyWith(purchasing: true, clearError: true);
    try {
      final param = PurchaseParam(productDetails: product);
      // All Serenity products are subscriptions → buyNonConsumable with
      // auto-renew is handled by StoreKit/Billing as a subscription.
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
    } catch (e, st) {
      reportError(ref, e, st,
          context: 'iap_purchase', data: {'productId': product.id});
      state = state.copyWith(purchasing: false, error: e.toString());
    }
  }

  Future<void> restore() => InAppPurchase.instance.restorePurchases();

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> updates) async {
    for (final p in updates) {
      switch (p.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(purchasing: true);
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // REAL IMPL: ship the purchase verification data to our backend,
          // which validates with Apple/Google and updates the user's
          // entitlement. For now we trust the store and flip a local flag.
          if (_allProductIds.contains(p.productID)) {
            await _box.put(_premiumKey, true);
            state = state.copyWith(
              isPremium: true,
              purchasing: false,
              clearError: true,
            );
          }
          if (p.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(p);
          }
        case PurchaseStatus.error:
          state = state.copyWith(
            purchasing: false,
            error: p.error?.message ?? 'Purchase failed',
          );
        case PurchaseStatus.canceled:
          state = state.copyWith(purchasing: false);
      }
    }
  }

  /// Dev-only helper to flip the flag without the store pipeline. Remove
  /// from release builds.
  Future<void> devSetPremium(bool v) async {
    if (!kDebugMode) return;
    await _box.put(_premiumKey, v);
    state = state.copyWith(isPremium: v);
  }

  /// Opens the platform subscription management UI.
  Future<void> openManageSubscriptions() async {
    final url = Platform.isIOS
        ? Uri.parse('https://apps.apple.com/account/subscriptions')
        : Uri.parse(
            'https://play.google.com/store/account/subscriptions?sku=$kSerenityMonthlyId&package=com.serenity.serenity_app',
          );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

final iapProvider =
    NotifierProvider<IapController, IapState>(IapController.new);
