import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'package:kultux/shared/widget/legal_dialog.dart';
import 'package:kultux/shared/widget/locality_selector.dart';
import 'package:kultux/shared/widget/text_fields.dart';
import 'package:kultux/core/models/location.dart';
import 'package:kultux/data/api/location_api.dart';
import 'package:kultux/data/api/user_api.dart';
import 'package:kultux/core/models/user.dart';
import 'package:kultux/shared/widget/alert_modal.dart';
import 'package:kultux/core/utils/validations.dart';

import 'package:kultux/shared/widget/page_header.dart';
import 'package:kultux/core/utils/web_container.dart';

import 'package:kultux/config/app_colors.dart';

import '../../core/utils/formatter.dart';





class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _termsChecked = false;
  bool _privacyChecked = false;
  String? email;
  Location? _locationSelected;

  static Map<String, TextEditingController>? controllers;

  late Future<List<Location>> futureLocations;

  String _currentEmail = '';
  String? _emailErrorApi;
  bool _emailValido = true;

  String _currentPassword = '';
  bool _isValidPassword = true;

  String currentConfirmPassword = '';
  bool _isSamePassword = true;

  String _dateOfBirth = '';

  @override
  void initState() {
    super.initState();
    futureLocations = LocationApiService.locationsNames();
    controllers = {
      'nombre': TextEditingController(),
      'apellidos': TextEditingController(),
      'email': TextEditingController(),
      'password': TextEditingController(),
      'password2': TextEditingController(),
      'fechaNacimiento': TextEditingController(),
    };
  }

  Future<bool> registerUser() async {
    if (!_termsChecked || !_privacyChecked) {
      AlertModal.show(
        context,
        message: 'Debes aceptar los Términos y la Política de privacidad.',
        type: AlertTipe.warning,
      );
      return false;
    }

    final fields = {
      'Nombre': controllers!['nombre']!.text,
      'Apellidos': controllers!['apellidos']!.text,
      'Correo electrónico': controllers!['email']!.text,
      'Contraseña': controllers!['password']!.text,
      'Repite contraseña': controllers!['password2']!.text,
      'Fecha de nacimiento': _dateOfBirth,
    };

    for (final entry in fields.entries) {
      if (entry.value.trim().isEmpty) {
        AlertModal.show(
          context,
          message: 'El campo ${entry.key} es obligatorio.',
          type: AlertTipe.error,
        );
        return false;
      }
    }

    final emailInput = controllers!['email']!.text.trim();
    final password = controllers!['password']!.text.trim();

    if (Validations.emailError(emailInput) != null) {
      AlertModal.show(
        context,
        message: Validations.emailError(emailInput)!,
        type: AlertTipe.error,
      );
      return false;
    }

    if (Validations.passwordError(password) != null) {
      AlertModal.show(
        context,
        message: Validations.passwordError(password)!,
        type: AlertTipe.error,
      );
      return false;
    }

    if (password != controllers!['password2']!.text.trim()) {
      AlertModal.show(
        context,
        message: 'Las contraseñas no coinciden',
        type: AlertTipe.error,
      );
      return false;
    }

    if (_locationSelected == null) {
      AlertModal.show(
        context,
        message: 'Selecciona una localidad válida.',
        type: AlertTipe.error,
      );
      return false;
    }

    try {
      email = await UserApiService.registerUser(
        User.register({
          'nombre': controllers!['nombre']!.text,
          'apellidos': controllers!['apellidos']!.text,
          'email': controllers!['email']!.text,
          'password': controllers!['password']!.text,
          'localidad': _locationSelected!.ine,
          'fechaNacimiento': _dateOfBirth,
        }),
      );
      return true;
    } catch (e) {
      final errorStr = e.toString();

      if (errorStr.contains('409')) {
        setState(() {
          _emailErrorApi = 'Este correo ya está en uso';
        });
        return false;
      }

      AlertModal.show(
        context,
        message: 'Alguno de los datos no son correctos, revísalos.',
        type: AlertTipe.error,
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorEmail = _emailErrorApi ?? Validations.emailError(_currentEmail);
    final emailEsValido = errorEmail == null;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(),
            PageHeader(
              title: 'Crear cuenta',
              subtitle: 'Bienvenid@',
              showRightImage: true,
              minHeight: 120,
              logoAsset: 'assets/images/logo_kultux.png',
            ),
            WebContainer(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LabelSection('Datos personales'),
                    _Field(
                      child: TextFieldApp.normal(
                        title: 'Nombre',
                        controller: controllers!['nombre']!,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Field(
                      child: TextFieldApp.normal(
                        title: 'Apellidos',
                        controller: controllers!['apellidos']!,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Field(child: _calendarField()),

                    const SizedBox(height: 16),
                    _LabelSection('Cuenta'),
                    _Field(
                      child: TextFieldApp.normal(
                        title: 'Correo electrónico',
                        controller: controllers!['email']!,
                        type: TextInputType.emailAddress,
                        showError: _currentEmail.isNotEmpty && !emailEsValido,
                        onChanged: (value) {
                          setState(() {
                            _currentEmail = value;
                            _emailValido = Validations.email(value);
                            _emailErrorApi = null;
                          });
                        },
                      ),
                    ),
                    if (_currentEmail.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          errorEmail ?? 'Email válido',
                          style: TextStyle(
                            fontSize: 12,
                            color: emailEsValido ? AppColors.green : Colors.red,
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),
                    _Field(
                      child: TextFieldApp.password(
                        title: 'Contraseña',
                        controller: controllers!['password']!,
                        showError:
                            _currentPassword.isNotEmpty && !_isValidPassword,
                        onChanged: (value) {
                          setState(() {
                            _currentPassword = value;
                            _isValidPassword = Validations.password(value);
                            _isSamePassword =
                                currentConfirmPassword.isEmpty ||
                                currentConfirmPassword == value;
                          });
                        },
                      ),
                    ),

                    if (_currentPassword.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          Validations.passwordError(_currentPassword) ??
                              'Contraseña válida',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isValidPassword ? AppColors.green : Colors.red,
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),
                    _Field(
                      child: TextFieldApp.password(
                        title: 'Repite contraseña',
                        controller: controllers!['password2']!,
                        showError:
                            currentConfirmPassword.isNotEmpty && !_isSamePassword,
                        onChanged: (value) {
                          setState(() {
                            currentConfirmPassword = value;
                            _isSamePassword = value == _currentPassword;
                          });
                        },
                      ),
                    ),
                    if (currentConfirmPassword.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          _isSamePassword
                              ? 'Las contraseñas coinciden'
                              : 'Las contraseñas no coinciden',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isSamePassword ? AppColors.green : Colors.red,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),
                    _LabelSection('Localidad'),
                    _Field(child: _locationSelector()),

                    const SizedBox(height: 16),
                    _LabelSection('Legal'),
                    _CheckLegal(
                      checked: _termsChecked,
                      onChanged: (v) =>
                          setState(() => _termsChecked = v ?? false),
                      normal: 'Acepto los ',
                      link: 'Términos y Condiciones',
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        LegalDialog.show(context, isPrivacy: false);
                      },
                    ),
                    const SizedBox(height: 6),
                    _CheckLegal(
                      checked: _privacyChecked,
                      onChanged: (v) =>
                          setState(() => _privacyChecked = v ?? false),
                      normal: 'Acepto la ',
                      link: 'Política de Privacidad',
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        LegalDialog.show(context, isPrivacy: true);

                      },
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border, width: 1.5),
                              ),
                              child: const Center(
                                child: Text(
                                  'Volver',
                                  style: TextStyle(
                                    fontFamily: 'RobotoCondensed',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSoft,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (await registerUser()) {
                                Navigator.pop(context);
                                AlertModal.show(
                                  context,
                                  message: '¡Registro completado!',
                                  type: AlertTipe.success,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text(
                                  'Registrarse',
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _LabelSection(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 2),
    child: Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'RobotoCondensed',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSoft,
        letterSpacing: 0.8,
      ),
    ),
  );

  Widget _Field({required Widget child}) => Container(
    padding: EdgeInsets.zero,
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Padding(padding: const EdgeInsets.all(10), child: child),
  );

  Widget _locationSelector() {
    return FutureBuilder<List<Location>>(
      future: futureLocations,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 40,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.green, strokeWidth: 2),
            ),
          );
        }
        return LocalitySelector(
          locations: snapshot.data!,
          onSelected: (loc) => setState(() => _locationSelected = loc),
          label: 'Localidad',
        );
      },
    );
  }

  Widget _calendarField() {
    final ctrl = controllers!['fechaNacimiento']!;

    return GestureDetector(
      onTap: () async {
        FocusScope.of(context).unfocus();

        final today = DateTime.now();
        final maxLimit = DateTime(today.year - 18, today.month, today.day);

        final date = await showDatePicker(
          context: context,
          locale: const Locale('es', 'ES'),
          initialDate: maxLimit,
          firstDate: DateTime(1900),
          lastDate: today,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.green,
                  onPrimary: AppColors.text,
                  onSurface: AppColors.text,
                  surface: AppColors.cardBg,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: AppColors.green),
                ),
                dialogBackgroundColor: AppColors.pageBg,
              ),
              child: child!,
            );
          },
        );

        if (date != null) {
          final isAdult =
              date.isBefore(maxLimit) ||
              date.isAtSameMomentAs(maxLimit);

          if (!isAdult) {
            AlertModal.show(
              context,
              message: 'Debes tener al menos 18 años para registrarte.',
              type: AlertTipe.error,
            );
            ctrl.clear();
            return;
          }
          final month = date.month.toString().padLeft(2, '0');
          final day = date.day.toString().padLeft(2, '0');
          _dateOfBirth = '${date.year}-$month-$day';
          ctrl.text = formatToSpanishDate(date);
        }
        if (_dateOfBirth.isEmpty) {
          AlertModal.show(
            context,
            message: 'El campo Fecha de nacimiento es obligatorio.',
            type: AlertTipe.error,
          );
          return;
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: ctrl,
          readOnly: true,
          style: const TextStyle(
            fontFamily: 'RobotoCondensed',
            fontSize: 13,
            color: AppColors.text,
          ),
          decoration: InputDecoration(
            labelText: 'Fecha de nacimiento',
            labelStyle: TextStyle(
              fontFamily: 'RobotoCondensed',
              fontSize: 12,
              color: AppColors.textSoft,
            ),
            filled: true,
            fillColor: AppColors.cardBg,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(
                'assets/iconos/calendario_registro.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.textSoft,
                  BlendMode.srcIn,
                ),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.green, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckLegal extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool?> onChanged;
  final String normal;
  final String link;
  final VoidCallback onTap;

  const _CheckLegal({
    required this.checked,
    required this.onChanged,
    required this.normal,
    required this.link,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: checked ? AppColors.green.withOpacity(0.6) : AppColors.border),
      ),
      child: Row(
        children: [
          Checkbox(
            value: checked,
            onChanged: onChanged,
            checkColor: AppColors.text,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            fillColor: WidgetStateProperty.resolveWith<Color?>(
              (s) => s.contains(WidgetState.selected) ? AppColors.green : null,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          Flexible(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'RobotoCondensed',
                  color: AppColors.textSoft,
                  fontSize: 13,
                ),
                children: [
                  TextSpan(text: normal),
                  TextSpan(
                    text: link,
                    style: const TextStyle(
                      color: AppColors.green,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = onTap,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
