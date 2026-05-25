import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  String _theme = 'System';
  String _alarmSound = 'Default';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Notifications Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Notifications',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _SettingsTile(
            title: 'Notifications',
            subtitle: 'Receive alarm notifications',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ),
          _SettingsTile(
            title: 'Vibration',
            subtitle: 'Vibrate on alarm',
            trailing: Switch(
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  _vibrationEnabled = value;
                });
              },
            ),
          ),
          _SettingsTile(
            title: 'Sound',
            subtitle: 'Play sound on alarm',
            trailing: Switch(
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
            ),
          ),
          const Divider(height: 1),

          // Sound & Appearance Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Sound & Appearance',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _SettingsTile(
            title: 'Alarm Sound',
            subtitle: _alarmSound,
            trailing: Icon(
              Icons.chevron_right,
              color: theme.iconTheme.color,
            ),
            onTap: () {
              _showSoundPicker(context);
            },
          ),
          _SettingsTile(
            title: 'Theme',
            subtitle: _theme,
            trailing: Icon(
              Icons.chevron_right,
              color: theme.iconTheme.color,
            ),
            onTap: () {
              _showThemePicker(context);
            },
          ),
          const Divider(height: 1),

          // About Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'About',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _SettingsTile(
            title: 'App Version',
            subtitle: '1.0.0',
            trailing: null,
          ),
          _SettingsTile(
            title: 'Privacy Policy',
            trailing: Icon(
              Icons.chevron_right,
              color: theme.iconTheme.color,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy')),
              );
            },
          ),
          _SettingsTile(
            title: 'Terms of Service',
            trailing: Icon(
              Icons.chevron_right,
              color: theme.iconTheme.color,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of Service')),
              );
            },
          ),
          const SizedBox(height: 20),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout (mockup)')),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Theme',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...<String>['Light', 'Dark', 'System'].map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _theme,
                onChanged: (value) {
                  setState(() {
                    _theme = value ?? 'System';
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showSoundPicker(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Alarm Sound',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...<String>['Default', 'Chime', 'Bell', 'Digital'].map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _alarmSound,
                onChanged: (value) {
                  setState(() {
                    _alarmSound = value ?? 'Default';
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
