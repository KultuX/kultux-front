import 'package:flutter/material.dart';
import 'package:kultux/data/api/user_api.dart';
import 'package:kultux/shared/widget/alert_modal.dart';
import 'package:kultux/shared/widget/text_fields.dart';

import '../../config/app_colors.dart';



class RecoverPasswordWidget extends StatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onBackLogin;

  const RecoverPasswordWidget({super.key, this.onClose, this.onBackLogin});

  @override
  State<RecoverPasswordWidget> createState() => _RecoverPasswordWidgetState();
}

class _RecoverPasswordWidgetState extends State<RecoverPasswordWidget> {
  final TextEditingController _email = TextEditingController();
  bool _errorEmail = false;
  bool _loading = false;
  bool _sending = false;

  Future<void> _restore() async {
    setState(() {
      _errorEmail = false;
    });

    if (_email.text.trim().isEmpty) {
      setState(() => _errorEmail = true);
      AlertModal.show(
        context,
        message: 'Introduce tu correo electrónico.',
        type: AlertTipe.warning,
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await UserApiService.recoverPassword(_email.text.trim());
      setState(() {
        _sending = true;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (e.toString().contains('404')) {
        setState(() => _errorEmail = true);
        AlertModal.show(
          context,
          message: 'No existe ninguna cuenta con ese correo.',
          type: AlertTipe.error,
        );
      } else {
        AlertModal.show(
          context,
          message: 'Ha ocurrido un error. Inténtalo más tarde.',
          type: AlertTipe.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onClose,
          child: Container(color: Colors.black54),
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              child: Container(
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
                    // Header igual al login
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.lock_reset_rounded,
                                  color: AppColors.green,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
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
                                    'Recuperar contraseña',
                                    style: TextStyle(
                                      fontSize: 18,
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
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      child: _sending
                          ? _SuccessWidget(
                              email: _email.text.trim(),
                              onClose: widget.onBackLogin ?? widget.onClose,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Introduce tu correo electrónico y te enviaremos una nueva contraseña.',
                                  style: TextStyle(
                                    fontFamily: 'RobotoCondensed',
                                    fontSize: 13,
                                    color: AppColors.textSoft,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: TextFieldApp.normal(
                                    title: 'Correo electrónico',
                                    controller: _email,
                                    showError: _errorEmail,
                                    type: TextInputType.emailAddress,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: _loading ? null : _restore,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _loading
                                          ? AppColors.green.withOpacity(0.6)
                                          : AppColors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: _loading
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFF1A1A1A),
                                              ),
                                            )
                                          : const Text(
                                              'Enviar',
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
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap:
                                      widget.onBackLogin ??
                                      widget
                                          .onClose,
                                  child: const Center(
                                    child: Text(
                                      'Volver al inicio de sesión',
                                      style: TextStyle(
                                        fontFamily: 'RobotoCondensed',
                                        fontSize: 13,
                                        color: AppColors.textSoft,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.textSoft,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessWidget extends StatelessWidget {
  final String email;
  final VoidCallback? onClose;

  const _SuccessWidget({required this.email, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: AppColors.green,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '¡Correo enviado!',
          style: TextStyle(
            fontFamily: 'RobotoCondensed',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hemos enviado una nueva contraseña a $email',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'RobotoCondensed',
            fontSize: 13,
            color: AppColors.textSoft,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onClose,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'Volver al inicio de sesión',
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
        const SizedBox(height: 8),
      ],
    );
  }
}
