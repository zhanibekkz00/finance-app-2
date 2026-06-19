import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/group_service.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';
import 'qr_scanner_screen.dart';

class JoinGroupScreen extends ConsumerStatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  ConsumerState<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends ConsumerState<JoinGroupScreen> {
  final _codeController = TextEditingController();
  final GroupService _groupService = GroupService();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _scanQrCode() async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );
    if (scannedCode != null && scannedCode.isNotEmpty) {
      setState(() {
        _codeController.text = scannedCode.toUpperCase();
        _errorText = null;
      });
      _joinGroup();
    }
  }

  Future<void> _joinGroup() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _errorText = l10n.pleaseEnterCode);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final userId = ref.read(authProvider).userId;
    if (userId == null) return;

    final success = await _groupService.joinGroup(userId, code);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        // Refresh transactions to pick up new group data
        ref.invalidate(transactionProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.joinedGroupSuccess)),
        );
        Navigator.pop(context);
      } else {
        setState(() => _errorText = l10n.invalidCodeError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.joinGroup)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.merge_type, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              l10n.enterInviteCode,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.enterCodeInstruction,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 4),
              decoration: InputDecoration(
                hintText: 'XYZ123',
                errorText: _errorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.blueAccent),
                  onPressed: _scanQrCode,
                ),
              ),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _joinGroup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.joinGroup, style: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
