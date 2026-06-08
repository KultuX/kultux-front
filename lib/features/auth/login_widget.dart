import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:kultux/shared/widget/text_fields.dart';
import 'package:kultux/features/auth/register_page.dart';
import 'package:kultux/core/models/user.dart';
import 'package:kultux/data/api/user_api.dart';
import 'package:kultux/data/repository/user_repository.dart';
import 'package:kultux/shared/widget/alert_modal.dart';
import 'package:kultux/features/auth/recover_password_widget.dart';

import '../../config/app_colors.dart';


class LoginWidget extends StatefulWidget {
  final VoidCallback? onClose;
  final void Function(User user)? userLoged;
  final VoidCallback? userGuest;

  const LoginWidget({super.key, this.onClose, this.userLoged, this.userGuest});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final TextEditingController email = TextEditingController();
  final TextEditingController pass = TextEditingController();

  bool _errorEmail = false;
  bool _errorPass = false;
  bool _checked = false;
  bool _showRecoveryPass = false;

  Future<void> _login() async {
    setState(() {
      _errorEmail = false;
      _errorPass = false;
    });

    if (email.text.trim().isEmpty && pass.text.trim().isEmpty) {
      setState(() {
        _errorEmail = true;
        _errorPass = true;
      });
      AlertModal.show(
        context,
        message: 'Debes introducir correo y contraseña.',
        type: AlertTipe.warning,
      );

      return;
    }
    if (email.text.trim().isEmpty) {
      setState(() => _errorEmail = true);
      AlertModal.show(
        context,
        message: 'Introduce un correo',
        type: AlertTipe.warning,
      );
      return;
    }
    if (pass.text.trim().isEmpty) {
      setState(() => _errorPass = true);
      AlertModal.show(
        context,
        message: 'Introduce una contraseña.',
        type: AlertTipe.warning,
      );
      return;
    }

    try {
      final user = await UserApiService.loginUser(
        User.login(email.text, pass.text),
      );
      if (_checked) await UserRepository.save(user);

      AlertModal.show(
        context,
        message:
            '👋🏻 ¡¡Bienvenid@, ${user.name?.toUpperCase() ?? user.email}!!',
        type: AlertTipe.success,
      );
      widget.userLoged?.call(user);
      User.activeUser = user;
    } catch (_) {
      setState(() {
        _errorEmail = true;
        _errorPass = true;
      });
      AlertModal.show(
        context,
        message: 'Usuario o contraseña incorrectos.',
        type: AlertTipe.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ModalBarrier(dismissible: false, color: Colors.black54),
        Center(
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              child: _showRecoveryPass
                  ? RecoverPasswordWidget(
                      onClose: widget.onClose,
                      onBackLogin: () =>
                          setState(() => _showRecoveryPass = false),
                    )
                  : _buildLogin(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogin() {
    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KultuX',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFb0b0b0),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: 30,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _campo(
                  child: TextFieldApp.normal(
                    title: 'Correo electrónico',
                    controller: email,
                    showError: _errorEmail,
                    type: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 10),
                _campo(
                  child: TextFieldApp.password(
                    title: 'Contraseña',
                    controller: pass,
                    showError: _errorPass,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _checked,
                          onChanged: (v) =>
                              setState(() => _checked = v ?? false),
                          checkColor: AppColors.text,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          fillColor: WidgetStateProperty.resolveWith(
                            (s) => s.contains(WidgetState.selected)
                                ? AppColors.green
                                : null,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Mantener la sesión iniciada',
                        style: TextStyle(
                          fontFamily: 'RobotoCondensed',
                          fontSize: 13,
                          color: AppColors.textSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _showRecoveryPass = true), // NUEVO
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        fontFamily: 'RobotoCondensed',
                        fontSize: 12,
                        color: AppColors.textSoft,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.textSoft,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _login,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontFamily: 'RobotoCondensed',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: widget.userGuest,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: AppColors.textSoft,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Entrar como invitado',
                          style: TextStyle(
                            fontFamily: 'RobotoCondensed',
                            fontSize: 13,
                            color: AppColors.textSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: '¿No tienes cuenta? ',
                      style: const TextStyle(
                        fontFamily: 'RobotoCondensed',
                        fontSize: 13,
                        color: AppColors.textSoft,
                      ),
                      children: [
                        TextSpan(
                          text: 'Regístrate',
                          style: const TextStyle(
                            fontFamily: 'RobotoCondensed',
                            fontSize: 13,
                            color: AppColors.green,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.green,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => RegisterPage()),
                            ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _campo({required Widget child}) => Padding(padding: const EdgeInsets.all(10), child: child);
