// Settings Dialog for application configuration
// Provides user preferences and app configuration options

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/utils.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _defaultCalendarView = 'month';
  String _defaultPortion = 'medium';
  List<String> _selectedDietaryRestrictions = [];

  // Available options
  final List<String> _calendarViews = ['week', 'month'];
  final List<String> _portionSizes = ['small', 'medium', 'large'];
  final List<String> _dietaryRestrictions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Nut-Free',
    'Low-Carb',
    'Low-Fat',
    'High-Protein',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
        _defaultCalendarView =
            prefs.getString('default_calendar_view') ?? 'month';
        _defaultPortion = prefs.getString('default_portion') ?? 'medium';
        _selectedDietaryRestrictions =
            prefs.getStringList('dietary_restrictions') ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
      await prefs.setString('default_calendar_view', _defaultCalendarView);
      await prefs.setString('default_portion', _defaultPortion);
      await prefs.setStringList(
        'dietary_restrictions',
        _selectedDietaryRestrictions,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Settings saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.settings, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          const Text('Settings'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // General Settings Section
                    _buildSectionHeader('General'),
                    _buildNotificationToggle(),
                    _buildDarkModeToggle(),
                    _buildCalendarViewSetting(),

                    const SizedBox(height: AppSpacing.lg),

                    // Meal Planning Settings Section
                    _buildSectionHeader('Meal Planning'),
                    _buildPortionSizeSetting(),

                    const SizedBox(height: AppSpacing.lg),

                    // Dietary Restrictions Section
                    _buildSectionHeader('Dietary Restrictions'),
                    _buildDietaryRestrictionsSettings(),

                    const SizedBox(height: AppSpacing.lg),

                    // Data Management Section
                    _buildSectionHeader('Data Management'),
                    _buildDataManagementButtons(),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            await _saveSettings();
            if (mounted) navigator.pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return SwitchListTile(
      title: const Text('Notifications'),
      subtitle: const Text('Enable meal planning reminders'),
      value: _notificationsEnabled,
      onChanged: (value) {
        setState(() {
          _notificationsEnabled = value;
        });
      },
      secondary: const Icon(Icons.notifications),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDarkModeToggle() {
    return SwitchListTile(
      title: const Text('Dark Mode'),
      subtitle: const Text('Use dark theme'),
      value: _darkModeEnabled,
      onChanged: (value) {
        setState(() {
          _darkModeEnabled = value;
        });
      },
      secondary: const Icon(Icons.dark_mode),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildCalendarViewSetting() {
    return ListTile(
      title: const Text('Default Calendar View'),
      subtitle: Text('Currently: $_defaultCalendarView'),
      leading: const Icon(Icons.calendar_view_month),
      trailing: DropdownButton<String>(
        value: _defaultCalendarView,
        onChanged: (value) {
          setState(() {
            _defaultCalendarView = value!;
          });
        },
        items: _calendarViews.map((view) {
          return DropdownMenuItem(value: view, child: Text(view.toUpperCase()));
        }).toList(),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildPortionSizeSetting() {
    return ListTile(
      title: const Text('Default Portion Size'),
      subtitle: Text('Currently: $_defaultPortion'),
      leading: const Icon(Icons.restaurant_menu),
      trailing: DropdownButton<String>(
        value: _defaultPortion,
        onChanged: (value) {
          setState(() {
            _defaultPortion = value!;
          });
        },
        items: _portionSizes.map((size) {
          return DropdownMenuItem(value: size, child: Text(size.toUpperCase()));
        }).toList(),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDietaryRestrictionsSettings() {
    return Column(
      children: [
        ...List.generate(_dietaryRestrictions.length, (index) {
          final restriction = _dietaryRestrictions[index];
          return CheckboxListTile(
            title: Text(restriction),
            value: _selectedDietaryRestrictions.contains(restriction),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedDietaryRestrictions.add(restriction);
                } else {
                  _selectedDietaryRestrictions.remove(restriction);
                }
              });
            },
            contentPadding: EdgeInsets.zero,
            dense: true,
          );
        }),
        if (_selectedDietaryRestrictions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Wrap(
              spacing: AppSpacing.xs,
              children: _selectedDietaryRestrictions.map((restriction) {
                return Chip(
                  label: Text(restriction),
                  onDeleted: () {
                    setState(() {
                      _selectedDietaryRestrictions.remove(restriction);
                    });
                  },
                  deleteIcon: const Icon(Icons.close, size: 16),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildDataManagementButtons() {
    return Column(
      children: [
        ListTile(
          title: const Text('Export Data'),
          subtitle: const Text('Export your meal plans and materials'),
          leading: const Icon(Icons.upload),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _exportData,
          contentPadding: EdgeInsets.zero,
        ),
        ListTile(
          title: const Text('Import Data'),
          subtitle: const Text('Import meal plans and materials'),
          leading: const Icon(Icons.download),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _importData,
          contentPadding: EdgeInsets.zero,
        ),
        ListTile(
          title: const Text('Clear All Data'),
          subtitle: const Text('Remove all meal plans and materials'),
          leading: Icon(Icons.delete_forever, color: AppColors.error),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _clearAllData,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'Export functionality will allow you to save your meal plans and materials to a file. '
          'This feature is coming soon!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _importData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
          'Import functionality will allow you to restore your meal plans and materials from a backup file. '
          'This feature is coming soon!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            const Text('Clear All Data'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete all your meal plans and materials? '
          'This action cannot be undone and will permanently remove all your data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clear all data functionality coming soon!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
