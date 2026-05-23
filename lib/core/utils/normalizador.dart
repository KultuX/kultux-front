import 'dart:convert';

String normalizar(String input) {
  const withDiacritics = 'áéíóúÁÉÍÓÚüÜñÑ';
  const withoutDiacritics = 'aeiouAEIOUuUnN';

  for (int i = 0; i < withDiacritics.length; i++) {
    input = input.replaceAll(withDiacritics[i], withoutDiacritics[i]);
  }

  return input.toLowerCase();
}

String formatearCategoria(String texto) {
  return texto
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (palabra) => palabra.isEmpty
            ? ''
            : palabra[0].toUpperCase() + palabra.substring(1),
      )
      .join(' ');
}

String formatearFecha(String? fecha) {
  if (fecha == null || fecha.trim().isEmpty) return '';
  final partes = fecha.split('-');
  if (partes.length != 3) return fecha;
  return '${partes[2]}-${partes[1]}-${partes[0]}';
}
