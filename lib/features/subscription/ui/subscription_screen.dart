import 'package:apphud/models/apphud_models/apphud_product.dart';
import 'package:apphud/models/apphud_models/apphud_subscription.dart';
import 'package:auto_route/auto_route.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:right_way/core/core.dart';

@RoutePage()
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (!di.isRegistered<ApphudSubscriptionService>()) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.subscriptionTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 48, color: Theme.of(context).colorScheme.outlineVariant),
                const Gap(16),
                Text(l10n.subscriptionSdkNotReady, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: di<ApphudSubscriptionService>(),
      builder: (context, _) => _SubscriptionView(service: di<ApphudSubscriptionService>()),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SubscriptionView extends StatefulWidget {
  const _SubscriptionView({required this.service});

  final ApphudSubscriptionService service;

  @override
  State<_SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<_SubscriptionView> {
  var _restoring = false;
  final _purchasing = <String, bool>{};

  // Telemetry: lazy-resolved из DI, null если не зарегистрирован.
  AppTelemetry? _telemetry;

  // Флаг: отправляем rw_sub_products_loaded только один раз.
  bool _productsLoadedLogged = false;

  @override
  void initState() {
    super.initState();
    _telemetry = di.isRegistered<AppTelemetry>() ? di<AppTelemetry>() : null;
    _maybeLogProductsLoaded();
  }

  @override
  void didUpdateWidget(_SubscriptionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeLogProductsLoaded();
  }

  void _maybeLogProductsLoaded() {
    if (_productsLoadedLogged || !widget.service.placementsLoaded) return;
    _productsLoadedLogged = true;
    final count = [
      widget.service.weeklyProduct(),
      widget.service.monthlyProduct(),
    ].whereType<ApphudProduct>().length;
    unawaited(_telemetry?.logSubProductsLoaded(count: count));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _planType(String productId) {
    if (productId == Env.apphudProductWeeklyId) return 'weekly';
    if (productId == Env.apphudProductMonthlyId) return 'monthly';
    return 'unknown';
  }

  // ── Purchase ──────────────────────────────────────────────────────────────

  Future<void> _purchase(ApphudProduct product) async {
    if (_purchasing[product.productId] == true) return;

    final planType = _planType(product.productId);
    unawaited(_telemetry?.logSubPurchaseStarted(
      productId: product.productId,
      planType: planType,
    ));

    setState(() => _purchasing[product.productId] = true);
    try {
      final result = await widget.service.purchase(product);
      if (!mounted) return;

      final err = result.error;
      if (err != null) {
        unawaited(_telemetry?.logSubPurchaseFailed(
          productId: product.productId,
          errorMessage: err.message,  // raw message только в телеметрию
        ));
        // Показываем локализованное сообщение, сырой ответ SDK скрываем.
        showAppSnackBar(context, context.l10n.subscriptionPurchaseFailed);
      } else if (result.subscription?.isActive == true ||
          result.nonRenewingPurchase != null) {
        final parts = apphudProductPriceParts(product);
        unawaited(_telemetry?.logSubPurchaseSuccess(
          productId: product.productId,
          planType: planType,
          price: parts.priceLabel.isNotEmpty ? parts.priceLabel : null,
          currency: parts.currencyCode,
        ));
        showAppSnackBar(context, context.l10n.subscriptionPurchaseSuccess);
        await widget.service.refreshPremiumFlags();
      }
      // else: результата нет и ошибки нет — пользователь отменил без сообщения.
    } catch (e) {
      unawaited(_telemetry?.logSubPurchaseFailed(
        productId: product.productId,
        errorMessage: e.toString(),
      ));
      if (mounted) {
        showAppSnackBar(context, context.l10n.subscriptionPurchaseFailed);
      }
    } finally {
      if (mounted) setState(() => _purchasing[product.productId] = false);
    }
  }

  // ── Restore ───────────────────────────────────────────────────────────────

  Future<void> _restore() async {
    unawaited(_telemetry?.logSubRestoreStarted());
    setState(() => _restoring = true);
    try {
      final result = await widget.service.restorePurchases();
      if (!mounted) return;

      final l10n = context.l10n;

      if (result.error != null) {
        // error != null → пользователь отменил или ошибка StoreKit/Billing.
        // refreshPremiumFlags() намеренно не вызываем — предотвращает повторный
        // App Store dialog из нативной receipt-валидации внутри SDK.
        unawaited(_telemetry?.logSubRestoreCancelled(
          errorMessage: result.error!.message,
        ));
        return;
      }

      final hasActive = result.subscriptions.any((s) => s.isActive) ||
          result.purchases.isNotEmpty;

      if (hasActive) {
        final restoredCount =
            result.subscriptions.where((s) => s.isActive).length +
            result.purchases.length;
        unawaited(_telemetry?.logSubRestoreSuccess(restoredCount: restoredCount));
        // Только при реально восстановленных покупках обновляем флаги.
        await widget.service.refreshPremiumFlags();
        if (mounted) showAppSnackBar(context, l10n.subscriptionRestoreSuccess);
      } else {
        unawaited(_telemetry?.logSubRestoreNothing());
        showAppSnackBar(context, l10n.subscriptionRestoreNothing);
      }
    } catch (_) {
      if (mounted) {
        showAppSnackBar(context, context.l10n.subscriptionRestoreFailed);
      }
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final svc = widget.service;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.subscriptionTitle)),
      body: ListView(
        padding: scrollableContentPadding(context),
        children: [
          // ── Status ────────────────────────────────────────────────────
          _SectionHeader(l10n.subscriptionStatusSection),
          const Gap(8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                children: [
                  _StatusTile(label: l10n.subscriptionPremium, value: svc.hasPremium, l10n: l10n),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _StatusTile(label: l10n.subscriptionActiveFlag, value: svc.hasActiveSubscription, l10n: l10n),
                ],
              ),
            ),
          ),
          const Gap(20),

          // ── Plans ─────────────────────────────────────────────────────
          // Продукты доступны синхронно: placementsDidFullyLoad уже дождался
          // загрузки SKProduct / ProductDetails перед тем как обновить кэш.
          // ListenableBuilder выше перестраивает экран как только придёт колбэк.
          _SectionHeader(l10n.subscriptionProductsSection),
          const Gap(8),
          if (!svc.placementsLoaded)
            const Center(
              child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
            )
          else
            Builder(
              builder: (_) {
                final weekly = svc.weeklyProduct();
                final monthly = svc.monthlyProduct();
                if (weekly == null && monthly == null) {
                  return _EmptyCard(l10n.subscriptionNoProducts);
                }
                return Column(
                  children: [
                    if (weekly != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ProductCard(
                          product: weekly,
                          planLabel: l10n.subscriptionWeekly,
                          icon: Icons.calendar_view_week_rounded,
                          isLoading: _purchasing[weekly.productId] == true,
                          onBuy: () => _purchase(weekly),
                          l10n: l10n,
                        ),
                      ),
                    if (monthly != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ProductCard(
                          product: monthly,
                          planLabel: l10n.subscriptionMonthly,
                          icon: Icons.calendar_month_rounded,
                          isLoading: _purchasing[monthly.productId] == true,
                          onBuy: () => _purchase(monthly),
                          l10n: l10n,
                        ),
                      ),
                  ],
                );
              },
            ),
          const Gap(20),

          // ── Restore ───────────────────────────────────────────────────
          FilledButton.tonal(
            onPressed: _restoring ? null : _restore,
            child: _restoring
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: cs.onSecondaryContainer),
                  )
                : Text(l10n.subscriptionRestore),
          ),
          const Gap(20),

          // ── Active subscriptions ──────────────────────────────────────
          _SectionHeader(l10n.subscriptionListSection),
          const Gap(8),
          if (svc.subscriptions.isEmpty)
            _EmptyCard(l10n.subscriptionNoneActive)
          else
            ...svc.subscriptions.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SubscriptionCard(sub: s, l10n: l10n),
              ),
            ),
          const Gap(20),

          // ── Placements ────────────────────────────────────────────────
          _SectionHeader(l10n.subscriptionPlacementsSection),
          const Gap(8),
          if (svc.placements.isEmpty)
            _EmptyCard(l10n.subscriptionNoPlacements)
          else
            Card(
              child: Column(
                children: svc.placements
                    .map(
                      (p) => ListTile(
                        leading: const Icon(Icons.dashboard_rounded),
                        title: Text(p.identifier),
                        subtitle: p.paywall != null
                            ? Text(
                                p.paywall!.identifier,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              )
                            : null,
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product card
// ─────────────────────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.planLabel,
    required this.icon,
    required this.isLoading,
    required this.onBuy,
    required this.l10n,
  });

  final ApphudProduct product;

  /// Явное название плана из l10n («Еженедельно» / «Ежемесячно»).
  final String planLabel;

  /// Иконка плана, передаётся со стороны родителя.
  final IconData icon;

  final bool isLoading;
  final VoidCallback onBuy;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // localizedTitle из StoreKit; пока не пришёл — показываем planLabel.
    final title = product.skProduct?.localizedTitle.isNotEmpty == true
        ? product.skProduct!.localizedTitle
        : planLabel;

    final price = apphudProductFormattedPrice(product);
    final period = apphudProductPeriodLabel(product);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ── Icon ──────────────────────────────────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: cs.onPrimaryContainer),
            ),
            const Gap(14),

            // ── Title + period + product id ───────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: tt.titleSmall),
                  if (period != null) ...[
                    const Gap(2),
                    Text(period, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                  const Gap(2),
                  Text(
                    product.productId,
                    style: tt.bodySmall?.copyWith(color: cs.outlineVariant, fontFamily: 'monospace'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Gap(12),

            // ── Price + buy button ─────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (price.isNotEmpty)
                  Text(
                    price,
                    style: tt.titleMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w700),
                  ),
                const Gap(6),
                SizedBox(
                  height: 32,
                  child: isLoading
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                          ),
                        )
                      : FilledButton(
                          onPressed: onBuy,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            l10n.subscriptionBuy as String,
                            style: tt.labelMedium?.copyWith(color: cs.onPrimary),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, letterSpacing: 0.5),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.label, required this.value, required this.l10n});

  final String label;
  final bool? value;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTrue = value == true;
    final isFalse = value == false;

    final color = isTrue ? cs.primary : (isFalse ? cs.error : cs.onSurfaceVariant);
    final icon = isTrue ? Icons.check_circle_rounded : (isFalse ? Icons.cancel_rounded : Icons.help_outline_rounded);
    final valueText = value == null
        ? (l10n.subscriptionUnknown as String)
        : (isTrue ? (l10n.subscriptionYes as String) : (l10n.subscriptionNo as String));

    return ListTile(
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            valueText,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
          const Gap(6),
          Icon(icon, color: color, size: 20),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.sub, required this.l10n});

  final ApphudSubscriptionWrapper sub;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final expiresDate = DateTime.fromMillisecondsSinceEpoch((sub.expiresAt * 1000).round());
    final isExpired = expiresDate.isBefore(DateTime.now());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(sub.productId, style: tt.titleSmall)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: sub.isActive ? cs.primaryContainer : cs.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    sub.status.name,
                    style: tt.labelSmall?.copyWith(
                      color: sub.isActive ? cs.onPrimaryContainer : cs.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8),
            _InfoRow(
              label: l10n.subscriptionExpiresAt,
              value:
                  '${expiresDate.year}-${expiresDate.month.toString().padLeft(2, '0')}-${expiresDate.day.toString().padLeft(2, '0')}',
              valueColor: isExpired ? cs.error : cs.onSurfaceVariant,
            ),
            const Gap(4),
            _InfoRow(
              label: l10n.subscriptionAutorenew,
              value: sub.isAutorenewEnabled ? (l10n.subscriptionYes as String) : (l10n.subscriptionNo as String),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(label, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        const Gap(8),
        Text(value, style: tt.bodySmall?.copyWith(color: valueColor ?? cs.onSurfaceVariant)),
      ],
    );
  }
}
