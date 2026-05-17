import 'package:flutter/material.dart';
import 'package:kultux/buscarActividad.dart';
import 'package:kultux/buscarRestaurante.dart';
import 'package:kultux/buscarAlojamiento.dart';

import 'componentes/cabecera.dart';

class BuscarPage extends StatefulWidget {
  final Function(dynamic)? onDetalleSeleccionado;
  final int selectedIndex;
  final Function(int) onIndexChanged;
  const BuscarPage({super.key, this.onDetalleSeleccionado, required this.selectedIndex, required this.onIndexChanged});

  @override
  State<BuscarPage> createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  late int _selectedIndex = 0;

  final List<String> _categorias = ["Actividades", "Restaurantes", "Alojamientos"];

  @override
  void initState(){
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CabeceraPagina(
          titulo: 'Buscar ${_categorias[_selectedIndex]}',
          subtitulo: 'Conoce Extremadura',
          mostrarImagenDerecha: true,
        ),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              _categorias.length,
                  (index) => GestureDetector(
                onTap: () => setState(()  {
                  _selectedIndex = index;
                  widget.onIndexChanged(index);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _selectedIndex == index
                        ? Color.fromARGB(255, 166, 226, 70)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _categorias[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _selectedIndex == index
                          ? Colors.black
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return BuscarActividadPage(onDetalleSeleccionado: widget.onDetalleSeleccionado);
      case 1:
        return BuscarRestaurantePage(onDetalleSeleccionado: widget.onDetalleSeleccionado);
      case 2:
        return BuscarAlojamientoPage(onDetalleSeleccionado: widget.onDetalleSeleccionado);
      default:
        return const SizedBox.shrink();
    }
  }
}