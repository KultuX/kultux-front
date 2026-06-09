import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kultux/shared/widget/text_fields.dart';
import 'package:kultux/core/models/location.dart';
import 'package:kultux/core/models/user.dart';
import 'package:kultux/data/api/user_api.dart';
import 'package:kultux/data/repository/user_repository.dart';
import 'package:kultux/data/api/location_api.dart';
import 'package:kultux/config/app_colors.dart';
import 'package:kultux/shared/widget/locality_selector.dart';
import 'package:kultux/shared/widget/alert_modal.dart';
import 'package:kultux/core/utils/validations.dart';



class EditProfilePage extends StatefulWidget {
  final VoidCallback onBack;
  final User? user;
  const EditProfilePage({super.key, required this.onBack, this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  Location? _selectedLocation;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  Key _selectorLocationKey = UniqueKey();

  late final Map<String, TextEditingController> _controllers;
  dynamic u;

  bool _validPasswordStatus = false;
  String _currentPassword = '';

  bool _emailValidStatus = false;
  String _currentEmail = '';

  String? _errorEmailAPI;

  String? _errorImage;

  @override
  void initState() {
    super.initState();
    u = User.activeUser ?? widget.user;
    _controllers = {
      'nombre': TextEditingController(text: u?.name ?? ''),
      'apellidos': TextEditingController(text: u?.surname ?? ''),
      'email': TextEditingController(text: u?.email ?? ''),
      'password': TextEditingController(),
    };
    _selectorLocationKey = UniqueKey();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _locationSelector() {
    final locations = LocationApiService.cache ?? [];
    return LocalitySelector(
      key: _selectorLocationKey,
      locations: locations,
      startLocation: User.activeUser?.location,
      onSelected: (loc) => setState(() => _selectedLocation = loc),
    );
  }

  Future<void> _processImageSelected(XFile? p) async {
    if (p == null || !mounted) return;

    final file = File(p.path);
    final sizeBytes = await file.length();
    final sizeMegabytes = sizeBytes / (1024 * 1024);

    setState(() {
      if (sizeMegabytes > 2.0) {
        _errorImage = 'La imagen debe pesar menos de 2 MB';
        _selectedImage = null;
      } else {
        _errorImage = null;
        _selectedImage = file;
      }
    });
  }

  Future<void> _saveChanges() async {
    final password = _controllers['password']!.text.trim();
    final email = _controllers['email']!.text.trim();

    if (Validations.emailError(email) != null) {
      AlertModal.show(
        context,
        message: Validations.emailError(email)!,
        type: AlertTipe.error,
      );
      return;
    }

    if (Validations.passwordError(password) != null) {
      AlertModal.show(
        context,
        message: Validations.passwordError(password)!,
        type: AlertTipe.error,
      );
      return;
    }

    final data = <String, dynamic>{};
    void addIfNotEmpty(String key) {
      final v = _controllers[key]!.text.trim();
      if (v.isNotEmpty) data[key] = v;
    }

    addIfNotEmpty('nombre');
    addIfNotEmpty('apellidos');
    addIfNotEmpty('email');
    addIfNotEmpty('password');
    
    if (_selectedLocation != null) {
      data['localidad'] = _selectedLocation!.ine;
    }

    try {
      final update = await UserApiService.editUser(
        id: User.activeUser!.id!,
        data: data,
        image: _selectedImage,
      );
      if (await UserRepository.activeSession())
        await UserRepository.save(update);
      User.activeUser = update;
      if (!mounted) return;
      AlertModal.show(
        context,
        message: '¡Perfil actualizado correctamente!',
        type: AlertTipe.success,
      );

      setState(() {
        u = update;
        _selectorLocationKey = UniqueKey();
      });
      widget.onBack();
    } catch (e) {
      if (!mounted) return;

      final errorStr = e.toString();

      if (errorStr.contains('409')) {
        setState(() {
          _errorEmailAPI = 'Este correo ya está en uso';
        });
        return;
      }

      AlertModal.show(
        context,
        message: 'Algo ha salido mal. Prueba a intentarlo más tarde.',
        type: AlertTipe.error,
      );
    }
  }

  Future<void> _openImageSelector() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _BottomSheetOpcion(
                    icon: Icons.photo_library_outlined,
                    text: 'Seleccionar de la galería',
                    onTap: () async {
                      Navigator.pop(context);
                      final p = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                      );
                      await _processImageSelected(p);
                      if (p != null && mounted) {
                        setState(() => _selectedImage = File(p.path));
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  _BottomSheetOpcion(
                    icon: Icons.camera_alt_outlined,
                    text: 'Tomar una foto',
                    onTap: () async {
                      Navigator.pop(context);
                      final p = await _picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 85,
                      );
                      await _processImageSelected(p);
                      if (p != null && mounted) {
                        setState(() => _selectedImage = File(p.path));
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = User.activeUser ?? widget.user;
    final errorEmail = _errorEmailAPI ?? Validations.emailError(_currentEmail);
    final isValidEmail = errorEmail == null;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _openImageSelector,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.green, width: 3),
                        ),
                        child: ClipOval(
                          child: _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                )
                              : (u?.profileImage != null &&
                                    u!.profileImage!.isNotEmpty)
                              ? Image.network(
                                  u.profileImage!,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/logo_registro.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 16, color: AppColors.text),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  u?.name ?? '',
                  style: const TextStyle(
                    fontFamily: 'RobotoCondensed',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Toca la foto para cambiarla',
                  style: TextStyle(
                    fontFamily: 'RobotoCondensed',
                    fontSize: 12,
                    color: AppColors.textSoft,
                  ),
                ),
                if (_errorImage != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _errorImage!,
                    style: const TextStyle(
                      fontFamily: 'RobotoCondensed',
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _labelSection('Datos personales'),
                _field(
                  child: TextFieldApp.normal(
                    title: 'Nombre',
                    controller: _controllers['nombre']!,
                  ),
                ),
                const SizedBox(height: 10),
                _field(
                  child: TextFieldApp.normal(
                    title: 'Apellidos',
                    controller: _controllers['apellidos']!,
                  ),
                ),

                const SizedBox(height: 16),
                _labelSection('Cuenta'),

                _field(
                  child: TextFieldApp.normal(
                    title: 'Correo electrónico',
                    controller: _controllers['email']!,
                    type: TextInputType.emailAddress,
                    showError: _currentEmail.isNotEmpty && !isValidEmail,
                    onChanged: (value) {
                      setState(() {
                        _currentEmail = value;
                        _emailValidStatus = Validations.email(value);
                        _errorEmailAPI = null;
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
                        color: isValidEmail ? AppColors.green : Colors.red,
                      ),
                    ),
                  ),

                const SizedBox(height: 10),
                _field(
                  child: TextFieldApp.password(
                    title: 'Nueva contraseña (opcional)',
                    controller: _controllers['password']!,
                    showError:
                        _currentPassword.isNotEmpty && !_validPasswordStatus,
                    onChanged: (value) {
                      setState(() {
                        _currentPassword = value;
                        _validPasswordStatus = Validations.password(value);
                      });
                    },
                  ),
                ),

                if (_currentPassword.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      Validations.passwordError(_currentPassword) ??
                          'Contraseña válida ',
                      style: TextStyle(
                        fontSize: 12,
                        color: _validPasswordStatus ? AppColors.green : Colors.red,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
                _labelSection('Ubicación'),
                _field(child: _locationSelector()),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: widget.onBack,
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
                        onTap: _saveChanges,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'Guardar cambios',
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
        ],
      ),
    );
  }
}

Widget _labelSection(String label) => Padding(
  padding: const EdgeInsets.only(bottom: 8, top: 2, left: 2),
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

Widget _field({required Widget child}) => Container(
  margin: const EdgeInsets.only(bottom: 0),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.border),
  ),
  child: Padding(padding: const EdgeInsets.all(10), child: child),
);

class _BottomSheetOpcion extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _BottomSheetOpcion({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.text,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: AppColors.green),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'RobotoCondensed',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
