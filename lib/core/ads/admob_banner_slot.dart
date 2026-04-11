import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:right_way/core/ads/admob_unit_ids.dart';

/// Баннер AdMob (anchored adaptive по ширине экрана, иначе [AdSize.banner]).
///
/// Загрузка стартует после кадра с валидным [MediaQuery] и после
/// [MobileAds.instance.initialize] — иначе первый запрос часто не доходит до показа.
class AdMobBannerSlot extends StatefulWidget {
  const AdMobBannerSlot({super.key});

  @override
  State<AdMobBannerSlot> createState() => _AdMobBannerSlotState();
}

class _AdMobBannerSlotState extends State<AdMobBannerSlot> {
  BannerAd? _ad;
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBanner());
  }

  Future<void> _loadBanner() async {
    final unitId = AdMobUnitIds.banner;
    if (!mounted || unitId.isEmpty) return;

    await MobileAds.instance.initialize();
    if (!mounted) return;

    final width = MediaQuery.sizeOf(context).width.truncate();
    final adaptive = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted) return;

    final size = adaptive ?? AdSize.banner;

    final ad = BannerAd(
      adUnitId: unitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (failed, error) {
          failed.dispose();
          if (!mounted) return;
          debugPrint(
            'AdMob banner onAdFailedToLoad: code=${error.code} domain=${error.domain} '
            'message=${error.message}',
          );
          setState(() {
            _ad = null;
            _loaded = false;
          });
        },
      ),
    );

    if (!mounted) return;
    setState(() => _ad = ad);
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
