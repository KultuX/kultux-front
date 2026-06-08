import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/core/models/activity.dart';
import 'package:kultux/core/models/accommodation.dart';
import 'package:kultux/core/models/restaurant.dart';
import 'package:kultux/core/models/image.dart' as img;
import 'package:kultux/core/models/time_slot.dart';
import 'package:kultux/core/models/user.dart';
import 'package:kultux/data/api/interaction_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kultux/shared/widget/alert_modal.dart';
import 'package:kultux/core/utils/sharing.dart';
import 'package:kultux/core/utils/app_icons.dart';
import 'package:kultux/core/utils/formatter.dart';


class _K {
  static const verde     = Color(0xFFA6E246);
  static const verdeDark = Color(0xFF639922);
  static const fondo     = Color(0xFFF1EFE9);
  static const card      = Color(0xFFFFFFFF);
  static const texto     = Color(0xFF1A1A1A);
  static const suave     = Color(0xFF6B6B6B);
  static const borde     = Color(0xFFE8E8E8);
  static const rojo      = Color(0xFFA32D2D);
  static const azul      = Color(0xFF185FA5);
}

// ─── Model ───────────────────────────────────────────────────────
class DetailPage extends StatefulWidget {
  final String titulo;
  final String? imagenPrincipal;
  final String? descripcion;
  final String? telefonoEmpresa;
  final String? correoCorporativo;
  final String? fechaInicio;
  final String? fechaFin;
  final String? localidad;
  final List<img.Image>? imagenes;
  final Map<String, List<TimeSlot>>? horario;
  final bool? abierto;
  final String? urlCompraReserva;
  final String? urlWeb;
  final String? direccion;
  final int? idActividad;
  final int? idRestaurante;
  final int? idAlojamiento;
  final String? nombreEmpresa;
  final String? logotipoEmpresa;
  final String? categoria;
  final String? iconoEtiqueta;
  final double? precio;
  final int? aforoMaximo;
  final String? horaInicio;
  final String? horaFin;
  final String? estado;

  const DetailPage._({
    super.key,
    required this.titulo,
    this.imagenPrincipal,
    this.descripcion,
    this.telefonoEmpresa,
    this.correoCorporativo,
    this.fechaInicio,
    this.fechaFin,
    this.horario,
    this.localidad,
    this.imagenes,
    this.abierto,
    this.urlCompraReserva,
    this.urlWeb,
    this.direccion,
    this.idActividad,
    this.idRestaurante,
    this.idAlojamiento,
    this.nombreEmpresa,
    this.logotipoEmpresa,
    this.categoria,
    this.iconoEtiqueta,
    this.precio,
    this.aforoMaximo,
    this.horaInicio,
    this.horaFin,
    this.estado,
  });

  List<String> get imagesList {
    if (imagenes == null || imagenes!.isEmpty) {
      return ['https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg'];
    }
    final ordenadas = [...imagenes!];
    ordenadas.sort((a, b) => a.esPortada ? -1 : 1);
    return ordenadas.map((i) => i.url).toList();
  }

  factory DetailPage.fromObject({required dynamic objeto}) {
    if (objeto is Activity) {
      return DetailPage._(
        titulo: objeto.titulo,
        imagenPrincipal: objeto.imagenPrincipal,
        localidad: objeto.localidad,
        descripcion: objeto.descripcion,
        telefonoEmpresa: objeto.telefonoEmpresa,
        correoCorporativo: objeto.correoCorporativo,
        fechaInicio: objeto.fechaInicio,
        fechaFin: objeto.fechaFin,
        imagenes: objeto.imagenes,
        urlCompraReserva: objeto.urlCompra,
        urlWeb: objeto.urlWeb,
        direccion: objeto.direccion,
        idActividad: objeto.id,
        nombreEmpresa: objeto.nombreEmpresa,
        logotipoEmpresa: objeto.logotipoEmpresa,
        categoria: objeto.categoriaActividad,
        iconoEtiqueta: 'assets/iconos/actividad_etiquetas.svg',
        precio: objeto.precio,
        aforoMaximo: objeto.aforoMaximo,
        horaInicio: objeto.horaInicio,
        horaFin: objeto.horaFin,
        estado: objeto.estado,
      );
    }
    if (objeto is Accommodation) {
      return DetailPage._(
        idAlojamiento: objeto.id,
        titulo: objeto.nombre,
        imagenPrincipal: objeto.imagenPrincipal,
        localidad: objeto.localidad,
        telefonoEmpresa: objeto.telefonoEmpresa,
        correoCorporativo: objeto.correoCorporativo,
        imagenes: objeto.imagenes,
        urlCompraReserva: objeto.urlReserva,
        urlWeb: objeto.urlWeb,
        descripcion: objeto.descripcion,
        direccion: objeto.direccion,
        categoria: objeto.categoriaAlojamiento,
        iconoEtiqueta: AppIcons.getAccommodationIcon(objeto.categoriaAlojamiento),
      );
    }
    if (objeto is Restaurant) {
      return DetailPage._(
        idRestaurante: objeto.id,
        titulo: objeto.nombre,
        imagenPrincipal: objeto.imagenPrincipal,
        localidad: objeto.localidad,
        descripcion: objeto.descripcion,
        telefonoEmpresa: objeto.telefonoEmpresa ?? '',
        correoCorporativo: objeto.correoCorporativo ?? '',
        horario: objeto.horario,
        imagenes: objeto.imagenes,
        abierto: objeto.abierto,
        urlCompraReserva: objeto.urlReserva,
        urlWeb: objeto.urlWeb,
        direccion: objeto.direccion,
        categoria: objeto.categoriaRestaurante,
        iconoEtiqueta: AppIcons.getRestaurantIcon(objeto.categoriaRestaurante),
      );
    }
    throw Exception('Tipo de objeto no soportado');
  }

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _indice = 0;
  late PageController _pageCtrl;

  bool get _tieneReserva => widget.urlCompraReserva?.trim().isNotEmpty == true;
  bool get _tieneWeb => widget.urlWeb?.trim().isNotEmpty == true;

  String _normUrl(String url) =>
      url.startsWith('http') ? url : 'https://$url';

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esActividad   = widget.idActividad != null;
    final esRestaurante = widget.idRestaurante != null;
    final esAlojamiento = widget.idAlojamiento != null;

    return ColoredBox(
      color: _K.fondo,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero imagen (ratio 3:4 igual que tarjeta) ──────────
            _TarjetaPrincipal(
              imagenesLista: widget.imagesList,
              indice: _indice,
              pageCtrl: _pageCtrl,
              estado: widget.estado,
              categoria: widget.categoria,
              iconoEtiqueta: widget.iconoEtiqueta,
              esActividad: esActividad,
              esRestaurante: esRestaurante,
              esAlojamiento: esAlojamiento,
              idActividad: widget.idActividad,
              idRestaurante: widget.idRestaurante,
              idAlojamiento: widget.idAlojamiento,
              idUsuario: User.activeUser?.id,
              titulo: widget.titulo,
              portada: widget.imagenPrincipal,
              descripcion: widget.descripcion,
              fechaInicio: widget.fechaInicio,
              onPageChanged: (i) => setState(() => _indice = i),
            ),

            // ── Info principal ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    widget.titulo,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _K.texto,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Localidad + dirección
                  if (widget.localidad != null)
                    _Direccion(
                      icono: Icons.location_on_outlined,
                      texto: widget.localidad!,
                      color: _K.verde,
                    ),
                  if (widget.direccion != null && widget.direccion!.isNotEmpty)
                    _Direccion(
                      icono: Icons.near_me_outlined,
                      texto: widget.direccion!,
                      color: _K.suave,
                    ),

                  const SizedBox(height: 14),


                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (esActividad && widget.fechaInicio != null)
                        _FechaHora(
                          icono: Icons.calendar_today_outlined,
                          texto: '${dateFormatter(widget.fechaInicio)}'
                              '${widget.fechaFin != null ? ' – ${dateFormatter(widget.fechaFin)}' : ''}',
                        ),
                      if (esActividad && widget.horaInicio != null)
                        _FechaHora(
                          icono: Icons.access_time_outlined,
                          texto: widget.horaFin != null
                              ? '${widget.horaInicio} – ${widget.horaFin}'
                              : widget.horaInicio!,
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: _K.borde, height: 1),
                  const SizedBox(height: 20),
                  if (esActividad && (widget.precio != null || widget.aforoMaximo != null)) ...[
                    Row(
                      children: [
                        if (widget.precio != null)
                          Expanded(child: _PrecioAforo(
                            icono: Icons.euro_outlined,
                            label: 'Precio',
                            valor: widget.precio == 0 ? 'Gratis' : '${widget.precio}€',
                          )),
                        if (widget.precio != null && widget.aforoMaximo != null)
                          const SizedBox(width: 12),
                        if (widget.aforoMaximo != null)
                          Expanded(child: _PrecioAforo(
                            icono: Icons.people_alt_outlined,
                            label: 'Aforo',
                            valor: widget.aforoMaximo == 0 ? 'Sin límite' : '${widget.aforoMaximo} personas',
                          )),
                      ],
                    ),
                  ],
                  const Divider(color: _K.borde, height: 1),
                  const SizedBox(height: 20),

                  if (widget.descripcion?.trim().isNotEmpty == true) ...[
                    _Titulo('Descripción'),
                    const SizedBox(height: 8),
                    Text(
                      widget.descripcion!,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.65,
                        color: _K.texto,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: _K.borde, height: 1),
                    const SizedBox(height: 20),
                  ],

                  if (esRestaurante && widget.horario != null) ...[
                    _BloqueHorario(horario: widget.horario!, abierto: widget.abierto),
                    const SizedBox(height: 24),
                    const Divider(color: _K.borde, height: 1),
                    const SizedBox(height: 20),
                  ],


                  _Titulo('Información'),
                  const SizedBox(height: 12),

                  if (esActividad && widget.nombreEmpresa != null)
                    _FilaInfo(icono: Icons.store_outlined, label: 'Organizado por', valor: widget.nombreEmpresa!),
                  if (_tieneWeb)
                    _FilaInfo(
                      icono: Icons.language_outlined,
                      label: 'Web oficial',
                      valor: widget.urlWeb!,
                      esEnlace: true,
                      onTap: () async => launchUrl(Uri.parse(_normUrl(widget.urlWeb!)), mode: LaunchMode.externalApplication),
                    ),
                  if (widget.telefonoEmpresa?.trim().isNotEmpty == true)
                    _FilaInfo(
                      icono: Icons.phone_outlined,
                      label: 'Teléfono',
                      valor: widget.telefonoEmpresa!,
                      esEnlace: true,
                      onTap: () async => launchUrl(Uri.parse('tel:${widget.telefonoEmpresa}')),
                    ),
                  if (widget.correoCorporativo?.trim().isNotEmpty == true)
                    _FilaInfo(
                      icono: Icons.mail_outline,
                      label: 'Correo',
                      valor: widget.correoCorporativo!,
                      esEnlace: true,
                      onTap: () async => launchUrl(Uri.parse('mailto:${widget.correoCorporativo}')),
                    ),
                  const SizedBox(height: 28),
                  _BotonCTA(
                    activo: _tieneReserva,
                    esActividad: esActividad,
                    esRestaurante: esRestaurante,
                    onTap: _tieneReserva
                        ? () async {
                      final uri = Uri.parse(_normUrl(widget.urlCompraReserva!));
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    }
                        : null,
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


class _TarjetaPrincipal extends StatelessWidget {
  final List<String> imagenesLista;
  final int indice;
  final PageController pageCtrl;
  final String? estado;
  final String? categoria;
  final String? iconoEtiqueta;
  final bool esActividad;
  final bool esRestaurante;
  final bool esAlojamiento;
  final int? idActividad;
  final int? idRestaurante;
  final int? idAlojamiento;
  final int? idUsuario;
  final String titulo;
  final String? portada;
  final String? descripcion;
  final String? fechaInicio;
  final ValueChanged<int> onPageChanged;

  const _TarjetaPrincipal({
    required this.imagenesLista,
    required this.indice,
    required this.pageCtrl,
    required this.esActividad,
    required this.esRestaurante,
    required this.esAlojamiento,
    required this.onPageChanged,
    required this.titulo,
    this.estado,
    this.categoria,
    this.iconoEtiqueta,
    this.idActividad,
    this.idRestaurante,
    this.idAlojamiento,
    this.idUsuario,
    this.portada,
    this.descripcion,
    this.fechaInicio,
  });

  @override
  Widget build(BuildContext context) {
    final tieneVarias = imagenesLista.length > 1;

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Stack(
        fit: StackFit.expand,
        children: [

          PageView.builder(
            controller: pageCtrl,
            onPageChanged: onPageChanged,
            itemCount: imagenesLista.length,
            itemBuilder: (_, i) => CachedNetworkImage(
              imageUrl: imagenesLista[i],
              fit: BoxFit.cover,
              memCacheWidth: 800,
              placeholder: (_, __) => const ColoredBox(color: Color(0xFFD4D0C8)),
              errorWidget: (_, __, ___) => Container(
                color: const Color(0xFFD4D0C8),
                child: const Icon(Icons.image_outlined, color: Color(0xFF999999), size: 48),
              ),
            ),
          ),


          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x88000000), Colors.transparent],
                ),
              ),
            ),
          ),


          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 140,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xCC000000), Colors.transparent],
                ),
              ),
            ),
          ),


          if (estado != null && estado!.isNotEmpty)
            Positioned(
              top: 14, left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: estado == 'PROXIMAMENTE' ? const Color(0xE0185FA5) : const Color(0xE0A32D2D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estado!,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
                ),
              ),
            ),


          Positioned(
            top: 10, right: 12,
            child: Row(
              children: [
                _BotonGuardar(
                  esActividad: esActividad,
                  esRestaurante: esRestaurante,
                  esAlojamiento: esAlojamiento,
                  idActividad: idActividad,
                  idRestaurante: idRestaurante,
                  idAlojamiento: idAlojamiento,
                  idUsuario: idUsuario,
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    final tipo = esActividad ? Tipe.actividad : esRestaurante ? Tipe.restaurante : Tipe.alojamiento;
                    portada != null
                        ? Sharing.sharingImage(titulo: titulo, tipo: tipo, imagenUrl: portada!, descripcion: descripcion, fecha: fechaInicio)
                        : Sharing.sharing(titulo: titulo, tipo: tipo, descripcion: descripcion, fecha: fechaInicio);
                  },
                  child: _Botones(icono: Icons.share_outlined),
                ),
              ],
            ),
          ),


          if (categoria != null && iconoEtiqueta != null)
            Positioned(
              bottom: 14, left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _K.verde.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(iconoEtiqueta!, width: 13, height: 13,
                        colorFilter: const ColorFilter.mode(_K.verde, BlendMode.srcIn)),
                    const SizedBox(width: 5),
                    Text(categoryFormatter(categoria!),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _K.verde, letterSpacing: 0.4)),
                  ],
                ),
              ),
            ),


          if (tieneVarias)
            Positioned(
              bottom: 14, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imagenesLista.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == indice ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == indice ? _K.verde : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                )),
              ),
            ),


          if (tieneVarias) ...[
            Positioned(
              left: 10, top: 0, bottom: 0,
              child: Center(child: _NavFlecha(icono: Icons.chevron_left, onTap: () {
                pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
              })),
            ),
            Positioned(
              right: 10, top: 0, bottom: 0,
              child: Center(child: _NavFlecha(icono: Icons.chevron_right, onTap: () {
                pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
              })),
            ),
          ],
        ],
      ),
    );
  }
}

class _Botones extends StatelessWidget {
  final IconData icono;
  const _Botones({required this.icono});

  @override
  Widget build(BuildContext context) => Container(
    width: 36, height: 36,
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.4),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icono, color: Colors.white, size: 18),
  );
}

class _NavFlecha extends StatelessWidget {
  final IconData icono;
  final VoidCallback onTap;
  const _NavFlecha({required this.icono, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icono, color: Colors.white, size: 22),
    ),
  );
}


class _Titulo extends StatelessWidget {
  final String texto;
  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) => Text(
    texto,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _K.texto, letterSpacing: -0.2),
  );
}


class _Direccion extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;
  const _Direccion({required this.icono, required this.texto, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Icon(icono, size: 15, color: color),
        const SizedBox(width: 5),
        Expanded(child: Text(texto, style: TextStyle(fontSize: 13.5, color: color == _K.verde ? _K.suave : _K.suave))),
      ],
    ),
  );
}


class _FechaHora extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _FechaHora({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: _K.verde.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _K.verde.withOpacity(0.35)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 13, color: _K.verdeDark),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _K.verdeDark)),
      ],
    ),
  );
}


class _BloqueHorario extends StatelessWidget {
  final Map<String, List<TimeSlot>> horario;
  final bool? abierto;
  const _BloqueHorario({required this.horario, this.abierto});

  static const _dias = {1:'Lun',2:'Mar',3:'Mié',4:'Jue',5:'Vie',6:'Sáb',7:'Dom'};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Titulo('Horario'),
            const Spacer(),
            if (abierto != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: abierto! ? _K.verde.withOpacity(0.15) : _K.rojo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: abierto! ? _K.verdeDark : _K.rojo, width: 0.8),
                ),
                child: Text(
                  abierto! ? '● Abierto' : '● Cerrado',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: abierto! ? _K.verdeDark : _K.rojo),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        ...[1,2,3,4,5,6,7].map((d) {
          final franjas = horario['$d'] ?? [];
          final cerrado = franjas.isEmpty;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 36, child: Text(_dias[d]!, style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: cerrado ? _K.suave : _K.texto,
                ))),
                const SizedBox(width: 10),
                Container(
                  width: 2,
                  height: cerrado ? 20 : (franjas.length * 28).toDouble(),
                  decoration: BoxDecoration(
                    color: cerrado ? _K.borde : _K.verde.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: cerrado
                      ? const Text('Cerrado', style: TextStyle(fontSize: 13, color: _K.suave, fontStyle: FontStyle.italic))
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: franjas.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: _K.verde.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _K.verde.withOpacity(0.3), width: 0.8),
                        ),
                        child: Text('${f.inicio} – ${f.fin}',
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _K.texto)),
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _FilaInfo extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  final bool esEnlace;
  final VoidCallback? onTap;
  const _FilaInfo({required this.icono, required this.label, required this.valor, this.esEnlace = false, this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: _K.verde.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icono, size: 16, color: _K.verde),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: _K.suave, fontWeight: FontWeight.w500)),
                const SizedBox(height: 1),
                Text(valor, style: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w500,
                  color: esEnlace ? const Color(0xFF3B6FE8) : _K.texto,
                  decoration: esEnlace ? TextDecoration.underline : null,
                )),
              ],
            ),
          ),
          if (esEnlace) const Icon(Icons.open_in_new, size: 14, color: _K.suave),
        ],
      ),
    ),
  );
}


class _BotonCTA extends StatelessWidget {
  final bool activo;
  final bool esActividad;
  final bool esRestaurante;
  final VoidCallback? onTap;
  const _BotonCTA({required this.activo, required this.esActividad, required this.esRestaurante, this.onTap});

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: activo ? 1.0 : 0.4,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _K.verde,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              esActividad ? Icons.confirmation_number_outlined : esRestaurante ? Icons.restaurant_outlined : Icons.hotel_outlined,
              size: 20, color: Colors.black87,
            ),
            const SizedBox(width: 8),
            Text(
              esActividad ? 'Comprar entradas' : 'Reservar ahora',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: 0.2),
            ),
          ],
        ),
      ),
    ),
  );
}


class _BotonGuardar extends StatefulWidget {
  final bool esActividad, esRestaurante, esAlojamiento;
  final int? idActividad, idRestaurante, idAlojamiento, idUsuario;

  const _BotonGuardar({
    required this.esActividad, required this.esRestaurante, required this.esAlojamiento,
    this.idActividad, this.idRestaurante, this.idAlojamiento, this.idUsuario,
  });

  @override
  State<_BotonGuardar> createState() => _BotonGuardarState();
}

class _BotonGuardarState extends State<_BotonGuardar> {
  bool? _guardado;
  bool _cargando = false;

  bool get _logueado => widget.idUsuario != null;
  bool get _soportado =>
      (widget.esActividad && widget.idActividad != null) ||
          (widget.esRestaurante && widget.idRestaurante != null) ||
          (widget.esAlojamiento && widget.idAlojamiento != null);

  @override
  void initState() {
    super.initState();
    if (_logueado && _soportado) _cargarEstado();
  }

  Future<void> _cargarEstado() async {
    try {
      bool guardado;
      if (widget.esActividad) {
        final r = await InteractionApiService.activitySavedState(idActividad: widget.idActividad!, idUsuario: widget.idUsuario!);
        guardado = r.guardado;
      } else if (widget.esRestaurante) {
        final r = await InteractionApiService.restaurantSavedState(idRestaurante: widget.idRestaurante!, idUsuario: widget.idUsuario!);
        guardado = r.guardado;
      } else {
        final r = await InteractionApiService.accommodationSavedState(idAlojamiento: widget.idAlojamiento!, idUsuario: widget.idUsuario!);
        guardado = r.guardado;
      }
      if (mounted) setState(() => _guardado = guardado);
    } catch (_) {
      if (mounted) setState(() => _guardado = false);
    }
  }

  Future<void> _toggle(BuildContext context) async {
    if (_cargando || !_soportado) return;
    if (!_logueado) { AlertModal.show(context, message: 'Inicia sesión para guardar'); return; }
    setState(() => _cargando = true);
    try {
      if (_guardado == true) {
        if (widget.esActividad) await InteractionApiService.unsavedActivity(idActividad: widget.idActividad!, idUsuario: widget.idUsuario!);
        else if (widget.esRestaurante) await InteractionApiService.unsavedRestaurant(idRestaurante: widget.idRestaurante!, idUsuario: widget.idUsuario!);
        else await InteractionApiService.unsavedAccommodation(idAlojamiento: widget.idAlojamiento!, idUsuario: widget.idUsuario!);
        if (mounted) setState(() => _guardado = false);
      } else {
        if (widget.esActividad) await InteractionApiService.saveActivity(idActividad: widget.idActividad!, idUsuario: widget.idUsuario!);
        else if (widget.esRestaurante) await InteractionApiService.saveRestaurant(idRestaurante: widget.idRestaurante!, idUsuario: widget.idUsuario!);
        else await InteractionApiService.saveAccommodation(idAlojamiento: widget.idAlojamiento!, idUsuario: widget.idUsuario!);
        if (mounted) setState(() => _guardado = true);
      }
    } catch (_) {
      if (mounted) AlertModal.show(context, message: 'Error al guardar. Inténtalo de nuevo.', type: AlertTipe.error);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_soportado) return const SizedBox.shrink();
    final icono = _guardado == true ? Icons.bookmark : Icons.bookmark_border;
    final color = _guardado == true ? _K.verde : Colors.white;
    return GestureDetector(
      onTap: () => _toggle(context),
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(12)),
        child: _cargando
            ? const Padding(padding: EdgeInsets.all(9), child: CircularProgressIndicator(strokeWidth: 2, color: _K.verde))
            : Icon(icono, color: color, size: 18),
      ),
    );
  }
}

class _PrecioAforo extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  const _PrecioAforo({required this.icono, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: _K.verde.withOpacity(0.10),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _K.verde.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: _K.verde.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icono, size: 18, color: _K.verdeDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: _K.suave, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(valor, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _K.verdeDark)),
            ],
          ),
        ),
      ],
    ),
  );
}
