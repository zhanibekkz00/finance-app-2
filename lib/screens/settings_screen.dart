import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../providers/notification_provider.dart';
import '../../app.dart';
import '../../services/export_service.dart';
import 'groups/share_code_screen.dart';
import 'groups/join_group_screen.dart';
import 'categories_screen.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // Helper to get native language names and flags
  String _getLanguageName(String code) {
    switch (code) {
      case 'ru':
        return 'Русский';
      case 'kk':
        return 'Қазақша';
      case 'en':
      default:
        return 'English';
    }
  }

  String _getLanguageFlag(String code) {
    switch (code) {
      case 'ru':
        return '🇷🇺';
      case 'kk':
        return '🇰🇿';
      case 'en':
      default:
        return '🇬🇧';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // SECTION 1: APPEARANCE & LOCALIZATION
          _buildSectionHeader(l10n.sectionAppearance),
          Card(
            elevation: 0,
            color: isDark ? Colors.grey[900] : Colors.grey[100],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.darkMode,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  // Row of 3 theme choices: Light, Dark, System
                  Row(
                    children: [
                      Expanded(
                        child: _buildThemeOption(
                          context,
                          ref,
                          ThemeMode.light,
                          Icons.wb_sunny_rounded,
                          l10n.themeLight,
                          settings.themeMode == ThemeMode.light,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildThemeOption(
                          context,
                          ref,
                          ThemeMode.dark,
                          Icons.nights_stay_rounded,
                          l10n.themeDark,
                          settings.themeMode == ThemeMode.dark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildThemeOption(
                          context,
                          ref,
                          ThemeMode.system,
                          Icons.settings_suggest_rounded,
                          l10n.themeSystem,
                          settings.themeMode == ThemeMode.system,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // LANGUAGE CARD
          Card(
            elevation: 0,
            color: isDark ? Colors.grey[900] : Colors.grey[100],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.blue[900] : Colors.blue[50])?.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.language_rounded, color: Colors.blue[600]),
              ),
              title: Text(
                l10n.language,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_getLanguageFlag(settings.locale.languageCode)} ${_getLanguageName(settings.locale.languageCode)}',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                ],
              ),
              onTap: () => _showLanguagePicker(context, ref, settings.locale.languageCode),
            ),
          ),
          const SizedBox(height: 12),

          // CATEGORIES CARD
          Card(
            elevation: 0,
            color: isDark ? Colors.grey[900] : Colors.grey[100],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.indigo[900] : Colors.indigo[50])?.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.category_rounded, color: Colors.indigo[600]),
              ),
              title: Text(
                l10n.category,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoriesScreen()),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 2: DATA & NOTIFICATIONS
          _buildSectionHeader(l10n.sectionDataNotifications),
          Card(
            elevation: 0,
            color: isDark ? Colors.grey[900] : Colors.grey[100],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.orange[900] : Colors.orange[50])?.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.file_download_rounded, color: Colors.orange[600]),
                  ),
                  title: Text(
                    l10n.exportData,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                  onTap: () async {
                    await ExportService.exportToFile();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.exportSuccess),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
                Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[200]),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.red[900] : Colors.red[50])?.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_rounded, color: Colors.red[600]),
                  ),
                  title: Text(
                    l10n.notifications,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Consumer(
                    builder: (context, ref, child) {
                      final unreadCount = ref.watch(unreadNotificationsCountProvider);
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF375F),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                        ],
                      );
                    },
                  ),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 3: SHARED BUDGET
          _buildSectionHeader(l10n.jointBudget),
          Card(
            elevation: 0,
            color: isDark ? Colors.grey[900] : Colors.grey[100],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.purple[900] : Colors.purple[50])?.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.qr_code_rounded, color: Colors.purple[600]),
                  ),
                  title: Text(
                    l10n.shareGroupCode,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ShareCodeScreen()),
                    );
                  },
                ),
                Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[200]),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.teal[900] : Colors.teal[50])?.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.group_add_rounded, color: Colors.teal[600]),
                  ),
                  title: Text(
                    l10n.joinGroup,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 4: AI RECOGNITION
          _buildSectionHeader('AI & Распознавание'),
          Card(
            elevation: 0,
            color: isDark ? Colors.grey[900] : Colors.grey[100],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.blue[900] : Colors.blue[50])?.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.document_scanner_rounded, color: Colors.blue[600]),
              ),
              title: const Text(
                'Gemini API Key',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                settings.geminiApiKey.isEmpty 
                  ? 'Не задан. Распознавание чеков недоступно.' 
                  : 'Ключ добавлен',
                style: TextStyle(
                  color: settings.geminiApiKey.isEmpty ? Colors.redAccent : Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
              onTap: () => _showApiKeyDialog(context, ref, settings.geminiApiKey),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
    IconData icon,
    String label,
    bool isSelected,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: () => ref.read(settingsProvider.notifier).setThemeMode(mode),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? activeColor.withOpacity(0.2) : activeColor.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : (isDark ? Colors.grey[400] : Colors.grey[600]),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, String currentLanguageCode) {

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Выберите язык / Тілді таңдаңыз',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                _buildLanguageTile(context, ref, 'ru', currentLanguageCode),
                _buildLanguageTile(context, ref, 'kk', currentLanguageCode),
                _buildLanguageTile(context, ref, 'en', currentLanguageCode),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    WidgetRef ref,
    String code,
    String currentLanguageCode,
  ) {
    final isSelected = code == currentLanguageCode;
    final flag = _getLanguageFlag(code);
    final name = _getLanguageName(code);

    return ListTile(
      leading: Text(
        flag,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor)
          : null,
      onTap: () {
        ref.read(settingsProvider.notifier).setLocale(Locale(code));
        Navigator.pop(context);
      },
    );
  }

  void _showApiKeyDialog(BuildContext context, WidgetRef ref, String currentKey) {
    final controller = TextEditingController(text: currentKey);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gemini API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Для работы ИИ-распознавания чеков вам нужен бесплатный ключ Gemini от Google AI Studio.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).setGeminiApiKey(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
