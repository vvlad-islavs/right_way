import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:right_way/core/core.dart';

@RoutePage()
class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  final _loading = <_AdFormat, bool>{};

  bool _isLoading(_AdFormat f) => _loading[f] == true;

  // ── Interstitial ────────────────────────────────────────────────────────────
  void _showInterstitial() {
    _setLoading(_AdFormat.interstitial, true);
    InterstitialAd.load(
      adUnitId: AdMobUnitIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _setLoading(_AdFormat.interstitial, false);
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (a) => a.dispose(),
            onAdFailedToShowFullScreenContent: (a, _) => a.dispose(),
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          _setLoading(_AdFormat.interstitial, false);
          _showError('Interstitial', error.message);
        },
      ),
    );
  }

  // ── Rewarded ────────────────────────────────────────────────────────────────
  void _showRewarded() {
    _setLoading(_AdFormat.rewarded, true);
    RewardedAd.load(
      adUnitId: AdMobUnitIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _setLoading(_AdFormat.rewarded, false);
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (a) => a.dispose(),
            onAdFailedToShowFullScreenContent: (a, _) => a.dispose(),
          );
          ad.show(
            onUserEarnedReward: (_, reward) =>
                _showSnack('Rewarded: +${reward.amount} ${reward.type}'),
          );
        },
        onAdFailedToLoad: (error) {
          _setLoading(_AdFormat.rewarded, false);
          _showError('Rewarded', error.message);
        },
      ),
    );
  }

  // ── Rewarded Interstitial ───────────────────────────────────────────────────
  void _showRewardedInterstitial() {
    _setLoading(_AdFormat.rewardedInterstitial, true);
    RewardedInterstitialAd.load(
      adUnitId: AdMobUnitIds.rewardedInterstitial,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _setLoading(_AdFormat.rewardedInterstitial, false);
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (a) => a.dispose(),
            onAdFailedToShowFullScreenContent: (a, _) => a.dispose(),
          );
          ad.show(
            onUserEarnedReward: (_, reward) =>
                _showSnack('Rewarded Interstitial: +${reward.amount} ${reward.type}'),
          );
        },
        onAdFailedToLoad: (error) {
          _setLoading(_AdFormat.rewardedInterstitial, false);
          _showError('Rewarded Interstitial', error.message);
        },
      ),
    );
  }

  // ── App Open ────────────────────────────────────────────────────────────────
  void _showAppOpen() {
    _setLoading(_AdFormat.appOpen, true);
    AppOpenAd.load(
      adUnitId: AdMobUnitIds.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _setLoading(_AdFormat.appOpen, false);
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (a) => a.dispose(),
            onAdFailedToShowFullScreenContent: (a, _) => a.dispose(),
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          _setLoading(_AdFormat.appOpen, false);
          _showError('App Open', error.message);
        },
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  void _setLoading(_AdFormat f, bool value) {
    if (!mounted) return;
    setState(() => _loading[f] = value);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    showAppSnackBar(context, msg);
  }

  void _showError(String format, String msg) {
    if (!mounted) return;
    showAppSnackBar(context, '$format: $msg');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final initialized = AdMobBootstrap.initialized;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adsTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: scrollableContentPadding(context),
              children: [
                // ── SDK status ────────────────────────────────────────────
                _SectionHeader(l10n.adsSdkStatus),
                const Gap(8),
                Card(
                  child: ListTile(
                    leading: Icon(
                      initialized ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: initialized ? cs.primary : cs.error,
                    ),
                    title: Text(
                      initialized ? l10n.adsSdkInitialized : l10n.adsSdkNotInitialized,
                      style: tt.bodyLarge?.copyWith(
                        color: initialized ? cs.primary : cs.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Gap(20),

                // ── Banner ────────────────────────────────────────────────
                _SectionHeader(l10n.adsBannerSection),
                const Gap(8),
                _AdFormatCard(
                  label: l10n.adsBannerLabel,
                  unitId: AdMobUnitIds.banner,
                  icon: Icons.web_asset_rounded,
                  notConfiguredLabel: l10n.adsNotConfigured,
                  showLabel: l10n.adsShowAd,
                  // Баннер уже виден внизу экрана — кнопка не нужна
                ),
                const Gap(20),

                // ── Full-screen formats ───────────────────────────────────
                _SectionHeader(l10n.adsFormatsSection),
                const Gap(8),
                _AdFormatCard(
                  label: l10n.adsInterstitialLabel,
                  unitId: AdMobUnitIds.interstitial,
                  icon: Icons.fullscreen_rounded,
                  notConfiguredLabel: l10n.adsNotConfigured,
                  showLabel: l10n.adsShowAd,
                  isLoading: _isLoading(_AdFormat.interstitial),
                  onShow: AdMobUnitIds.interstitial.isNotEmpty ? _showInterstitial : null,
                ),
                const Gap(8),
                _AdFormatCard(
                  label: l10n.adsRewardedLabel,
                  unitId: AdMobUnitIds.rewarded,
                  icon: Icons.card_giftcard_rounded,
                  notConfiguredLabel: l10n.adsNotConfigured,
                  showLabel: l10n.adsShowAd,
                  isLoading: _isLoading(_AdFormat.rewarded),
                  onShow: AdMobUnitIds.rewarded.isNotEmpty ? _showRewarded : null,
                ),
                const Gap(8),
                _AdFormatCard(
                  label: l10n.adsRewardedInterstitialLabel,
                  unitId: AdMobUnitIds.rewardedInterstitial,
                  icon: Icons.featured_play_list_rounded,
                  notConfiguredLabel: l10n.adsNotConfigured,
                  showLabel: l10n.adsShowAd,
                  isLoading: _isLoading(_AdFormat.rewardedInterstitial),
                  onShow: AdMobUnitIds.rewardedInterstitial.isNotEmpty
                      ? _showRewardedInterstitial
                      : null,
                ),
                const Gap(8),
                _AdFormatCard(
                  label: l10n.adsAppOpenLabel,
                  unitId: AdMobUnitIds.appOpen,
                  icon: Icons.open_in_new_rounded,
                  notConfiguredLabel: l10n.adsNotConfigured,
                  showLabel: l10n.adsShowAd,
                  isLoading: _isLoading(_AdFormat.appOpen),
                  onShow: AdMobUnitIds.appOpen.isNotEmpty ? _showAppOpen : null,
                ),
                const Gap(8),
                _AdFormatCard(
                  label: l10n.adsNativeLabel,
                  unitId: AdMobUnitIds.nativeAdvanced,
                  icon: Icons.dynamic_feed_rounded,
                  notConfiguredLabel: l10n.adsNotConfigured,
                  showLabel: l10n.adsShowAd,
                  // Native требует кастомного layout — не показывается кнопкой
                ),
              ],
            ),
          ),

          // ── Live banner ────────────────────────────────────────────────
          const AdMobBannerSlot(),
        ],
      ),
    );
  }
}

enum _AdFormat { interstitial, rewarded, rewardedInterstitial, appOpen }

// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _AdFormatCard extends StatelessWidget {
  const _AdFormatCard({
    required this.label,
    required this.unitId,
    required this.icon,
    required this.notConfiguredLabel,
    required this.showLabel,
    this.onShow,
    this.isLoading = false,
  });

  final String label;
  final String unitId;
  final IconData icon;
  final String notConfiguredLabel;
  final String showLabel;
  final VoidCallback? onShow;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final configured = unitId.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: configured ? cs.primary : cs.outlineVariant,
              size: 28,
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: tt.titleSmall?.copyWith(
                      color: configured ? cs.onSurface : cs.onSurfaceVariant,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    configured ? unitId : notConfiguredLabel,
                    style: tt.bodySmall?.copyWith(
                      color: configured ? cs.onSurfaceVariant : cs.outlineVariant,
                      fontFamily: configured ? 'monospace' : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onShow != null) ...[
              const Gap(8),
              SizedBox(
                height: 32,
                child: isLoading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.primary,
                          ),
                        ),
                      )
                    : FilledButton.tonal(
                        onPressed: onShow,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(showLabel, style: tt.labelMedium),
                      ),
              ),
            ] else ...[
              const Gap(8),
              Icon(
                configured ? Icons.circle : Icons.circle_outlined,
                size: 8,
                color: configured ? cs.primary : cs.outlineVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
