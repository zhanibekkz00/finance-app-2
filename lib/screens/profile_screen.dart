import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../providers/balance_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/chart_provider.dart';
import '../services/group_service.dart';
import '../widgets/glass_container.dart';
import '../widgets/neo_container.dart';
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
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = ref.read(authProvider).displayName ?? '';
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

  Future<void> _leaveGroup() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    final success = await _groupService.leaveGroup();
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        // Invalidate all related providers to clear state and transition to personal wallet
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.leaveGroupConfirmTitle, style: const TextStyle(color: Colors.white)),
        content: Text(
          l10n.leaveGroupConfirmMessage,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _leaveGroup();
            },
            child: Text(l10n.leave, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final groupAsync = ref.watch(groupProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, size: 40, color: Colors.white),
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
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(l10n.personalData),
                  const SizedBox(height: 15),
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: l10n.yourName,
                              labelStyle: const TextStyle(color: Colors.grey),
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
                          onPressed: () => setState(() => _isEditing = false),
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
                    ),
                  _buildProfileItem(
                    icon: Icons.email,
                    label: l10n.email,
                    value: authState.email ?? l10n.notSpecified,
                  ),
                  const SizedBox(height: 30),
                  _buildSectionTitle(l10n.jointBudget),
                  const SizedBox(height: 15),
                  groupAsync.when(
                    data: (group) {
                      if (group != null) {
                        final partner = group.users
                            .where((u) => u.id != authState.userId)
                            .firstOrNull;
                        final partnerText = partner != null
                            ? (partner.displayName ?? partner.email)
                            : l10n.unknown;

                        return GlassContainer(
                          borderRadius: 20,
                          padding: 16.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.group, color: Colors.blueAccent),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      l10n.inGroupWith(partnerText),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _confirmLeaveGroup,
                                  icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                                  label: Text(
                                    l10n.leaveGroup,
                                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return GlassContainer(
                          borderRadius: 20,
                          padding: 16.0,
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.personalAccount,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.settings);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
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
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Text(
                      'Error: $err',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildSectionTitle(l10n.account),
                  const SizedBox(height: 15),
                  _buildProfileItem(
                    icon: Icons.security,
                    label: l10n.role,
                    value: authState.role ?? 'User',
                  ),
                  const SizedBox(height: 40),
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
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onEdit,
  }) {
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
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.white70),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }
}
