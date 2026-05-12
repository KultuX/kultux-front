import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kultux/componentes/text_fields.dart';
import 'package:kultux/models/localidad.dart';
import 'package:kultux/models/usuario.dart';
import 'package:kultux/api/usuariosAPI.dart';
import 'package:kultux/repository/usuario_repository.dart';
import 'package:kultux/api/localidadesApi.dart';
import 'componentes/selector_localidad.dart';

const _verde = Color(0xFFA6E246);
const _fondoPagina = Color(0xFFF1EFE9);
const _fondoCard = Color(0xFFF8F7F4);
const _texto = Color(0xFF1A1A1A);
const _textoSuave = Color(0xFF6B6B6B);
const _borde = Color(0xFFE0DDD6);

class EditarPerfilPage extends StatefulWidget {
  final VoidCallback onVolver;
  const EditarPerfilPage({super.key, required this.onVolver});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  Localidad? _localidadSeleccionada;
  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();
  Key _selectorLocalidadKey = UniqueKey();

  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final u = Usuario.usuarioActual;
    _controllers = {
      'nombre':    TextEditingController(text: u?.nombre ?? ''),
      'apellidos': TextEditingController(text: u?.apellidos ?? ''),
      'email':     TextEditingController(text: u?.email ?? ''),
      'password':  TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  Widget _selectorLocalidad() {
    return FutureBuilder<List<Localidad>>(
      future: LocalidadApiService.cache != null
          ? Future.value(LocalidadApiService.cache)
          : LocalidadApiService.obtenerLocalidadNombres(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(
                color: _verde, strokeWidth: 2)),
          );
        }
        return SelectorLocalidad(
          key: _selectorLocalidadKey,
          localidades: snapshot.data!,
          ineInicial: Usuario.usuarioActual?.localidad,
          onSelected: (loc) => setState(() => _localidadSeleccionada = loc),
        );
      },
    );
  }

  Future<void> _guardarCambios() async {
    final datos = <String, dynamic>{};
    void addIfNotEmpty(String key) {
      final v = _controllers[key]!.text.trim();
      if (v.isNotEmpty) datos[key] = v;
    }
    addIfNotEmpty('nombre');
    addIfNotEmpty('apellidos');
    addIfNotEmpty('email');
    addIfNotEmpty('password');
    if (_localidadSeleccionada != null) {
      datos['localidad'] = _localidadSeleccionada!.ine;
    }

    try {
      final actualizado = await UsuarioApiService.editarUsuario(
        id: Usuario.usuarioActual!.id!,
        datos: datos,
        imagen: _imagenSeleccionada,
      );
      await UsuarioRepository.guardar(actualizado);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        showCloseIcon: true,
        content: Text('✅ ¡Perfil actualizado correctamente!',
            textAlign: TextAlign.center),
      ));
      widget.onVolver();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Error: $e')));
    }
  }

  Future<void> _abrirSelectorImagen() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: _fondoCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: _borde,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _BottomSheetOpcion(
                    icono: Icons.photo_library_outlined,
                    texto: 'Seleccionar de la galería',
                    onTap: () async {
                      Navigator.pop(context);
                      final p = await _picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 85);
                      if (p != null && mounted) {
                        setState(() => _imagenSeleccionada = File(p.path));
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  _BottomSheetOpcion(
                    icono: Icons.camera_alt_outlined,
                    texto: 'Tomar una foto',
                    onTap: () async {
                      Navigator.pop(context);
                      final p = await _picker.pickImage(
                          source: ImageSource.camera, imageQuality: 85);
                      if (p != null && mounted) {
                        setState(() => _imagenSeleccionada = File(p.path));
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
    return Container(
      color: _fondoPagina,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
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
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFFb0b0b0))),
                      const SizedBox(height: 2),
                      const Text('Editar perfil',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
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
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: _fondoCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borde),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _abrirSelectorImagen,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 88, height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _verde, width: 3),
                          ),
                          child: ClipOval(
                            child: _imagenSeleccionada != null
                                ? Image.file(_imagenSeleccionada!,
                                fit: BoxFit.cover)
                                : (Usuario.usuarioActual?.imagenPerfil != null &&
                                Usuario.usuarioActual!.imagenPerfil!
                                    .isNotEmpty)
                                ? Image.network(
                                Usuario.usuarioActual!.imagenPerfil!,
                                fit: BoxFit.cover)
                                : Image.asset(
                                'assets/images/logo_registro.png',
                                fit: BoxFit.cover),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: _verde, shape: BoxShape.circle),
                          child: const Icon(Icons.edit,
                              size: 16, color: _texto),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Usuario.usuarioActual?.nombre ?? '',
                    style: const TextStyle(
                        fontFamily: 'RobotoCondensed',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _texto),
                  ),
                  const SizedBox(height: 2),
                  const Text('Toca la foto para cambiarla',
                      style: TextStyle(
                          fontFamily: 'RobotoCondensed',
                          fontSize: 12,
                          color: _textoSuave)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SeccionLabel('Datos personales'),
                  _Campo(child: CamposPersonalizados.normal(
                      titulo: 'Nombre',
                      controller: _controllers['nombre']!)),
                  const SizedBox(height: 10),
                  _Campo(child: CamposPersonalizados.normal(
                      titulo: 'Apellidos',
                      controller: _controllers['apellidos']!)),

                  const SizedBox(height: 16),
                  _SeccionLabel('Cuenta'),
                  _Campo(child: CamposPersonalizados.normal(
                      titulo: 'Correo electrónico',
                      controller: _controllers['email']!,
                      tipo: TextInputType.emailAddress)),
                  const SizedBox(height: 10),
                  _Campo(child: CamposPersonalizados.password(
                      titulo: 'Nueva contraseña (opcional)',
                      controller: _controllers['password']!)),

                  const SizedBox(height: 16),
                  _SeccionLabel('Ubicación'),
                  _Campo(child: _selectorLocalidad()),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onVolver,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _borde, width: 1.5),
                            ),
                            child: const Center(
                              child: Text('Volver',
                                  style: TextStyle(
                                      fontFamily: 'RobotoCondensed',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _textoSuave)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: _guardarCambios,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _verde,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text('Guardar cambios',
                                  style: TextStyle(
                                      fontFamily: 'RobotoCondensed',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _texto)),
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
      ),
    );
  }
}
Widget _SeccionLabel(String label) => Padding(
  padding: const EdgeInsets.only(bottom: 8, top: 2, left: 2),
  child: Text(
    label.toUpperCase(),
    style: const TextStyle(
      fontFamily: 'RobotoCondensed',
      fontSize: 11, fontWeight: FontWeight.w600,
      color: _textoSuave, letterSpacing: 0.8,
    ),
  ),
);

Widget _Campo({required Widget child}) => Container(
  margin: const EdgeInsets.only(bottom: 0),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _borde),
  ),
  child: Padding(padding: const EdgeInsets.all(10), child: child),
);

class _BottomSheetOpcion extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback onTap;

  const _BottomSheetOpcion({
    required this.icono,
    required this.texto,
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
              child: Icon(icono, size: 16, color: _verde),
            ),
            const SizedBox(width: 12),
            Text(texto,
                style: const TextStyle(
                    fontFamily: 'RobotoCondensed',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _texto)),
          ],
        ),
      ),
    );
  }
}