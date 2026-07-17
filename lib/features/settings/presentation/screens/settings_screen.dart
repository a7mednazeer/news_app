import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../home/presentation/providers/news_repository_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../data/repositories/settings_repository.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final breakingAlertsEnabled = ref.watch(breakingAlertsEnabledProvider);
    final textScale = ref.watch(textScaleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const _SectionTitle('Appearance'),
          _SettingsCard(
            children: [
              _DropdownTile<AppThemeMode>(
                icon: Icons.dark_mode_rounded,
                label: 'Theme',
                value: themeMode,
                items: const {
                  AppThemeMode.system: 'System Default',
                  AppThemeMode.light: 'Light',
                  AppThemeMode.dark: 'Dark',
                },
                onChanged: (mode) {
                  if (mode != null) ref.read(themeModeProvider.notifier).setMode(mode);
                },
              ),
              const Divider(height: 1),
              _SliderTile(
                icon: Icons.text_fields_rounded,
                label: 'Text Size',
                value: textScale,
                min: 0.85,
                max: 1.3,
                onChanged: (v) => ref.read(textScaleProvider.notifier).setScale(v),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionTitle('Language & Region'),
          _SettingsCard(
            children: [
              _DropdownTile<String>(
                icon: Icons.language_rounded,
                label: 'Language',
                value: locale,
                items: kSupportedLocales,
                onChanged: (code) {
                  if (code != null) {
                    ref.read(localeProvider.notifier).setLocale(code);
                    AppSnackbar.show(
                      context,
                      message: 'Language preference saved',
                      type: SnackType.success,
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionTitle('Notifications'),
          _SettingsCard(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_rounded),
                title: const Text('Push Notifications'),
                subtitle: const Text('Get notified about news updates'),
                value: notificationsEnabled,
                onChanged: (v) => ref.read(notificationsEnabledProvider.notifier).toggle(v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.bolt_rounded),
                title: const Text('Breaking News Alerts'),
                subtitle: const Text('Instant alerts for major stories'),
                value: breakingAlertsEnabled && notificationsEnabled,
                onChanged: notificationsEnabled
                    ? (v) => ref.read(breakingAlertsEnabledProvider.notifier).toggle(v)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionTitle('Content Preferences'),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.interests_rounded),
                title: const Text('Manage Interests'),
                subtitle: const Text('Update the topics you follow'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _openInterestsSheet(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionTitle('About'),
          _SettingsCard(
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline_rounded),
                title: Text('App Version'),
                trailing: Text(AppInfo.appVersion),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => AppSnackbar.show(context, message: 'Privacy Policy coming soon'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => AppSnackbar.show(context, message: 'Terms of Service coming soon'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _openInterestsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _InterestsSheet(),
    );
  }
}

class _InterestsSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_InterestsSheet> createState() => _InterestsSheetState();
}

class _InterestsSheetState extends ConsumerState<_InterestsSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(onboardingRepositoryProvider).getSelectedCategoryIds().toSet();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        top: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Manage Interests', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: categories.map((category) {
              final isSelected = _selected.contains(category.id);
              return FilterChip(
                label: Text(category.name),
                avatar: Icon(category.icon, size: 16),
                selected: isSelected,
                onSelected: (v) => setState(() {
                  if (v) {
                    _selected.add(category.id);
                  } else {
                    _selected.remove(category.id);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await ref
                    .read(onboardingCompleteProvider.notifier)
                    .complete(_selected.toList());
                if (context.mounted) {
                  Navigator.of(context).pop();
                  AppSnackbar.show(
                    context,
                    message: 'Interests updated',
                    type: SnackType.success,
                  );
                }
              },
              child: const Text('Save Preferences'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xs),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: children),
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  final IconData icon;
  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;

  const _DropdownTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: DropdownButton<T>(
        value: value,
        underline: const SizedBox.shrink(),
        items: items.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: AppSpacing.md),
              Text(label),
              const Spacer(),
              Text('${(value * 100).round()}%'),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: 9,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
