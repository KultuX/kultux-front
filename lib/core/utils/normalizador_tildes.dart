import 'dart:convert';

String normalizar(String input) {
  const withDiacritics = 'áéíóúÁÉÍÓÚüÜñÑ';
  const withoutDiacritics = 'aeiouAEIOUuUnN';

  for (int i = 0; i < withDiacritics.length; i++) {
    input = input.replaceAll(withDiacritics[i], withoutDiacritics[i]);
  }

  return input.toLowerCase();
}
