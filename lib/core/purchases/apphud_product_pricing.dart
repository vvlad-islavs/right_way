import 'package:apphud/models/apphud_models/apphud_product.dart';
import 'package:apphud/models/sk_product/subscription_period_time_wrapper.dart';
import 'package:intl/intl.dart';

/// Форматированная цена из [ApphudProduct].
///
/// iOS — использует [SKProductWrapper.price] + [SKPriceLocaleWrapper.currencySymbol/currencyCode].
/// Android — `formattedPrice` первой фазы первого offer.
String apphudProductFormattedPrice(ApphudProduct product) {
  final sk = product.skProduct;
  if (sk != null) {
    final price = sk.price;
    final symbol = sk.priceLocale.currencySymbol;
    final code = sk.priceLocale.currencyCode;

    if (code != null && code.isNotEmpty) {
      try {
        final digits = price % 1 == 0 ? 0 : 2;
        return NumberFormat.simpleCurrency(name: code, decimalDigits: digits)
            .format(price);
      } catch (_) {}
    }
    if (symbol != null && symbol.isNotEmpty) {
      final formatted = price % 1 == 0
          ? price.toInt().toString()
          : price.toStringAsFixed(2);
      return '$symbol$formatted';
    }
    return price.toString();
  }

  final details = product.productDetails;
  final offers = details?.subscriptionOfferDetails;
  if (offers != null && offers.isNotEmpty) {
    final phases = offers.first.pricingPhases;
    if (phases.isNotEmpty) {
      return phases.first.formattedPrice;
    }
  }
  return '';
}

/// Строка периода подписки из iOS [SKProductWrapper.subscriptionPeriod].
/// Возвращает null, если информация недоступна.
String? apphudProductPeriodLabel(ApphudProduct product) {
  final period = product.skProduct?.subscriptionPeriod;
  if (period == null) return null;
  final n = period.numberOfUnits;
  return switch (period.unit) {
    SKSubscriptionPeriodTime.day => '$n д.',
    SKSubscriptionPeriodTime.week => '$n нед.',
    SKSubscriptionPeriodTime.month => '$n мес.',
    SKSubscriptionPeriodTime.year => '$n г.',
  };
}

/// Прежний API — для обратной совместимости.
({String priceLabel, String? currencyCode}) apphudProductPriceParts(
  ApphudProduct product,
) {
  final sk = product.skProduct;
  if (sk != null) {
    return (
      priceLabel: sk.price.toString(),
      currencyCode: sk.priceLocale.currencyCode,
    );
  }
  final details = product.productDetails;
  final offers = details?.subscriptionOfferDetails;
  if (offers != null && offers.isNotEmpty) {
    final phases = offers.first.pricingPhases;
    if (phases.isNotEmpty) {
      final p = phases.first;
      return (priceLabel: p.formattedPrice, currencyCode: p.priceCurrencyCode);
    }
  }
  return (priceLabel: '', currencyCode: null);
}
