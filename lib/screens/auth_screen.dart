import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../data/user_repository.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _confirmCtl = TextEditingController();
  final _codeCtl = TextEditingController();

  bool _isLogin = true;
  bool _obscure = true;
  bool _loading = false;
  String _role = Roles.student;

  @override
  void dispose() {
    _usernameCtl.dispose();
    _passwordCtl.dispose();
    _confirmCtl.dispose();
    _codeCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);

    try {
      if (_isLogin) {
        await state.login(_usernameCtl.text, _passwordCtl.text);
      } else {
        await state.register(
          username: _usernameCtl.text,
          password: _passwordCtl.text,
          role: _role,
          teacherCode: _codeCtl.text,
        );
      }
    } on AuthException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Не удалось выполнить действие. Попробуйте ещё раз.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3B0B10), AppColors.background],
            stops: [0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.45),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'StudyApp',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isLogin
                          ? 'Войдите, чтобы увидеть расписание и задания'
                          : 'Создайте аккаунт, чтобы начать',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 28),
                    Form(
                      key: _formKey,
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        alignment: Alignment.topCenter,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _usernameCtl,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              decoration: const InputDecoration(
                                labelText: 'Логин',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) {
                                final value = v?.trim() ?? '';
                                if (value.isEmpty) return 'Введите логин';
                                if (!_isLogin &&
                                    value.length < AppConfig.minUsernameLength) {
                                  return 'Минимум ${AppConfig.minUsernameLength} символа';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordCtl,
                              obscureText: _obscure,
                              textInputAction: _isLogin
                                  ? TextInputAction.done
                                  : TextInputAction.next,
                              onFieldSubmitted: (_) {
                                if (_isLogin) _submit();
                              },
                              decoration: InputDecoration(
                                labelText: 'Пароль',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) {
                                final value = v ?? '';
                                if (value.isEmpty) return 'Введите пароль';
                                if (!_isLogin &&
                                    value.length < AppConfig.minPasswordLength) {
                                  return 'Минимум ${AppConfig.minPasswordLength} символов';
                                }
                                return null;
                              },
                            ),
                            if (!_isLogin) ...[
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _confirmCtl,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Повторите пароль',
                                  prefixIcon: Icon(Icons.lock_reset_outlined),
                                ),
                                validator: (v) => v != _passwordCtl.text
                                    ? 'Пароли не совпадают'
                                    : null,
                              ),
                              const SizedBox(height: 18),
                              SegmentedButton<String>(
                                showSelectedIcon: false,
                                segments: const [
                                  ButtonSegment(
                                    value: Roles.student,
                                    label: Text('Студент'),
                                    icon: Icon(Icons.school_outlined),
                                  ),
                                  ButtonSegment(
                                    value: Roles.teacher,
                                    label: Text('Преподаватель'),
                                    icon: Icon(Icons.badge_outlined),
                                  ),
                                ],
                                selected: {_role},
                                onSelectionChanged: (s) =>
                                    setState(() => _role = s.first),
                                style: SegmentedButton.styleFrom(
                                  selectedBackgroundColor: AppColors.primary,
                                  selectedForegroundColor: Colors.white,
                                  foregroundColor: AppColors.muted,
                                  side: const BorderSide(color: AppColors.outline),
                                ),
                              ),
                              if (_role == Roles.teacher) ...[
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _codeCtl,
                                  textInputAction: TextInputAction.done,
                                  autocorrect: false,
                                  decoration: const InputDecoration(
                                    labelText: 'Код преподавателя',
                                    prefixIcon: Icon(Icons.key_outlined),
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Введите код'
                                          : null,
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isLogin ? 'Войти' : 'Создать аккаунт'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loading ? null : _toggleMode,
                      child: Text(
                        _isLogin
                            ? 'Нет аккаунта? Зарегистрироваться'
                            : 'Уже есть аккаунт? Войти',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
