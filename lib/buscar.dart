import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/models/localidad.dart';
import 'package:kultux/api/localidadesApi.dart';
class BuscarPage extends StatefulWidget{
  const BuscarPage({super.key});
  @override
  State<BuscarPage> createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  late Future<List<Localidad>> futureLocalidad;

  @override
  void initState() {
    super.initState();
    futureLocalidad = LocalidadApiService.obtenerLocalidadNombres();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child:Column(
      mainAxisAlignment: .center,
      children: [
        Container(
          width: 341,
          child: SearchBar(
            hintText: 'Buscar',
            leading: SvgPicture.asset(
              "assets/iconos/buscar.svg",
              colorFilter: ColorFilter.mode(
                  Colors.black26,
                  BlendMode.srcIn
              ),
            ),
            backgroundColor: WidgetStateProperty.all(Colors.grey[350]),
          ),

        ),
        const SizedBox(height: 20,),
        Container(
          width: 350,
          child: Row(
            children: [
              DropdownMenu<String>(
                width: 165,
                initialSelection: 'Categoría',
                label: const Text('Categoría'),
                menuStyle: MenuStyle(
                  shape: WidgetStateProperty.resolveWith<OutlinedBorder?>(
                      (states) =>  RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.grey.shade300,
                  ),
                ),
                dropdownMenuEntries: [
                  'Gastronomía',
                  'Teatro',
                  'Comedia',
                  'Música',
                  'Infantil',
                  'Noche'
                ]
                    .map((cat) => DropdownMenuEntry(value: cat, label: cat))
                    .toList(),
                onSelected: (value) => print(value),
              ),
              const SizedBox(width: 20,),
              _selectorLocalidad(),
            ],
          ),
        ),
      ],

    ));
  }

  Widget _selectorLocalidad() {
    String _inicial = 'Ubicación';

    return FutureBuilder<List<Localidad>>(
      future: futureLocalidad,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error al cargar las localidades: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No hay localidades disponibles');
        } else {
          final nombres = snapshot.data!.map((l) => l.nombre).toList();

          return Container(
            child: DropdownMenu<String>(
              width: 165,
              initialSelection: _inicial,
              label: const Text('Ubicación'),
              menuHeight: 250,
              menuStyle: MenuStyle(
                shape: WidgetStateProperty.resolveWith<OutlinedBorder?>(
                      (states) =>  RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))
                  ),
                ),
                backgroundColor: MaterialStateProperty.resolveWith(
                      (states) => Colors.grey.shade300,
                ),
              ),
              dropdownMenuEntries: nombres
                  .map((nombre) =>
                  DropdownMenuEntry(
                    value: nombre,
                    label: nombre,
                  ))
                  .toList(),
            ),
          );
        }
      },
    );
  }

}
