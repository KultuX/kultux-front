import 'package:flutter/material.dart';

class PoliticaPrivacidadDialog extends StatelessWidget {
  const PoliticaPrivacidadDialog({super.key});

  /// Abre el diálogo de Política de Privacidad.
  /// Se cierra pulsando el botón "Cerrar" o tocando fuera del diálogo.
  static Future<void> mostrar(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const PoliticaPrivacidadDialog(),
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
                const Icon(Icons.privacy_tip_outlined, color: Colors.black, size: 24),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Política de privacidad',
                    style: TextStyle(
                      fontFamily: 'RobotoCondensed',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
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
                  _SeccionTitulo('1. Responsable del tratamiento'),
                  _SeccionTexto(
                    'El responsable del tratamiento de los datos personales recogidos a través de Kultux es el equipo '
                        'desarrollador de la aplicación, con sede en Badajoz, España. Puedes contactarnos en cualquier momento '
                        'a través de los correos habilitados en la sección "Contacta con nosotros".',
                  ),

                  _SeccionTitulo('2. Datos que recopilamos'),
                  _SeccionTexto(
                    'Recopilamos los datos que tú mismo nos proporcionas al registrarte y usar la aplicación, entre ellos: '
                        'nombre de usuario, dirección de correo electrónico, foto de perfil (opcional) y cualquier contenido '
                        'que publiques dentro de la plataforma. No recogemos datos de localización ni accedemos a tu agenda '
                        'de contactos.',
                  ),

                  _SeccionTitulo('3. Finalidad del tratamiento'),
                  _SeccionTexto(
                    'Tus datos se utilizan exclusivamente para: gestionar tu cuenta y permitirte acceder a las '
                        'funcionalidades de Kultux, personalizar tu experiencia dentro de la aplicación, y enviarte '
                        'notificaciones relacionadas con la actividad de tu cuenta cuando las tengas activadas.',
                  ),

                  _SeccionTitulo('4. Base legal'),
                  _SeccionTexto(
                    'El tratamiento de tus datos se basa en el consentimiento que otorgas al aceptar estos términos '
                        'durante el proceso de registro, de conformidad con el Reglamento General de Protección de Datos '
                        '(RGPD) y la Ley Orgánica 3/2018 de Protección de Datos Personales (LOPDGDD).',
                  ),

                  _SeccionTitulo('5. Conservación de los datos'),
                  _SeccionTexto(
                    'Conservamos tus datos mientras mantengas una cuenta activa en Kultux. Si decides eliminar tu cuenta, '
                        'tus datos personales serán suprimidos de nuestros sistemas en un plazo máximo de 30 días, salvo '
                        'obligación legal de conservación.',
                  ),

                  _SeccionTitulo('6. Cesión de datos a terceros'),
                  _SeccionTexto(
                    'Kultux no vende, alquila ni cede tus datos personales a terceros con fines comerciales. '
                        'Únicamente podrían compartirse con proveedores técnicos estrictamente necesarios para el '
                        'funcionamiento de la plataforma, quienes están sujetos a las mismas obligaciones de confidencialidad.',
                  ),

                  _SeccionTitulo('7. Tus derechos'),
                  _SeccionTexto(
                    'En cualquier momento puedes ejercer tus derechos de acceso, rectificación, supresión, oposición, '
                        'limitación del tratamiento y portabilidad de tus datos escribiéndonos a los correos indicados en '
                        '"Contacta con nosotros". También tienes derecho a presentar una reclamación ante la Agencia Española '
                        'de Protección de Datos (www.aepd.es).',
                  ),

                  _SeccionTitulo('8. Seguridad'),
                  _SeccionTexto(
                    'Aplicamos medidas técnicas y organizativas adecuadas para proteger tus datos frente a accesos no '
                        'autorizados, pérdida o destrucción accidental. Sin embargo, ningún sistema de transmisión por '
                        'Internet es completamente seguro, por lo que no podemos garantizar una seguridad absoluta.',
                  ),

                  _SeccionTitulo('9. Cambios en esta política'),
                  _SeccionTexto(
                    'Podemos actualizar esta Política de Privacidad ocasionalmente. Te notificaremos cualquier cambio '
                        'significativo a través de la aplicación. Te recomendamos revisarla periódicamente. El uso continuado '
                        'de Kultux tras la publicación de cambios implica su aceptación.',
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