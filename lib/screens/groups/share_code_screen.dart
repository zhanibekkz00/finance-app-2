import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/auth_provider.dart';
import '../../services/group_service.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';

class ShareCodeScreen extends ConsumerStatefulWidget {
  const ShareCodeScreen({super.key});

  @override
  ConsumerState<ShareCodeScreen> createState() => _ShareCodeScreenState();
}

class _ShareCodeScreenState extends ConsumerState<ShareCodeScreen> {
  final GroupService _groupService = GroupService();
  String? _inviteCode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    final userId = ref.read(authProvider).userId;
    if (userId == null) return;

    final groupId = await _groupService.getUserGroupId(userId);
    if (groupId != null) {
      final code = await _groupService.getGroupCode(groupId);
      if (mounted) {
        setState(() {
          _inviteCode = code;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createGroup() async {
    setState(() => _isLoading = true);
    final userId = ref.read(authProvider).userId;
    if (userId == null) return;

    final l10n = AppLocalizations.of(context)!;

    try {
      final code = await _groupService.createGroup(userId);
      if (mounted) {
        if (code != null) {
          setState(() {
            _inviteCode = code;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(l10n.failedToCreateGroup)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.unknown}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.jointBudgetGroup)),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_inviteCode != null) ...[
                      Text(
                        l10n.yourGroupCode,
                        style: const TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                        child: SelectableText(
                          _inviteCode!,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: _inviteCode!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.codeCopied)),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            label: Text(l10n.copy),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Share.share(
                                  l10n.shareMessage(_inviteCode!));
                            },
                            icon: const Icon(Icons.share),
                            label: Text(l10n.share),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.shareCodeInstruction,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ] else ...[
                      const Icon(Icons.group_add, size: 64, color: Colors.grey),
                      const SizedBox(height: 24),
                      Text(
                        l10n.createJointGroup,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.createGroupInstruction,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _createGroup,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                        ),
                        child: Text(l10n.createGroup),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
