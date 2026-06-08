import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum Tipe { actividad, restaurante, alojamiento }

class Sharing {
  static const _landing = 'https://kultux-landingpage.vercel.app/';

  static final _appInfo =
      'Kultux es la app para descubrir Extremadura de verdad — actividades, restaurantes y alojamientos seleccionados en un solo lugar.\n\n👇 $_landing';
  static final _iconos = {
    Tipe.actividad: '🎯',
    Tipe.restaurante: '🍽️',
    Tipe.alojamiento: '🏨',
  };

  static String _message({
    required String titulo,
    required Tipe tipo,
    String? descripcion,
    String? fecha,
    int maxDescripcion = 300,
  }) {
    final emoji = _iconos[tipo]!;

    final descTrim = descripcion?.trim();
    final desc = (descTrim == null || descTrim.isEmpty)
        ? null
        : descTrim.length > maxDescripcion
        ? '${descTrim.substring(0, maxDescripcion)}...'
        : descTrim;

    return [
      '$emoji: $titulo',
      if (fecha != null) '📅 $fecha',
      if (desc != null) desc,
      _appInfo,
    ].join('\n\n');
  }

  static Future<void> sharing({
    required String titulo,
    required Tipe tipo,
    String? descripcion,
    String? fecha,
    int maxDescripcion = 100,
  }) async {
    await Share.share(
      _message(
        titulo: titulo,
        tipo: tipo,
        descripcion: descripcion,
        fecha: fecha,
        maxDescripcion: maxDescripcion,
      ),
    );
  }

  static Future<void> sharingImage({
    required String titulo,
    required Tipe tipo,
    required String imagenUrl,
    String? descripcion,
    String? fecha,
    int maxDescripcion = 100,
  }) async {
    try {
      final response = await http.get(Uri.parse(imagenUrl));
      final temp = await getTemporaryDirectory();
      final file = File('${temp.path}/share_img.jpg');
      await file.writeAsBytes(response.bodyBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: _message(
          titulo: titulo,
          tipo: tipo,
          descripcion: descripcion,
          fecha: fecha,
          maxDescripcion: maxDescripcion,
        ),
      );
    } catch (_) {
      await sharing(
        titulo: titulo,
        tipo: tipo,
        descripcion: descripcion,
        fecha: fecha,
        maxDescripcion: maxDescripcion,
      );
    }
  }
}
