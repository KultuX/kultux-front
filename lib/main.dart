import 'package:flutter/material.dart';
import 'package:kultux/api/actividadesAPI.dart';
import 'package:kultux/componentes/bottom_nav.dart';
import 'package:kultux/componentes/app_bar.dart';
import 'package:kultux/componentes/asset_login.dart';
import 'package:kultux/mapas.dart';
import 'package:kultux/perfil.dart';
import 'package:kultux/buscar.dart';
import 'package:kultux/tarjetas.dart';
import 'package:kultux/establecimientos.dart';
import 'package:kultux/detalles.dart';
import 'package:kultux/models/actividad.dart';
import 'package:kultux/models/usuario.dart';
import 'package:kultux/notificaciones.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KultuX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _logeado = false;
  int _indexActual = 0;
  bool _invitado = false;
  Usuario? usuario;

  bool _mostrarNotificaciones = false;

  late Future<List<Actividad>> _futureActividades;

  bool _mostrandoDetalleInicio = false;
  Actividad? _actividadDetalleSeleccionada;

  bool _mostrandoDetalleEstablecimiento = false;
  dynamic _establecimientoDetalleSeleccionado;

  @override
  void initState() {
    super.initState();
    _futureActividades = ActividadesApiService.obtenerActividadesDestacadas();
  }

  void _cerrarSesion() {
    setState(() {
      _logeado = false;
      _invitado = false;
      _indexActual = 0;
      _mostrandoDetalleInicio = false;
      _actividadDetalleSeleccionada = null;
      _mostrandoDetalleEstablecimiento = false;
      _establecimientoDetalleSeleccionado = null;
    });
  }

  void _abrirDetalleActividad(Actividad actividad) {
    setState(() {
      _actividadDetalleSeleccionada = actividad;
      _mostrandoDetalleInicio = true;
    });
  }

  void _volverAListadoInicio() {
    setState(() {
      _mostrandoDetalleInicio = false;
      _actividadDetalleSeleccionada = null;
    });
  }

  void _abrirDetalleEstablecimiento(dynamic objeto) {
    setState(() {
      _establecimientoDetalleSeleccionado = objeto;
      _mostrandoDetalleEstablecimiento = true;
    });
  }

  void _volverAListadoEstablecimientos() {
    setState(() {
      _mostrandoDetalleEstablecimiento = false;
      _establecimientoDetalleSeleccionado = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> paginas = [
      _bodyInicio(),
      MapasPage(),
      BuscarPage(),
      _bodyEstablecimientos(),
      PerfilPage(cerrarSesion: _cerrarSesion, usuario: usuario),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarPersonalizado(
        logeado: !_logeado ? true : _invitado,
        mostrar: _mostrarNotificaciones,
        notificaciones: () {
          setState(() {
            _mostrarNotificaciones = !_mostrarNotificaciones;
          });
        },
      ),
      body: _mostrarNotificaciones
          ? NotificacionesPage(mostrar:_mostrarNotificaciones) // 🔹 muestra notificaciones
          : (
              _indexActual == 0 && !_logeado && !_invitado
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        paginas[_indexActual],
                        if (!_logeado && !_invitado)
                          AssetLogin(
                            cerrar: () {
                              setState(() {
                                _logeado = true;
                                _invitado = true;
                              });
                            },
                            logeado: (Usuario logeado) {
                              setState(() {
                                _logeado = true;
                                _invitado = false;
                                usuario = logeado;
                              });
                            },
                            invitado: () {
                              setState(() {
                                _invitado = true;
                                _logeado = true;
                                _indexActual = 0;
                              });
                            },
                          ),
                      ],
                    )
                  : paginas[_indexActual]),
              bottomNavigationBar: BottomNav(
                itemSeleccionado: _indexActual,
                itemSeleccion: (index) {
                  if (!_logeado && !_invitado) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "¡Inicia sesión, registrate o entra como invitado!",
                          textAlign: .center,
                        ),
                        showCloseIcon: true,
                      ),
                    );
                    return;
                  }

                  if (index == 4 && _invitado) {
                    setState(() {
                      _invitado = false;
                      _logeado = false;
                      _indexActual = 0;
                      _mostrandoDetalleInicio = false;
                      _actividadDetalleSeleccionada = null;
                      _mostrandoDetalleEstablecimiento = false;
                      _establecimientoDetalleSeleccionado = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          showCloseIcon: true,
                          content: Text(textAlign: .center,"⚠️ ¡Inicia sesión o registrate para acceder a más funcionalidades! ⚠️")),
                    );
                    return;
                  }

                  setState(() {
                    _mostrarNotificaciones = false;
                    _indexActual = index;

                    _mostrandoDetalleInicio = false;
                    _actividadDetalleSeleccionada = null;

                    _mostrandoDetalleEstablecimiento = false;
                    _establecimientoDetalleSeleccionado = null;
                  });
                },
              ),
            );
  }

  Widget _bodyInicio() {
    if (_mostrandoDetalleInicio && _actividadDetalleSeleccionada != null) {
      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: _volverAListadoInicio,
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          Expanded(
            child: Detalle.desdeObjeto(objeto: _actividadDetalleSeleccionada!),
          ),
        ],
      );
    }

    return Center(
      child: SizedBox(
        width: 364,
        child: FutureBuilder<List<Actividad>>(
          future: _futureActividades,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error ${snapshot.error}"));
            }

            final actividades = snapshot.data;

            if (actividades == null || actividades.isEmpty) {
              return const Center(
                child: Text("No hay actividades disponibles"),
              );
            }

            return ListView.builder(
              itemCount: actividades.length,
              itemBuilder: (context, index) {
                final actividad = actividades[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Tarjeta.actividades(
                    titulo: actividad.titulo,
                    localidad: actividad.localidad,
                    fecha: actividad.fechaInicio,
                    imagenUrl: actividad.imagenPrincipal,
                    onTap: () async {
                      try {
                        final actividadDetalle =
                            await ActividadesApiService.detalleActividad(
                              actividad.id,
                            );
                        _abrirDetalleActividad(actividadDetalle);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            showCloseIcon: true,
                            content: Text(textAlign: .center, "Error al cargar el detalle $e"),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _bodyEstablecimientos() {
    if (_mostrandoDetalleEstablecimiento &&
        _establecimientoDetalleSeleccionado != null) {
      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: _volverAListadoEstablecimientos,
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          Expanded(
            child: Detalle.desdeObjeto(
              objeto: _establecimientoDetalleSeleccionado!,
            ),
          ),
        ],
      );
    }

    return EstablecimientosPage(
      onDetalleSeleccionado: _abrirDetalleEstablecimiento,
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Image.asset("assets/images/imagen_splash.png")],
      ),
    );
  }
}
