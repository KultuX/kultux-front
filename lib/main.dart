import 'package:flutter/material.dart';
import 'package:kultux/api/actividadesAPI.dart';
import 'package:kultux/api/localidadesApi.dart';
import 'package:kultux/componentes/bottom_nav.dart';
import 'package:kultux/componentes/app_bar.dart';
import 'package:kultux/componentes/asset_login.dart';
import 'package:kultux/componentes/cabecera.dart';
import 'package:kultux/componentes/scroll_boton.dart';
import 'package:kultux/mapas.dart';
import 'package:kultux/perfil.dart';
import 'package:kultux/buscar.dart';
import 'package:kultux/repository/usuario_repository.dart';

import 'package:kultux/componentes/tarjetas.dart';
import 'package:kultux/establecimientos.dart';
import 'package:kultux/detalles.dart';
import 'package:kultux/models/actividad.dart';
import 'package:kultux/models/usuario.dart';

import 'dart:io';
import 'package:kultux/core/utils/estado_ui.dart';
import 'package:kultux/core/utils/http_error_mapper.dart';
import 'package:kultux/core/utils/estados_widgets.dart';

import 'package:kultux/componentes/modal_alerta.dart';

import 'package:kultux/guardados.dart' show GuardadosTab, GuardadosPage;

import 'componentes/tarjetasBusqueda.dart';
import 'models/pages.dart';

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
  final List<Actividad>? actividadesIniciales;
  final int? totalPaginas;
  const MyHomePage({super.key, this.actividadesIniciales, this.totalPaginas});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _logeado = false;
  int _indexActual = 0;
  bool _invitado = false;
  Usuario? usuario;

  List<Actividad> _actividades = [];
  int _paginaActual = 0;
  int _totalPaginas = 1;
  bool _cargando = false;

  final ScrollController _scrollController = ScrollController();

  bool _mostrandoDetalleInicio = false;
  Actividad? _actividadDetalleSeleccionada;

  bool _mostrandoDetalleEstablecimiento = false;
  dynamic _establecimientoDetalleSeleccionado;

  bool _mostrandoDetalleBuscar = false;
  dynamic _buscarDetalleSeleccionado;

  EstadoUi estadoInicio = EstadoUi.cargando;
  String mensajeErrorInicio = '';

  int _buscarCategoriaIndex = 0;

  bool _mostrandoDetalleGuardado = false;
  dynamic _guardadoDetalleSeleccionado;

  bool _mostrandoGuardadosLista = false;
  bool _mostrandoPerfil = false;

  GuardadosTab _guardadosTabActivo = GuardadosTab.actividades;

  late final EstablecimientosPage _establecimientosPage;



  Future<void> _cargarSesion() async {
    final usuarioGuardado = await UsuarioRepository.cargar();

    setState(() {
      if (usuarioGuardado != null) {
        usuario = usuarioGuardado;
        _logeado = true;
        _invitado = false;
      } else {
        usuario = null;
        _logeado = false;
        _invitado = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _cargarSesion();
    _establecimientosPage = EstablecimientosPage(
      onDetalleSeleccionado: _abrirDetalleEstablecimiento,
    );

    if (widget.actividadesIniciales != null) {
      _actividades = widget.actividadesIniciales!;
      _totalPaginas = widget.totalPaginas ?? 1;
      _paginaActual = 1;
      estadoInicio = EstadoUi.contenido;
    } else {
      _cargarActividades(inicial: true);
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _cargarMas();
      }
    });
  }

  Future<void> _cargarActividades({bool inicial = false}) async {
    if (_cargando) return;

    if (inicial) {
      setState(() {
        estadoInicio = EstadoUi.cargando;
      });
    }

    _cargando = true;

    try {
      final page = await ActividadesApiService.obtenerActividadesInicio(
        _paginaActual,
      );

      setState(() {
        _actividades.addAll(page.contenido);
        _totalPaginas = page.totalPaginas;
        _paginaActual++;

        if (_actividades.isEmpty) {
          estadoInicio = EstadoUi.vacio;
        } else {
          estadoInicio = EstadoUi.contenido;
        }
      });
    } on SocketException {
      setState(() {
        estadoInicio = EstadoUi.sinConexion;
        mensajeErrorInicio = 'No hay conexión a internet';
      });
    } on HttpException catch (e) {
      final uiError = mapearStatusCode(int.parse(e.message));

      setState(() {
        estadoInicio = uiError.estado;
        mensajeErrorInicio = uiError.mensaje;
      });
    } catch (_) {
      setState(() {
        estadoInicio = EstadoUi.error;
        mensajeErrorInicio = 'Error inesperado';
      });
    } finally {
      _cargando = false;
    }
  }

  Future<void> _cargarMas() async {
    if (_cargando) return;
    if (_paginaActual >= _totalPaginas) return;
    await _cargarActividades();
  }
  void _cerrarSesion() async {
    await UsuarioRepository.cerrarSesion();

    setState(() {
      usuario = null;
      Usuario.usuarioActual = null;

      _logeado = false;
      _invitado = false;

      _indexActual = 0;

      _mostrandoPerfil = false;

      _mostrandoDetalleInicio = false;
      _actividadDetalleSeleccionada = null;

      _mostrandoDetalleEstablecimiento = false;
      _establecimientoDetalleSeleccionado = null;

      _mostrandoDetalleBuscar = false;
      _buscarDetalleSeleccionado = null;

      _mostrandoDetalleGuardado = false;
      _guardadoDetalleSeleccionado = null;

      _mostrandoGuardadosLista = false;
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
      _actividades.clear();
      _paginaActual = 0;
    });
    _cargarActividades();
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

  void _abrirDetalleBuscar(dynamic objeto) {
    setState(() {
      _buscarDetalleSeleccionado = objeto;
      _mostrandoDetalleBuscar = true;
    });
  }

  void _volverAListadoBuscar() {
    setState(() {
      _mostrandoDetalleBuscar = false;
      _buscarDetalleSeleccionado = null;
    });
  }

  void _abrirDetalleGuardados(dynamic objeto, GuardadosTab tab) {
    setState(() {
      _guardadoDetalleSeleccionado = objeto;
      _mostrandoDetalleGuardado = true;
      _guardadosTabActivo = tab;
      _indexActual = 4;
    });
  }

  void _volverAGuardados() {
    setState(() {
      _mostrandoDetalleGuardado = false;
      _guardadoDetalleSeleccionado = null;
      _mostrandoGuardadosLista = true;
    });
  }

  Widget _getPaginaActual() {

    if (_mostrandoPerfil) {
      return _bodyPerfil();
    }
    switch (_indexActual) {
      case 0:
        return _bodyInicio();
      case 1:
        return const MapasPage();
      case 2:
        return _bodyBuscar();
      case 3:
        return _bodyEstablecimientos();
      case 4:

        if (_mostrandoDetalleGuardado &&
            _guardadoDetalleSeleccionado != null) {

          return Column(
            children: [
              CabeceraPagina(
                titulo: 'Información',
                subtitulo: 'Detalle',
                onVolver: _volverAGuardados,
              ),
              Expanded(
                child: Detalle.desdeObjeto(
                  objeto: _guardadoDetalleSeleccionado!,
                ),
              ),
            ],
          );
        }

        return GuardadosPage(
          tabInicial: _guardadosTabActivo,

          onVolver: () {
            setState(() {
              _indexActual = 0;
            });
          },

          onDetalleSeleccionado: (objeto, tab) {
            _abrirDetalleGuardados(objeto, tab);
          },
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBarPersonalizado(
        logeado: _logeado,
        invitado: _invitado,

        onMostrarLogin: () {
          setState(() {
            _logeado = false;
            _invitado = false;
          });
        },
        perfilActivado: _mostrandoPerfil,
        onIrInicio: () {
          setState(() {

            _mostrandoPerfil = false;

            _indexActual = 0;

            _mostrandoDetalleInicio = false;
            _actividadDetalleSeleccionada = null;

            _mostrandoDetalleEstablecimiento = false;
            _establecimientoDetalleSeleccionado = null;

            _mostrandoDetalleBuscar = false;
            _buscarDetalleSeleccionado = null;

            _mostrandoDetalleGuardado = false;
            _guardadoDetalleSeleccionado = null;
          });
        },

        onIrPerfil: () {
          setState(() {

            _mostrandoPerfil = true;

            _mostrandoDetalleInicio = false;
            _actividadDetalleSeleccionada = null;

            _mostrandoDetalleEstablecimiento = false;
            _establecimientoDetalleSeleccionado = null;

            _mostrandoDetalleBuscar = false;
            _buscarDetalleSeleccionado = null;
          });
        },
      ),
      body: !_logeado && !_invitado
          ? Stack(
              alignment: Alignment.center,
              children: [
                _getPaginaActual(),
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
                        _logeado = false;
                       // _indexActual = 0;
                      });
                    },
                  ),
              ],
            )
          : _getPaginaActual(),
      bottomNavigationBar: BottomNav(

        itemSeleccionado: _indexActual,
        itemSeleccion: (index) {
          _mostrandoPerfil = false;
          if (!_logeado && !_invitado) {
            if (!context.mounted) return;
            Alerta.show(
              context,
              mensaje: '¡Inicia sesión, registrate o entra como invitado!',
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
              _mostrandoDetalleBuscar = false;
              _buscarDetalleSeleccionado = null;
            });
            Alerta.show(
              context,
              mensaje:
                  '¡Inicia sesión o registrate para acceder a más funcionalidades!',
            );
            return;
          }

          setState(() {
            _indexActual = index;

            _mostrandoDetalleInicio = false;
            _actividadDetalleSeleccionada = null;

            _mostrandoDetalleEstablecimiento = false;
            _establecimientoDetalleSeleccionado = null;
            _mostrandoDetalleBuscar = false;
            _buscarDetalleSeleccionado = null;

            if (index != 4) {
              _mostrandoDetalleGuardado = false;
              _guardadoDetalleSeleccionado = null;
              _mostrandoGuardadosLista = false;
            }
          });
        },
      ),
    );
  }

  Widget _contenidoInicio() {
    return Expanded(
      child: Center(
        child: SizedBox(
          width: 380,
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                itemCount: _actividades.length + 1,
                itemBuilder: (context, index) {
                  if (index < _actividades.length) {
                    final actividad = _actividades[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TarjetaBusqueda.actividad(
                      titulo: actividad.titulo,
                      localidad: actividad.localidad!,
                      fecha: actividad.fechaInicio,
                      imagenUrl: actividad.imagenPrincipal,
                      onTap: () async {
                        final detalle = await ActividadesApiService.detalleActividad(actividad.id);
                        _abrirDetalleActividad(detalle);
                      },
                      textoEtiqueta: actividad.categoriaActividad!,
                      iconoEtiqueta: 'assets/iconos/actividad_etiquetas.svg',
                    ),
                    );
                  }

                  if (_cargando) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 166, 226, 70),
                        ),
                      ),
                    );
                  }

                  if (_paginaActual >= _totalPaginas) {
                    return const Padding(
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          "¡Ya no hay más actividades para mostrar!",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: ScrollBoton(controller: _scrollController),
              ),
            ],
          ),
        ),
      ),
    );
  }





  Widget _bodyInicio() {
    if (_mostrandoDetalleInicio && _actividadDetalleSeleccionada != null) {
      return Column(
        children: [
          CabeceraPagina(
            titulo: 'Información',
            subtitulo: 'Detalle',
            onVolver: _volverAListadoInicio,
          ),
          Expanded(
            child: Detalle.desdeObjeto(objeto: _actividadDetalleSeleccionada!),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CabeceraPagina(
          titulo: 'Actividades recientes',
          subtitulo: 'Inicio',
          mostrarFecha: true,
          mostrarEtiquetaHoy: true,
        ),

        switch (estadoInicio) {
          EstadoUi.cargando => const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 166, 226, 70),
              ),
            ),
          ),
          EstadoUi.vacio => Expanded(child: estadoVacio()),
          EstadoUi.sinConexion => Expanded(
            child: estadoError(
              icon: Icons.wifi_off,
              mensaje: mensajeErrorInicio,
              onRetry: _cargarActividades,
            ),
          ),
          EstadoUi.error => Expanded(
            child: estadoError(
              icon: Icons.error_outline,
              mensaje: mensajeErrorInicio,
              onRetry: _cargarActividades,
            ),
          ),
          EstadoUi.contenido => _contenidoInicio(),
        },
      ],
    );
  }

  Widget _bodyEstablecimientos() {
    return Stack(
      children: [
        _establecimientosPage,
        if (_mostrandoDetalleEstablecimiento &&
            _establecimientoDetalleSeleccionado != null)
          Column(
            children: [
              CabeceraPagina(
                titulo: 'Información',
                subtitulo: 'Detalle',
                onVolver: _volverAListadoEstablecimientos,
              ),
              Expanded(
                child: Detalle.desdeObjeto(
                  objeto: _establecimientoDetalleSeleccionado!,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _bodyBuscar() {
    if (_mostrandoDetalleBuscar && _buscarDetalleSeleccionado != null) {
      return Column(
        children: [
          CabeceraPagina(
            titulo: 'Información',
            subtitulo: 'Detalle',
            onVolver: _volverAListadoBuscar,
          ),
          Expanded(
            child: Detalle.desdeObjeto(objeto: _buscarDetalleSeleccionado!),
          ),
        ],
      );
    }
    return BuscarPage(
      onDetalleSeleccionado: _abrirDetalleBuscar,
      selectedIndex: _buscarCategoriaIndex,
      onIndexChanged: (index) {
        _buscarCategoriaIndex = index;
      },
    );
  }

  Widget _bodyPerfil() {

    return PerfilPage(
      cerrarSesion: _cerrarSesion,
      usuario: usuario,
      onVolver: () {
        setState(() {
          _mostrandoPerfil = false;
        });
      },
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
    _cargarDatosInicio();
  }

  Future<void> _cargarDatosInicio() async {
    try {
      final results = await Future.wait([
        ActividadesApiService.obtenerActividadesInicio(0),
        LocalidadApiService.obtenerLocalidadNombres(),
      ]);

      final page = results[0] as Pages<Actividad>;

      for (final act in page.contenido.take(5)) {
        if (act.imagenPrincipal != null) {
          try {
            await precacheImage(NetworkImage(act.imagenPrincipal), context);
          } catch (_) {}
        }
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MyHomePage(
            actividadesIniciales: page.contenido,
            totalPaginas: page.totalPaginas,
          ),
        ),
      );
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyHomePage()),
      );
    }
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
