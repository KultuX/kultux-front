import 'package:flutter/material.dart';
import 'package:kultux/buscarActividad.dart';

class BuscarPage extends StatelessWidget {
  const BuscarPage({super.key});

  static const Color primaryGreen = Color.fromARGB(255, 166, 226, 70);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 📦 BODY
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            const Text(
              "¿Qué quieres explorar hoy?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Busca actividades, restaurantes o alojamientos",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            // 🧭 CARDS
            Expanded(
              child: ListView(
                children: [

                  _buildCard(
                    context,
                    title: "Actividades",
                    subtitle: "Eventos, cultura, ocio y experiencias",
                    icon: Icons.event,
                    color: primaryGreen,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const BuscarActividadPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildCard(
                    context,
                    title: "Restaurantes",
                    subtitle: "Descubre dónde comer cerca de ti",
                    icon: Icons.restaurant,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pushNamed(context, '/restaurantes');
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildCard(
                    context,
                    title: "Alojamientos",
                    subtitle: "Hoteles, casas rurales y estancias",
                    icon: Icons.hotel,
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.pushNamed(context, '/alojamientos');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }

  // 🎴 CARD REUTILIZABLE
  Widget _buildCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [

            // 🟩 ICONO LATERAL
            Container(
              width: 90,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Icon(
                icon,
                size: 40,
                color: color,
              ),
            ),

            const SizedBox(width: 16),

            // 📝 TEXTO
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}