import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/componentes/botones.dart';
import 'package:kultux/editar_perfil.dart';
import 'package:kultux/models/usuario.dart';
import 'package:kultux/api/usuariosAPI.dart';
import 'package:kultux/repository/usuario_repository.dart';
import 'package:kultux/componentes/terminos_condiciones_dialog.dart';
import 'package:kultux/componentes/politica_privacidad_dialog.dart';

const _verde = Color(0xFFA6E246);
const _fondoPagina = Color(0xFFF1EFE9);
const _fondoCard = Color(0xFFF8F7F4);
const _texto = Color(0xFF1A1A1A);
const _textoSuave = Color(0xFF6B6B6B);
const _borde = Color(0xFFE0DDD6);

class PerfilPage extends StatefulWidget {
  final VoidCallback cerrarSesion;
  final Usuario? usuario;
  const PerfilPage({super.key, required this.cerrarSesion, this.usuario});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  bool _editandoPerfil = false;

  final _opciones = {
    'Editar perfil':            ('assets/iconos/editar_perfil.svg',      'ajustes'),
    'Guardados':                ('assets/iconos/guardados.svg',           'ajustes'),
    'Notificaciones activadas': ('assets/iconos/sin_notificaciones.svg',  'ajustes'),
    'Contacta con nosotros':    ('assets/iconos/contactar_nosotros.svg',  'soporte'),
    'Términos y condiciones':   ('assets/iconos/terminos_condiciones.svg','soporte'),
    'Política de privacidad':   ('assets/iconos/politica_privacidad.svg', 'soporte'),
  };

  @override
  Widget build(BuildContext context) {
    if (_editandoPerfil) {
      return EditarPerfilPage(
        onVolver: () => setState(() => _editandoPerfil = false),
      );
    }

    return Container(
      color: _fondoPagina,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderBanner(),
            _TarjetaAvatar(),
            _SeccionLabel('Ajustes'),
            ..._opciones.entries
                .where((e) => e.value.$2 == 'ajustes')
                .map((e) => _OpcionTile(
              texto: e.key,
              icono: e.value.$1,
              notif: e.key == 'Notificaciones activadas',
              onTap: () => _manejarOpcion(e.key),
            )),
            _SeccionLabel('Soporte'),
            ..._opciones.entries
                .where((e) => e.value.$2 == 'soporte')
                .map((e) => _OpcionTile(
              texto: e.key,
              icono: e.value.$1,
              onTap: () => _manejarOpcion(e.key),
            )),
            const SizedBox(height: 20),
            _BotonesAccion(
              onCerrar: _confirmarCerrarSesion,
              onEliminar: _confirmarEliminarCuenta,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _manejarOpcion(String texto) {
    switch (texto) {
      case 'Editar perfil':
        setState(() => _editandoPerfil = true);
      case 'Contacta con nosotros':
        _mostrarContacto();
      case 'Términos y condiciones':
        TerminosCondicionesDialog.mostrar(context);
      case 'Política de privacidad':
        PoliticaPrivacidadDialog.mostrar(context);
      default:
        _mostrarProximamente();
    }
  }


  Widget _HeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0, right: 0,
            child: Opacity(
              opacity: 0.12,
              child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  color: _verde,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mi cuenta',
                  style: TextStyle(fontSize: 12, color: Color(0xFFb0b0b0))),
              const SizedBox(height: 2),
              const Text('Perfil',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 6),
              Container(
                width: 36, height: 2,
                decoration: BoxDecoration(
                  color: _verde,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _TarjetaAvatar() {
    final usuario = Usuario.usuarioActual ?? widget.usuario;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: _fondoCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borde),
      ),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _verde, width: 3),
            ),
            child: ClipOval(
              child: (usuario?.imagenPerfil != null && usuario!.imagenPerfil!.isNotEmpty)
                  ? Image.network(usuario.imagenPerfil!, fit: BoxFit.cover)
                  : Image.asset('assets/images/logo_registro.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            usuario?.nombre ?? 'Nombre usuario',
            style: const TextStyle(
              fontFamily: 'RobotoCondensed',
              fontSize: 18, fontWeight: FontWeight.w700, color: _texto,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            usuario?.email ?? 'correo@correo.com',
            style: const TextStyle(
              fontFamily: 'RobotoCondensed', fontSize: 13, color: _textoSuave,
            ),
          ),
        ],
      ),
    );
  }

  Widget _SeccionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'RobotoCondensed',
          fontSize: 11, fontWeight: FontWeight.w600,
          color: _textoSuave, letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _OpcionTile({
    required String texto,
    required String icono,
    required VoidCallback onTap,
    bool notif = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: _fondoCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borde),
        ),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: _texto,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: SvgPicture.asset(
                  icono, width: 16, height: 16,
                  colorFilter: const ColorFilter.mode(_verde, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                texto,
                style: const TextStyle(
                  fontFamily: 'RobotoCondensed',
                  fontSize: 14, fontWeight: FontWeight.w500, color: _texto,
                ),
              ),
            ),
            if (notif)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _verde,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('ON',
                    style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700, color: _texto)),
              )
            else
              SvgPicture.asset('assets/iconos/flecha_siguiente.svg',
                  width: 16, height: 16,
                  colorFilter: const ColorFilter.mode(_textoSuave, BlendMode.srcIn)),
          ],
        ),
      ),
    );
  }

  Widget _BotonesAccion({
    required VoidCallback onCerrar,
    required VoidCallback onEliminar,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onCerrar,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _verde,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('Cerrar sesión',
                      style: TextStyle(
                          fontFamily: 'RobotoCondensed',
                          fontSize: 14, fontWeight: FontWeight.w700, color: _texto)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onEliminar,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFC62828), width: 1.5),
                ),
                child: const Center(
                  child: Text('Eliminar cuenta',
                      style: TextStyle(
                          fontFamily: 'RobotoCondensed',
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: Color(0xFFC62828))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _mostrarContacto() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 166, 226, 70),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.black, fontSize: 14),
                        children: [
                          const TextSpan(text: '1: '),
                          TextSpan(
                            text: 'smmoninog01@iesalbarregas.es',
                            style: const TextStyle(
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
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.black, fontSize: 14),
                        children: [
                          const TextSpan(text: '2: '),
                          TextSpan(
                            text: 'cmaciasi01@iesalbarregas.es',
                            style: const TextStyle(
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
                      backgroundColor: const Color.fromARGB(255, 166, 226, 70),
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
        );
      },
    );
  }

  Future<void> _confirmarCerrarSesion() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar sesión', textAlign: TextAlign.center),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 16),
              const Text('¿Estás segur@ de que quieres cerrar sesión?', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  BotonesGenerico(
                    titulo: 'Cerrar sesión',
                    ancho: 120,
                    pulsar: () {
                      Navigator.of(context).pop();
                      widget.cerrarSesion();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _textoConLink({required String normal, required String link}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontFamily: 'RobotoCondensed', color: Colors.black, fontSize: 14),
        children: [
          TextSpan(text: normal),
          TextSpan(
            text: link,
            style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarProximamente() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 166, 226, 70),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction, size: 60, color: Colors.black),
              const SizedBox(height: 20),
              const Text('Próximamente', style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const CircularProgressIndicator(color: Colors.white),
              const CircularProgressIndicator(
                  color: Color.fromARGB(255, 166, 226, 70)
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmarEliminarCuenta() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar cuenta', textAlign: TextAlign.center),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🗑️', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 16),
              const Text(
                '¿Estás segur@ de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _eliminarCuenta();
                      },
                      child: const Text('Eliminar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _eliminarCuenta() async {
    try {
      await UsuarioApiService.eliminarUsuario(Usuario.usuarioActual!.id!);
      await UsuarioRepository.cerrarSesion();

      if (!mounted) return;
      widget.cerrarSesion();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          content: Text('✅ Cuenta eliminada correctamente.', textAlign: TextAlign.center),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Error al eliminar la cuenta: $e')),
      );
    }
  }
}