import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kultux/componentes/text_fields.dart';
import 'package:kultux/componentes/botones.dart';
import 'package:kultux/componentes/selector_localidad.dart';
import 'package:kultux/models/localidad.dart';
import 'package:kultux/models/usuario.dart';
import 'package:kultux/api/usuariosAPI.dart';
import 'package:kultux/repository/usuario_repository.dart';
import 'package:kultux/api/localidadesApi.dart';

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

  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();

    final u = Usuario.usuarioActual;

    _controllers = {
      'nombre': TextEditingController(text: u?.nombre ?? ''),
      'apellidos': TextEditingController(text: u?.apellidos ?? ''),
      'email': TextEditingController(text: u?.email ?? ''),
      'password': TextEditingController(),
      'localidad': TextEditingController(text: u?.localidad?.toString() ?? ''),
    };

    _cargarLocalidadInicial();
  }

  /// Cargar la localidad actual del usuario para el selector
  Future<void> _cargarLocalidadInicial() async {
    final id = int.tryParse(_controllers['localidad']!.text);
    if (id == null) return;

    try {
      final lista = await LocalidadApiService.obtenerLocalidadNombres();
      if (!mounted) return;

      setState(() {
        _localidadSeleccionada =
            lista.firstWhere((l) => l.ine == id, orElse: () => _localidadSeleccionada as Localidad);
      });
    } catch (_) {
      // si falla, simplemente no se preselecciona
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Selector de imagen ─────────────────────────────────────────────
  Future<void> _abrirSelectorImagen() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galería'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                );
                if (picked != null && mounted) {
                  setState(() {
                    _imagenSeleccionada = File(picked.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Cámara'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 85,
                );
                if (picked != null && mounted) {
                  setState(() {
                    _imagenSeleccionada = File(picked.path);
                  });
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Guardar cambios ────────────────────────────────────────────────
  Future<void> _guardarCambios() async {
    final datos = <String, dynamic>{};

    void addIfNotEmpty(String key) {
      final value = _controllers[key]!.text.trim();
      if (value.isNotEmpty) datos[key] = value;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          content: Text(
            '✅ ¡Perfil actualizado correctamente!',
            textAlign: TextAlign.center,
          ),
        ),
      );

      widget.onVolver();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Error: $e')),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _avatarEditable(),
          const SizedBox(height: 24),

          CamposPersonalizados.normal(
            titulo: 'Nombre',
            controller: _controllers['nombre']!,
          ),
          const SizedBox(height: 20),

          CamposPersonalizados.normal(
            titulo: 'Apellidos',
            controller: _controllers['apellidos']!,
          ),
          const SizedBox(height: 20),

          CamposPersonalizados.normal(
            titulo: 'Correo electrónico',
            controller: _controllers['email']!,
          ),
          const SizedBox(height: 20),

          CamposPersonalizados.password(
            titulo: 'Nueva contraseña (opcional)',
            controller: _controllers['password']!,
          ),
          const SizedBox(height: 20),

          /// ✅ MISMO selector reutilizado
          SelectorLocalidad(
            valorInicial: _localidadSeleccionada,
            onSelected: (loc) {
              setState(() {
                _localidadSeleccionada = loc;
                _controllers['localidad']!.text =
                    loc?.ine.toString() ?? '';
              });
            },
          ),

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BotonesGenerico(
                titulo: 'Guardar',
                ancho: 127,
                pulsar: _guardarCambios,
              ),
              const SizedBox(width: 50),
              BotonesGenerico(
                titulo: 'Volver',
                ancho: 127,
                pulsar: widget.onVolver,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Avatar editable ────────────────────────────────────────────────
  Widget _avatarEditable() {
    return GestureDetector(
      onTap: _abrirSelectorImagen,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 64,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: _imagenSeleccionada != null
                ? FileImage(_imagenSeleccionada!)
                : (Usuario.usuarioActual!.imagenPerfil != null &&
                Usuario.usuarioActual!.imagenPerfil!.isNotEmpty
                ? NetworkImage(Usuario.usuarioActual!.imagenPerfil!)
                : null) as ImageProvider?,
            child: _imagenSeleccionada == null
                ? const Icon(Icons.person,
                size: 64, color: Colors.grey)
                : null,
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 166, 226, 70),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit,
                size: 18, color: Colors.black),
          ),
        ],
      ),
    );
  }
}