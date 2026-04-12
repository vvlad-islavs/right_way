import 'package:apphud/apphud.dart';
import 'package:apphud/models/apphud_models/android/android_purchase_wrapper.dart';
import 'package:apphud/models/apphud_models/apphud_non_renewing_purchase.dart';
import 'package:apphud/models/apphud_models/apphud_paywalls.dart';
import 'package:apphud/models/apphud_models/apphud_placement.dart';
import 'package:apphud/models/apphud_models/apphud_placements.dart';
import 'package:apphud/models/apphud_models/apphud_subscription.dart';
import 'package:apphud/models/apphud_models/apphud_user.dart';
import 'package:apphud/models/apphud_models/composite/apphud_product_composite.dart';
import 'package:apphud/models/apphud_models/composite/apphud_purchase_result.dart';
import 'package:apphud/models/apphud_models/apphud_composite_model.dart';
import 'package:apphud/models/apphud_models/apphud_paywall.dart';
import 'package:apphud/models/apphud_models/apphud_product.dart';
import 'package:flutter/foundation.dart';
import 'package:right_way/core/config/app_env.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Состояние подписок и paywall из AppHud + реализация [ApphudListener].
class ApphudSubscriptionService extends ChangeNotifier implements ApphudListener {
  ApphudSubscriptionService(this._talker);

  final Talker _talker;

  List<ApphudPlacement> _placements = const [];
  ApphudPaywalls? _lastPaywalls;
  List<ApphudSubscriptionWrapper> _subscriptions = const [];
  List<ApphudNonRenewingPurchase> _nonRenewing = const [];
  bool? _hasPremium;
  bool? _hasActiveSubscription;

  /// true после первого [placementsDidFullyLoad] — placements и Store-продукты готовы.
  bool _placementsLoaded = false;

  List<ApphudPlacement> get placements => List.unmodifiable(_placements);
  bool get placementsLoaded => _placementsLoaded;

  /// Синхронизация после [Apphud.placements] (например сразу после старта SDK).
  void ingestPlacements(List<ApphudPlacement> list) {
    _placements = List.from(list);
    _placementsLoaded = true;
    notifyListeners();
  }

  ApphudPaywalls? get lastPaywalls => _lastPaywalls;
  List<ApphudSubscriptionWrapper> get subscriptions => List.unmodifiable(_subscriptions);
  List<ApphudNonRenewingPurchase> get nonRenewingPurchases => List.unmodifiable(_nonRenewing);
  bool? get hasPremium => _hasPremium;
  bool? get hasActiveSubscription => _hasActiveSubscription;

  /// Paywall из кэшированного placement [Env.apphudPaywallId].
  ///
  /// Данные доступны синхронно после [placementsDidFullyLoad]: Store-продукты
  /// (SKProduct / ProductDetails) уже загружены.
  ApphudPaywall? mainPlacementPaywall() {
    final id = Env.apphudPaywallId;
    if (id.isEmpty) return null;
    for (final p in _placements) {
      if (p.paywall?.identifier == id) return p.paywall;
    }
    return null;
  }

  /// Все продукты paywall [Env.apphudPaywallId] из кэша.
  List<ApphudProduct> mainPaywallProducts() =>
      mainPlacementPaywall()?.products ?? const [];

  /// Weekly-продукт ([Env.apphudProductWeeklyId]) из кэша.
  ApphudProduct? weeklyProduct() {
    final id = Env.apphudProductWeeklyId;
    if (id.isEmpty) return null;
    return _productWithId(mainPaywallProducts(), id);
  }

  /// Monthly-продукт ([Env.apphudProductMonthlyId]) из кэша.
  ApphudProduct? monthlyProduct() {
    final id = Env.apphudProductMonthlyId;
    if (id.isEmpty) return null;
    return _productWithId(mainPaywallProducts(), id);
  }

  ApphudProduct? _productWithId(List<ApphudProduct> products, String productId) {
    for (final p in products) {
      if (p.productId == productId) return p;
    }
    return null;
  }

  Future<ApphudPlacements> fetchPlacements({bool forceRefresh = false}) =>
      Apphud.fetchPlacements(forceRefresh: forceRefresh);

  Future<bool> refreshPremiumFlags() async {
    _hasPremium = await Apphud.hasPremiumAccess();
    _hasActiveSubscription = await Apphud.hasActiveSubscription();
    notifyListeners();
    return _hasPremium ?? false;
  }

  Future<ApphudPurchaseResult> purchase(ApphudProduct product) => Apphud.purchase(product: product);

  Future<ApphudComposite> restorePurchases() => Apphud.restorePurchases();

  Future<ApphudSubscriptionWrapper?> subscription() => Apphud.subscription();

  // ─── ApphudListener ───────────────────────────────────────────────────────

  @override
  Future<void> apphudDidChangeUserID(String userId) async {
    _talker.info('Apphud: user id → $userId');
    await refreshPremiumFlags();
  }

  @override
  Future<void> apphudDidFecthProducts(List<ApphudProductComposite> products) async {
    _talker.info('Apphud: native products fetched (${products.length})');
    notifyListeners();
  }

  @override
  Future<void> paywallsDidFullyLoad(ApphudPaywalls paywalls) async {
    _lastPaywalls = paywalls;
    if (paywalls.error != null) {
      _talker.warning('Apphud: paywalls error — ${paywalls.error?.message}');
    } else {
      _talker.info('Apphud: paywalls loaded');
    }
    notifyListeners();
  }

  @override
  Future<void> userDidLoad(ApphudUser user) async {
    _talker.info('Apphud: user loaded');
    await refreshPremiumFlags();
  }

  @override
  Future<void> apphudSubscriptionsUpdated(List<ApphudSubscriptionWrapper> subscriptions) async {
    _subscriptions = subscriptions;
    await refreshPremiumFlags();
  }

  @override
  Future<void> apphudNonRenewingPurchasesUpdated(
    List<ApphudNonRenewingPurchase> purchases,
  ) async {
    _nonRenewing = purchases;
    notifyListeners();
  }

  @override
  Future<void> placementsDidFullyLoad(List<ApphudPlacement> placements) async {
    _placements = placements;
    _placementsLoaded = true;
    _talker.info('Apphud: placements loaded (${placements.length})');
    notifyListeners();
  }

  @override
  Future<void> apphudDidReceivePurchase(AndroidPurchaseWrapper purchase) async {
    _talker.info('Apphud: purchase received (Android) ${purchase.productId ?? '?'}');
    notifyListeners();
  }
}
