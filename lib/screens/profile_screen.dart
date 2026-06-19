import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../utils/image_crop_helper.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../providers/balance_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/chart_provider.dart';
import '../services/group_service.dart';
import '../services/upload_service.dart';
import '../widgets/glass_container.dart';
import '../app.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _groupService = GroupService();
  final _uploadService = UploadService();
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = ref.read(authProvider).displayName ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupProvider.notifier).refresh();
      ref.read(authProvider.notifier).fetchProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    await ref.read(authProvider.notifier).updateProfile(
          displayName: _nameController.text.trim(),
        );
    setState(() {
      _isEditing = false;
      _isLoading = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileUpdated)),
      );
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return;

    if (!mounted) return;
    final cropped = await ImageCropHelper.cropImage(
      sourcePath: picked.path,
      cropStyle: CropStyle.circle,
      context: context,
    );
    if (cropped == null) return;

    setState(() => _isUploadingAvatar = true);

    try {
      final Uint8List bytes = await cropped.readAsBytes();
      final url = await _uploadService.uploadImage(bytes, picked.name);
      if (url != null) {
        await ref.read(authProvider.notifier).updateProfile(avatarUrl: url);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Фото профиля обновлено!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка загрузки фото')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _leaveGroup() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    final success = await _groupService.leaveGroup();
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ref.invalidate(groupProvider);
        ref.invalidate(balanceProvider);
        ref.invalidate(transactionProvider);
        ref.invalidate(chartProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.personalAccount)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.unknown)),
        );
      }
    }
  }

  void _confirmLeaveGroup() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.65);
    final dialogBg = isDark ? const Color(0xFF1E1E2C) : Colors.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.leaveGroupConfirmTitle,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        content: Text(
          l10n.leaveGroupConfirmMessage,
          style: TextStyle(color: subTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _leaveGroup();
            },
            child: Text(l10n.leave,
                style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    await ref.read(groupProvider.notifier).refresh();
    await ref.read(authProvider.notifier).fetchProfile();
  }

  void _showPartnerProfile(BuildContext context, GroupMember partner) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PartnerProfileSheet(partner: partner),
    );
  }

  Widget _buildAvatarWidget(String? avatarUrl, double radius) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarUrl),
        backgroundColor: Colors.white24,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white24,
      child: Icon(Icons.person, size: radius, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final groupAsync = ref.watch(groupProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.65);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        color: const Color(0xFF6A11CB),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ─── Hero Header ───────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          // Avatar with edit button
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              _buildAvatarWidget(authState.avatarUrl, 48),
                              if (_isUploadingAvatar)
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black45,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const CircularProgressIndicator(
                                        color: Colors.white),
                                  ),
                                ),
                              GestureDetector(
                                onTap:
                                    _isUploadingAvatar ? null : _pickAndUploadAvatar,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Color(0xFF6A11CB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            authState.displayName ?? l10n.unknown,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            authState.email ?? '',
                            style:
                                const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ─── Body ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Personal data ──
                    _buildSectionTitle(l10n.personalData),
                    const SizedBox(height: 15),
                    if (_isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                labelText: l10n.yourName,
                                labelStyle: TextStyle(color: subTextColor),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (_isLoading)
                            const CircularProgressIndicator()
                          else
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: _saveName,
                            ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () =>
                                setState(() => _isEditing = false),
                          ),
                        ],
                      )
                    else
                      _buildProfileItem(
                        icon: Icons.badge,
                        label: l10n.displayName,
                        value: authState.displayName ?? l10n.notSpecified,
                        onEdit: () {
                          setState(() => _isEditing = true);
                        },
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                    _buildProfileItem(
                      icon: Icons.email,
                      label: l10n.email,
                      value: authState.email ?? l10n.notSpecified,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                    const SizedBox(height: 30),

                    // ── Joint budget / Partner ──
                    _buildSectionTitle(l10n.jointBudget),
                    const SizedBox(height: 15),
                    groupAsync.when(
                      data: (group) {
                        if (group != null) {
                          // Find partners (everyone who isn't the current user)
                          final partners = group.users
                              .where((u) =>
                                  u.id.trim().toLowerCase() !=
                                  authState.userId?.trim().toLowerCase())
                              .toList();

                          return GlassContainer(
                            borderRadius: 20,
                            padding: 0.0,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Partner cards
                                  if (partners.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.hourglass_empty,
                                              color: Colors.amber),
                                          const SizedBox(width: 12),
                                          Text(
                                            l10n.waitingForPartner,
                                            style: TextStyle(
                                                color: subTextColor,
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    ...partners.map((partner) =>
                                        _buildPartnerTile(context, partner, textColor, subTextColor)),

                                  Divider(
                                      color: isDark ? Colors.white12 : Colors.black12, height: 24),

                                  // Leave group button
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: _confirmLeaveGroup,
                                      icon: const Icon(Icons.logout,
                                          color: Colors.redAccent, size: 18),
                                      label: Text(
                                        l10n.leaveGroup,
                                        style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        backgroundColor:
                                            Colors.redAccent.withOpacity(0.1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return GlassContainer(
                            borderRadius: 20,
                            padding: 16.0,
                            child: Row(
                              children: [
                                Icon(Icons.person_outline,
                                    color: subTextColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.personalAccount,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.settings);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(l10n.setupGroup),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text(
                        'Error: $err',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 30),


                    if (authState.role == 'admin') ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.admin);
                          },
                          icon: const Icon(Icons.admin_panel_settings),
                          label: const Text('Админ панель',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textColor,
                          side: BorderSide(
                              color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.settings);
                        },
                        icon: const Icon(Icons.settings_outlined),
                        label: Text(l10n.settings,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.onboarding,
                              (route) => false,
                            );
                          }
                        },
                        child: Text(l10n.logoutAccount,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerTile(BuildContext context, GroupMember partner, Color textColor, Color subTextColor) {
    final name = partner.displayName ?? partner.email.split('@').first;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => _showPartnerProfile(context, partner),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            // Partner avatar
            Hero(
              tag: 'partner-avatar-${partner.id}',
              child: GestureDetector(
                onTap: () => _showPartnerProfile(context, partner),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    ),
                  ),
                  child: partner.avatarUrl != null &&
                          partner.avatarUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            partner.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.displayName ?? name,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    partner.email,
                    style: TextStyle(color: subTextColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: isDark ? Colors.white30 : Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
    required Color subTextColor,
    VoidCallback? onEdit,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey : Colors.black54)),
                Text(value,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor)),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: Icon(Icons.edit_note, color: subTextColor),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }
}

// ─── Partner Profile Bottom Sheet ─────────────────────────────────────────────
class _PartnerProfileSheet extends StatelessWidget {
  final GroupMember partner;
  const _PartnerProfileSheet({required this.partner});

  @override
  Widget build(BuildContext context) {
    final name = partner.displayName ?? partner.email.split('@').first;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final hasAvatar =
        partner.avatarUrl != null && partner.avatarUrl!.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.65);
    final dialogBg = isDark ? const Color(0xFF1E1E2C) : Colors.white;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: EdgeInsets.zero,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Gradient header with avatar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  // Tappable avatar → fullscreen
                  GestureDetector(
                    onTap: hasAvatar
                        ? () => _showFullscreenPhoto(context, partner.avatarUrl!)
                        : null,
                    child: Hero(
                      tag: 'partner-avatar-${partner.id}',
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white24,
                        ),
                        child: hasAvatar
                            ? ClipOval(
                                child: Image.network(
                                  partner.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Text(initial,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 38,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 38,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (hasAvatar)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.zoom_in, color: Colors.white60, size: 14),
                          SizedBox(width: 4),
                          Text('Нажмите для просмотра',
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 11)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  Text(
                    partner.displayName ?? name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    partner.email,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Info tile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Партнёр по бюджету',
                    style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 12,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),
                  _infoRow(context, Icons.badge_outlined, 'Имя',
                      partner.displayName ?? '—', textColor, isDark),
                  const SizedBox(height: 10),
                  _infoRow(context, Icons.email_outlined, 'Email', partner.email, textColor, isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11)),
              Text(value,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  void _showFullscreenPhoto(BuildContext context, String url) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (ctx, animation, _) => FadeTransition(
          opacity: animation,
          child: GestureDetector(
            onTap: () => Navigator.pop(ctx),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Hero(
                  tag: 'partner-avatar-${partner.id}',
                  child: InteractiveViewer(
                    child: Image.network(url, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
