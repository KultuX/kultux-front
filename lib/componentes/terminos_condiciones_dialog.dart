import 'package:flutter/material.dart';

class TerminosCondicionesDialog extends StatelessWidget {
  const TerminosCondicionesDialog({super.key});

  /// Abre el diálogo de Términos y Condiciones.
  /// Se cierra pulsando el botón "Cerrar" o tocando fuera del diálogo.
  static Future<void> mostrar(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true, // toca fuera → cierra
      builder: (_) => const TerminosCondicionesDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Cabecera ────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 166, 226, 70),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.article_outlined, color: Colors.black, size: 24),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Términos y condiciones',
                    style: TextStyle(
                      fontFamily: 'RobotoCondensed',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Botón X para cerrar rápido
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.black),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // ── Contenido scrollable ────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _SeccionTitulo('1. Aceptación de los términos'),
                  _SeccionTexto(
                    'Al acceder y utilizar Kultux, aceptas estar sujeto a estos Términos y Condiciones. '
                        'Si no estás de acuerdo con alguna parte de estos términos, te pedimos que no utilices la aplicación.',
                  ),

                  _SeccionTitulo('2. Uso de la aplicación'),
                  _SeccionTexto(
                    'Kultux está destinada a usuarios mayores de 14 años. Al registrarte, garantizas que la información '
                        'proporcionada es verídica y que mantendrás tus credenciales de acceso en confidencialidad. '
                        'El uso de la aplicación con fines fraudulentos, ilegales o perjudiciales queda estrictamente prohibido.',
                  ),

                  _SeccionTitulo('3. Cuenta de usuario'),
                  _SeccionTexto(
                    'Eres responsable de todas las actividades que ocurran bajo tu cuenta. '
                        'Kultux se reserva el derecho de suspender o eliminar cuentas que incumplan estos términos, '
                        'sin previo aviso y sin responsabilidad hacia el usuario afectado.',
                  ),

                  _SeccionTitulo('4. Contenido del usuario'),
                  _SeccionTexto(
                    'Al publicar contenido en Kultux, otorgas a la plataforma una licencia no exclusiva para mostrar '
                        'dicho contenido. No debes publicar material que sea ilegal, ofensivo, difamatorio o que infrinja '
                        'derechos de terceros. Kultux no se hace responsable del contenido generado por los usuarios.',
                  ),

                  _SeccionTitulo('5. Propiedad intelectual'),
                  _SeccionTexto(
                    'Todos los elementos de Kultux (diseño, logotipos, código fuente, etc.) son propiedad de sus '
                        'desarrolladores y están protegidos por la legislación vigente en materia de propiedad intelectual. '
                        'Queda prohibida su reproducción sin autorización expresa.',
                  ),

                  _SeccionTitulo('6. Limitación de responsabilidad'),
                  _SeccionTexto(
                    'Kultux se proporciona "tal cual", sin garantías de ningún tipo. No nos hacemos responsables '
                        'de daños directos o indirectos derivados del uso o la imposibilidad de uso de la aplicación, '
                        'ni de la exactitud o completitud de la información que contiene.',
                  ),

                  _SeccionTitulo('7. Modificaciones'),
                  _SeccionTexto(
                    'Nos reservamos el derecho de modificar estos términos en cualquier momento. '
                        'Te notificaremos los cambios relevantes a través de la aplicación. El uso continuado '
                        'de Kultux tras la publicación de cambios implica la aceptación de los nuevos términos.',
                  ),

                  _SeccionTitulo('8. Legislación aplicable'),
                  _SeccionTexto(
                    'Estos términos se rigen por la legislación española vigente. Cualquier disputa derivada '
                        'del uso de Kultux se someterá a los tribunales competentes de la ciudad de Badajoz, España.',
                  ),

                  SizedBox(height: 8),
                  Text(
                    'Última actualización: mayo de 2025',
                    style: TextStyle(
                      fontFamily: 'RobotoCondensed',
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Botón Cerrar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 166, 226, 70),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(
                    fontFamily: 'RobotoCondensed',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares privados ──────────────────────────────────────────────

class _SeccionTitulo extends StatelessWidget {
  final String texto;
  const _SeccionTitulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        texto,
        style: const TextStyle(
          fontFamily: 'RobotoCondensed',
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _SeccionTexto extends StatelessWidget {
  final String texto;
  const _SeccionTexto(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontFamily: 'RobotoCondensed',
        fontSize: 13,
        color: Colors.black87,
        height: 1.5,
      ),
    );
  }
}