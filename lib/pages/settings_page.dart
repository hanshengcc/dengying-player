import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/update_checker.dart';
import '../widgets/tv_focus_highlight.dart';
import '../widgets/update_dialog.dart';

/// 设置页：主题、账户。每组设置放一张圆角卡片里，不是一条条平铺到底——
/// 分组更清楚，也是 Netflix 设置页那种"一屏几大块"的排法。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = L.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _SettingsSection(
            title: l.appearance,
            child: RadioGroup<ThemeMode>(
              groupValue: state.themeMode,
              onChanged: (m) => state.setThemeMode(m!),
              child: Column(
                children: [
                  TvFocusHighlight(
                    child: RadioListTile<ThemeMode>(
                        autofocus: state.tvMode,
                        title: Text(l.followSystem),
                        value: ThemeMode.system),
                  ),
                  TvFocusHighlight(
                    child: RadioListTile<ThemeMode>(
                        title: Text(l.lightTheme), value: ThemeMode.light),
                  ),
                  TvFocusHighlight(
                    child: RadioListTile<ThemeMode>(
                        title: Text(l.darkTheme), value: ThemeMode.dark),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SettingsSection(
            title: l.languageSectionTitle,
            child: RadioGroup<Locale?>(
              groupValue: state.locale,
              onChanged: (v) => state.setLocale(v),
              child: Column(
                children: [
                  TvFocusHighlight(
                    child: RadioListTile<Locale?>(
                        title: Text(l.followSystem), value: null),
                  ),
                  TvFocusHighlight(
                    child: RadioListTile<Locale?>(
                        title: Text(l.languageChinese),
                        value: const Locale('zh')),
                  ),
                  TvFocusHighlight(
                    child: RadioListTile<Locale?>(
                        title: Text(l.languageEnglish),
                        value: const Locale('en')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SettingsSection(
            title: l.tvSectionTitle,
            child: TvFocusHighlight(
              child: SwitchListTile(
                title: Text(l.tvModeTitle),
                subtitle: Text(l.tvModeDescription),
                value: state.tvMode,
                onChanged: (v) => state.setTvMode(v),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SettingsSection(
            title: l.account,
            child: Column(
              children: [
                if (state.activeServer != null)
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(state.activeServer!.username),
                    subtitle: Text(state.activeServer!.baseUrl),
                  ),
                TvFocusHighlight(
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text(l.logout),
                    onTap: () async {
                      await context.read<AppState>().logout();
                      if (context.mounted) {
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SettingsSection(
            title: l.about,
            child: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snap) {
                final version = snap.data?.version;
                final l = L.of(context);
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(l.appName),
                      subtitle: Text(l.aboutSubtitle),
                    ),
                    TvFocusHighlight(
                      child: ListTile(
                        leading: const Icon(Icons.system_update_outlined),
                        title: Text(l.checkUpdate),
                        subtitle: Text(version != null
                            ? l.currentVersion(version)
                            : l.loadingVersion),
                        onTap: () => _checkUpdate(context),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkUpdate(BuildContext context) async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(l.checkingUpdate)));
    final info = await UpdateChecker.check();
    if (!context.mounted) return;
    messenger.hideCurrentSnackBar();
    if (info == null) {
      messenger.showSnackBar(SnackBar(content: Text(l.alreadyLatest)));
    } else {
      showUpdateDialog(context, info);
    }
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _SettingsSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: scheme.primary),
          ),
        ),
        Material(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ],
    );
  }
}
