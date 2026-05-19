import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/forgot_password_provider.dart';
import '../../widgets/glass_container.dart';
import 'package:finance_app/l10n/generated/app_localizations.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscureText = true;
  bool _isEmailEmpty = true;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    final isEmpty = _emailCtrl.text.trim().isEmpty;
    if (isEmpty != _isEmailEmpty) {
      setState(() {
        _isEmailEmpty = isEmpty;
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.removeListener(_onEmailChanged);
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _sendEmail() {
    if (_formKey.currentState!.validate()) {
      ref.read(forgotPasswordProvider.notifier).sendResetCode(_emailCtrl.text.trim());
    }
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      ref.read(forgotPasswordProvider.notifier).resetPassword(
            _emailCtrl.text.trim(),
            _otpCtrl.text.trim(),
            _passCtrl.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(forgotPasswordProvider);

    // Listen to success and errors
    ref.listen<ForgotPasswordState>(forgotPasswordProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        String errorMsg = next.error!;
        if (errorMsg.contains('Email не найден') || errorMsg.contains('Not Found') || errorMsg.contains('404')) {
          errorMsg = l10n.emailNotFound;
        } else if (errorMsg.contains('Ошибка отправки') || errorMsg.contains('500') || errorMsg.contains('Internal Server Error')) {
          errorMsg = l10n.failedToSendCode;
        } else if (errorMsg.contains('Invalid or expired reset code')) {
          errorMsg = l10n.invalidCode;
        } else {
          errorMsg = '${l10n.checkConnection}: $errorMsg';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      if (next.isSuccess && !prev!.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.passwordResetSuccess),
            backgroundColor: Colors.green,
          ),
        );
        // Clear forgot password state and pop back to login
        ref.read(forgotPasswordProvider.notifier).resetState();
        Navigator.pop(context);
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.passwordRecovery, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: GlassContainer(
                  borderRadius: 24,
                  padding: 24,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: !state.isCodeSent
                        ? _buildEmailStep(l10n, state)
                        : _buildResetStep(l10n, state),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep(AppLocalizations l10n, ForgotPasswordState state) {
    return Column(
      key: const ValueKey('email_step'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mail_outline, size: 64, color: Color(0xFF6366F1)),
        const SizedBox(height: 16),
        Text(
          l10n.enterYourEmail,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _emailCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: l10n.email,
            labelStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Введите email';
            }
            if (!value.contains('@')) {
              return 'Введите корректный email';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isEmailEmpty ? null : _sendEmail,
                child: Text(l10n.send, style: const TextStyle(fontSize: 16)),
              ),
      ],
    );
  }

  Widget _buildResetStep(AppLocalizations l10n, ForgotPasswordState state) {
    return Column(
      key: const ValueKey('reset_step'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.security, size: 64, color: Color(0xFF22C55E)),
        const SizedBox(height: 16),
        Text(
          l10n.codeSentToEmail,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.greenAccent),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _otpCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: l10n.enterOtp,
            labelStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Введите код';
            }
            if (value.length < 6) {
              return 'Код должен содержать 6 цифр';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passCtrl,
          style: const TextStyle(color: Colors.white),
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: l10n.newPassword,
            labelStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.vpn_key_outlined, color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Введите новый пароль';
            }
            if (value.length < 6) {
              return 'Пароль должен быть не менее 6 символов';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPassCtrl,
          style: const TextStyle(color: Colors.white),
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: l10n.confirmNewPassword,
            labelStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.vpn_key_outlined, color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Подтвердите пароль';
            }
            if (value != _passCtrl.text) {
              return l10n.passwordsDoNotMatch;
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _resetPassword,
                child: Text(l10n.reset, style: const TextStyle(fontSize: 16)),
              ),
      ],
    );
  }
}
