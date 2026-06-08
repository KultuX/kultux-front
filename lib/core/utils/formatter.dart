
String accentFormatter(String input) {
  const withDiacritics = 'áéíóúÁÉÍÓÚüÜñÑ';
  const withoutDiacritics = 'aeiouAEIOUuUnN';

  for (int i = 0; i < withDiacritics.length; i++) {
    input = input.replaceAll(withDiacritics[i], withoutDiacritics[i]);
  }

  return input.toLowerCase();
}

String categoryFormatter(String texto) {
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

String dateFormatter(String? fecha) {
  if (fecha == null || fecha.trim().isEmpty) return '';
  final partes = fecha.split('-');
  if (partes.length != 3) return fecha;
  return '${partes[2]}-${partes[1]}-${partes[0]}';
}

String formatToSpanishDate(DateTime fecha) {
  return '${fecha.day}-${fecha.month}-${fecha.year}';
}

String normUrl(String url) =>
    url.startsWith('http') ? url : 'https://$url';


