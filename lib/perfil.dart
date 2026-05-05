import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/componentes/botones.dart';
import 'package:kultux/editar_perfil.dart';
import 'package:kultux/models/usuario.dart';
import 'package:kultux/api/usuariosAPI.dart';
import 'package:kultux/repository/usuario_repository.dart';
import 'package:kultux/componentes/terminos_condiciones_dialog.dart';
import 'package:kultux/componentes/politica_privacidad_dialog.dart';

class PerfilPage extends StatefulWidget {
  final VoidCallback cerrarSesion;
  final Usuario? usuario;
  const PerfilPage({super.key, required this.cerrarSesion, this.usuario});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {

  // ── Control de vista ───────────────────────────────────────────────────────
  bool _editandoPerfil = false;

  final _opciones = {
    'Editar perfil': 'assets/iconos/editar_perfil.svg',
    'Guardados': 'assets/iconos/guardados.svg',
    'Notificaciones activadas': 'assets/iconos/sin_notificaciones.svg',
    'Contacta con nosotros': 'assets/iconos/contactar_nosotros.svg',
    'Términos y condiciones': 'assets/iconos/terminos_condiciones.svg',
    'Política de privacidad': 'assets/iconos/politica_privacidad.svg',
  };

  @override
  Widget build(BuildContext context) {
    // ── Si estamos editando, mostramos EditarPerfilPage dentro del Scaffold ──
    if (_editandoPerfil) {
      return EditarPerfilPage(
        onVolver: () => setState(() => _editandoPerfil = false),
      );
    }

    // ── Vista normal del perfil ────────────────────────────────────────────
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 90,
                    backgroundImage: (Usuario.usuarioActual?.imagenPerfil != null &&
                        Usuario.usuarioActual!.imagenPerfil!.isNotEmpty)
                        ? NetworkImage(Usuario.usuarioActual!.imagenPerfil!)
                        : const AssetImage("assets/images/logo_registro.png") as ImageProvider,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Usuario.usuarioActual?.nombre ?? widget.usuario?.nombre ?? 'Nombre usuario',
                    style: const TextStyle(fontFamily: 'RobotoCondensed', fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Usuario.usuarioActual?.email ?? widget.usuario?.email ?? 'correo@correo.com',
                    style: const TextStyle(fontFamily: 'RobotoCondensed'),
                  ),
                ],
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _opciones.length,
            itemBuilder: (context, index) {
              final texto = _opciones.keys.elementAt(index);
              final icono = _opciones.values.elementAt(index);
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: SvgPicture.asset(
                    icono,
                    colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  ),
                  title: Text(texto),
                  trailing: SvgPicture.asset("assets/iconos/flecha_siguiente.svg"),
                  onTap: () {
                    if (texto == 'Editar perfil') {
                      setState(() => _editandoPerfil = true);
                    } else if (texto == 'Contacta con nosotros') {
                      _mostrarContacto();
                    } else if (texto == 'Términos y condiciones') {
                      TerminosCondicionesDialog.mostrar(context);
                    } else if (texto == 'Política de privacidad') {  // ← nuevo
                      PoliticaPrivacidadDialog.mostrar(context);
                    } else {
                      _mostrarProximamente();
                    }
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BotonesGenerico(
                titulo: "Cerrar sesión",
                pulsar: _confirmarCerrarSesion,
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: _confirmarEliminarCuenta,
                child: const Text('Eliminar cuenta'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Dialogs (sin cambios) ──────────────────────────────────────────────────

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

              // ── Cabecera ──────────────────────────────────────────────
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

              // ── Contenido ─────────────────────────────────────────────
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

              // ── Botón Cerrar ──────────────────────────────────────────
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