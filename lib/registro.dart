
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/componentes/text_fields.dart';
import 'package:kultux/componentes/botones.dart';
import 'package:kultux/main.dart';
class RegistroPage extends StatefulWidget{
  const RegistroPage({super.key});
  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage>{
   bool _checkedTerminos = false;
   bool _checkedPolitica = false;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Image.asset("assets/images/logo_registro.png", width:200, height: 200,),
            const SizedBox(height: 20,),
            CamposPersonalizados.normal(titulo: "Nombre"),
            const SizedBox(height: 20,),
            CamposPersonalizados.normal(titulo: "Apellidos"),
            const SizedBox(height: 20,),
            CamposPersonalizados.normal(titulo: "Correo electrónico"),
            const SizedBox(height: 20,),
            CamposPersonalizados.password(titulo: "Contraseña"),
            const SizedBox(height: 20,),
            CamposPersonalizados.password(titulo: "Repite contraseña"),
            const SizedBox(height: 20,),
            //Extendible
            _desplegable(titulo: "Localidad"),
            const SizedBox(height: 20,),
            // Fechas
            _calendario(titulo: "Fecha de nacimiento"),
            const SizedBox(height: 20,),
            Column(mainAxisAlignment: .start,
            children: [
              Row(
                  children:[
                    _check(
                        checked:_checkedTerminos,
                        pulsar: (valor) => setState(()=> _checkedTerminos = valor ?? false)),
                    _textoConLink(normal:'Aceptar nuestros ' , link:'Términos y Condiciones')
                  ]),
              Row(
                  children:[
                    _check(
                        checked:_checkedPolitica,
                    pulsar: (valor) => setState(()=> _checkedPolitica = valor ?? false)),
                    _textoConLink(normal:'Aceptar nuestra ' , link:'Política de Privacidad')
                  ]),
            ],),
            const SizedBox(height: 20,),
            Row(mainAxisAlignment: .center,
                children:[
                  BotonesGenerico(
                      titulo:"Registrarse",
                      ancho:127),
                  const SizedBox(width: 50,),
                  BotonesGenerico(
                      titulo:"Volver",
                      ancho:127,
                    pulsar: (){
                        Navigator.pop(context);
                    }
                  )
                ]
            )
          ],
        ),
      ),
    );
  }

  Widget _textoConLink({required String normal, required String link}){
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'RobotoCondensed',
          color: Colors.black,
          fontSize: 14
        ),
        children: [
          TextSpan(text:normal),
          TextSpan(
              text: link,
              style: TextStyle(
                  color:Colors.blue,
                  decoration: .underline
              ),
          )
        ]
      )
    );
  }

  Widget _check({required bool checked, required ValueChanged<bool?> pulsar}){
    return Checkbox(
        value: checked,
        onChanged: pulsar,
        checkColor: Colors.black,
        fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.selected)) {
            return Color.fromARGB(255, 166, 226, 70); // verde solo al marcar
          }
          return null; // fondo transparente al desmarcar → borde intacto
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // hace las esquinas redondeadas
          side: BorderSide(color: Colors.black26, width: 1), // borde del checkbox
        )
    );
  }

  Widget _calendario({required String titulo, double ancho = 364}){
    TextEditingController _controller = TextEditingController();
    return SizedBox(
      width: ancho,
      child: TextField(
        controller: _controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: titulo,
          suffixIcon: SizedBox(width:15,height:15,child:Center(child:SvgPicture.asset("assets/iconos/calendario_registro.svg"))),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
        ),
        onTap: () async {
          DateTime? fecha = await showDatePicker(
            context: context,
            initialDate:DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now()
          );
          if(fecha !=null){
            setState(() {
              _controller.text = "${fecha.day}/${fecha.month}/${fecha.year}";
            });
          }
        }

      )
    );
  }

  Widget _desplegable({required String titulo, double ancho = 364}){
    final List<String> localidades = ['Mérida','Badajoz','Cáceres','Plasencia','Navalmoral de la Mata','Don Benito','Zafra','Villafranca de los Barros'];
    String? localidadSeleccionada = localidades[0];
    return SizedBox(
      width: ancho,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: titulo,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        child: DropdownButton<String>(
          value : localidadSeleccionada,
          hint: Text(titulo, style: TextStyle(fontFamily: 'RobotoCondensed'),),
          onChanged: (String? nuevo){
            setState(() {
              localidadSeleccionada = nuevo!;
            });
          },
          items: localidades.map((loc){
            return DropdownMenuItem<String>(
              value: loc,
              child: Text(loc, style: TextStyle(fontFamily: 'RobotoCondensed')),
            );
          }).toList(),
          underline: const SizedBox(),

        )
      )
    );
  }

}
