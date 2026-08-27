import 'package:flutter/material.dart';

import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool showOfflineDevices = true;
  bool autoRefreshNetwork = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.settings_rounded),
            SizedBox(width: 10),
            Text('Settings'),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Application Settings',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Customize Network Doctor behavior.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // NETWORK SCANNER
                    // ==================================================
                    _SettingsSection(
                      title: 'Network Scanner',
                      icon: Icons.radar_rounded,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Show Offline Hosts'),
                          subtitle: const Text(
                            'Include unreachable IP addresses in scan results.',
                          ),
                          value: showOfflineDevices,
                          onChanged: (value) {
                            setState(() {
                              showOfflineDevices = value;
                            });
                          },
                        ),

                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Automatic Network Refresh'),
                          subtitle: const Text(
                            'Refresh network information automatically.',
                          ),
                          value: autoRefreshNetwork,
                          onChanged: (value) {
                            setState(() {
                              autoRefreshNetwork = value;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // APPEARANCE
                    // ==================================================
                    _SettingsSection(
                      title: 'Appearance',
                      icon: Icons.palette_rounded,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.brightness_6_rounded),
                          title: const Text('Theme'),
                          subtitle: const Text(
                            'Theme settings can be managed from the application appearance options.',
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Appearance settings will be expanded here.',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // ABOUT
                    // ==================================================
                    _SettingsSection(
                      title: 'Information',
                      icon: Icons.info_outline_rounded,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.info_rounded),
                          title: const Text('About Network Doctor'),
                          subtitle: const Text(
                            'Application information, developer and copyright.',
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AboutScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Center(
                      child: Text(
                        'Network Doctor 1.0.0+1',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SETTINGS SECTION
// ============================================================

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: colors.onPrimaryContainer),
                ),

                const SizedBox(width: 12),

                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            ...children,
          ],
        ),
      ),
    );
  }
}
