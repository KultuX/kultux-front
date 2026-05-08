import 'package:flutter/material.dart';

Widget estadoVacio() {
  return Center(  // ← añadir
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.search_off, size: 56, color: Colors.grey),
        SizedBox(height: 12),
        Text('No hay resultados'),
      ],
    ),
  );
}

Widget estadoError({
  required IconData icon,
  required String mensaje,
  required VoidCallback onRetry,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 56, color: Colors.grey),
        const SizedBox(height: 12),
        Text(mensaje, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 166, 226, 70),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            elevation: 3,
          ),
        ),
      ],
    ),
  );
}
