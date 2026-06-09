import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/features/profile/edit_profile_page.dart';
import 'package:kultux/core/models/user.dart';
import 'package:kultux/data/api/user_api.dart';
import 'package:kultux/data/repository/user_repository.dart';
import 'package:kultux/shared/widget/legal_dialog.dart';
import 'package:kultux/shared/widget/alert_modal.dart';
import 'package:kultux/shared/widget/page_header.dart';

import 'package:kultux/config/app_colors.dart';



class ProfilePage extends StatefulWidget {
  final VoidCallback logout;
  final User? user;
  final VoidCallback onBack;

  const ProfilePage({
    super.key,
    required this.logout,
    this.user,
    required this.onBack,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _editingProfile = false;

  final options = {
    'Editar perfil': ('assets/iconos/editar_perfil.svg', 'ajustes'),
    'Contacta con nosotros': (
      'assets/iconos/contactar_nosotros.svg',
      'soporte',
    ),
    'Términos y condiciones': (
      'assets/iconos/terminos_condiciones.svg',
      'soporte',
    ),
    'Política de privacidad': (
      'assets/iconos/politica_privacidad.svg',
      'soporte',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.pageBg,
      child: Column(
        children: [
          PageHeader(
            title: _editingProfile ? 'Editar perfil' : 'Perfil',
            subtitle: 'Mi cuenta',
            onBack: _editingProfile
                ? () {
                    setState(() {
                      _editingProfile = false;
                    });
                  }
                : widget.onBack,
          ),

          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_editingProfile) {
      return EditProfilePage(
        onBack: () {
          setState(() {
            _editingProfile = false;
          });
        },
        user: widget.user ?? User.activeUser,
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ImageCard(),
          _labelSection('Ajustes'),

          ...options.entries
              .where((e) => e.value.$2 == 'ajustes')
              .map(
                (e) => _optionTile(
                  texto: e.key,
                  icono: e.value.$1,
                  onTap: () => _selectOption(e.key),
                ),
              ),

          _labelSection('Soporte'),

          ...options.entries
              .where((e) => e.value.$2 == 'soporte')
              .map(
                (e) => _optionTile(
                  texto: e.key,
                  icono: e.value.$1,
                  onTap: () => _selectOption(e.key),
                ),
              ),

          const SizedBox(height: 20),

          _actionButtons(
            onClose: _confirmLogout,
            onDelete: _confirmDeleteAccount,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _selectOption(String texto) {
    switch (texto) {
      case 'Editar perfil':
        setState(() => _editingProfile = true);
        return;
      case 'Contacta con nosotros':
        _showContact();
        return;
      case 'Términos y condiciones':
        LegalDialog.show(context,isPrivacy: false);
        return;
      case 'Política de privacidad':
        LegalDialog.show(context, isPrivacy: true);
        return;
      default:
        return;
    }
  }

  Widget _ImageCard() {
    final usuario = User.activeUser ?? widget.user;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.green, width: 3),
            ),
            child: ClipOval(
              child:
                  (usuario?.profileImage != null &&
                      usuario!.profileImage!.isNotEmpty)
                  ? Image.network(usuario.profileImage!, fit: BoxFit.cover)
                  : Image.asset(
                      'assets/images/logo_registro.png',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            usuario?.name ?? 'Nombre usuario',
            style: const TextStyle(
              fontFamily: 'RobotoCondensed',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            usuario?.email ?? 'correo@correo.com',
            style: const TextStyle(
              fontFamily: 'RobotoCondensed',
              fontSize: 13,
              color: AppColors.textSoft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelSection(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 16, 6),
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
  }

  Widget _optionTile({
    required String texto,
    required String icono,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
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
              child: Center(
                child: SvgPicture.asset(
                  icono,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(AppColors.green, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                texto,
                style: const TextStyle(
                  fontFamily: 'RobotoCondensed',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
            ),
            SvgPicture.asset(
              'assets/iconos/flecha_siguiente.svg',
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(AppColors.textSoft, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButtons({
    required VoidCallback onClose,
    required VoidCallback onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'Cerrar sesión',
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
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFC62828),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Eliminar cuenta',
                    style: TextStyle(
                      fontFamily: 'RobotoCondensed',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC62828),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showContact() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          child: SizedBox(
            width:
                360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 166, 226, 70),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/iconos/contactar_nosotros.svg",
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Contacta con nosotros',
                          style: TextStyle(
                            fontFamily: 'RobotoCondensed',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.black),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Si tienes cualquier duda o sugerencia, pueden contactarnos en los siguientes correos electrónicos:',
                        style: TextStyle(
                          fontFamily: 'RobotoCondensed',
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'RobotoCondensed',
                            color: Colors.black,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(text: '1: '),
                            TextSpan(
                              text: 'smmoninog01@iesalbarregas.es',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'RobotoCondensed',
                            color: Colors.black,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(text: '2: '),
                            TextSpan(
                              text: 'cmaciasi01@iesalbarregas.es',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          166,
                          226,
                          70,
                        ),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cerrar',
                        style: TextStyle(
                          fontFamily: 'RobotoCondensed',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.pageBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border),
          ),
          child: SizedBox(
            width: 360,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.logout, size: 50, color: AppColors.green),
                  const SizedBox(height: 12),
                  const Text(
                    'Cerrar sesión',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'RobotoCondensed',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¿Estás segur@ de que quieres cerrar sesión?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'RobotoCondensed',
                      fontSize: 13,
                      color: AppColors.textSoft,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontFamily: 'RobotoCondensed',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.logout();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Cerrar sesión',
                                style: TextStyle(
                                  fontFamily: 'RobotoCondensed',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteAccount() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.pageBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFC62828)),
          ),
          child: SizedBox(
            width: 360,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.delete_forever,
                    size: 50,
                    color: Color(0xFFC62828),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Eliminar cuenta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'RobotoCondensed',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Esta acción no se puede deshacer. Se eliminarán todos tus datos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'RobotoCondensed',
                      fontSize: 13,
                      color: AppColors.textSoft,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontFamily: 'RobotoCondensed',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
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
                            Navigator.of(context).pop();
                            await _deleteAccount();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC62828),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Eliminar',
                                style: TextStyle(
                                  fontFamily: 'RobotoCondensed',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      await UserApiService.deleteUser(User.activeUser!.id!);
      await UserRepository.closeSession();

      if (!mounted) return;
      widget.logout();
      AlertModal.show(
        context,
        message: 'Cuenta eliminada correctamente.',
        type: AlertTipe.success,
      );
    } catch (e) {
      if (!mounted) return;
      AlertModal.show(
        context,
        message: 'Error al eliminar la cuenta',
        type: AlertTipe.error,
      );
    }
  }
}
