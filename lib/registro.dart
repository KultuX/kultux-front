
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/componentes/text_fields.dart';
import 'package:kultux/componentes/botones.dart';
import 'package:kultux/models/localidad.dart';
import 'package:kultux/api/localidadesApi.dart';
import 'package:kultux/api/usuariosAPI.dart';
import 'package:kultux/models/usuario.dart';
import 'package:kultux/componentes/terminos_condiciones_dialog.dart';
import 'package:kultux/componentes/politica_privacidad_dialog.dart';
import 'package:flutter/gestures.dart';

class RegistroPage extends StatefulWidget{
  const RegistroPage({super.key});
  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage>{
   bool _checkedTerminos = false;
   bool _checkedPolitica = false;
   String? email;

   Localidad? _localidadSeleccionada;

   static Map<String, TextEditingController>? controllers;
   final Map<String, String?> _errores = {};

   late Future<List<Localidad>> futureLocalidades;

   Map<String, TextEditingController> _controllers(){
     return {
       'nombre' : controler(),
       'apellidos' : controler(),
       'email' : controler(),
       'password' : controler(),
       'password2' : controler(),
       'localidad' : controler(),
       'fechaNacimiento' : controler()
     };
   }


   TextEditingController controler(){
     return TextEditingController();
   }
   @override
   void initState(){
     super.initState();
     futureLocalidades = LocalidadApiService.obtenerLocalidadNombres();
     controllers = _controllers();

   }

   Future<bool> registrarUsuario() async {
     _errores.clear();
     //1º Comprobar que los dos checkbos estén marcados
     if (!_checkedTerminos || !_checkedPolitica) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text(
               "⚠️ Debes aceptar los Términos y la Política de privacidad. ⚠️ "),
         ),
       );
       return false;
     }
     for (final controller in controllers!.values) {
       if (controller.text.trim().isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text(" ⚠️  Todos los campos son obligatorios. ⚠️ ")),
         );
         return false;
       }
     }

     if(controllers!['password']!.text != controllers!['password2']!.text){
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Las contraseñas no coinciden.❌")),
       );
       return false;
     }

     final locTxt = controllers!['localidad']!.text;
     if (locTxt.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Selecciona una localidad')),
       );
       return false;
     }
     final locId = int.tryParse(locTxt);
     if (locId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Localidad inválida')),
       );
       return false;
     }

     Usuario? userRegistro  = Usuario.registro({
       'nombre' : controllers!['nombre']!.text,
       'apellidos' : controllers!['apellidos']!.text,
       'email' :  controllers!['email']!.text,
       'password' : controllers!['password']!.text,
       'localidad' : int.parse(controllers!['localidad']!.text),
       'fechaNacimiento' : controllers!['fechaNacimiento']!.text
     });
     try{
       email = await UsuarioApiService.registroUsuario(userRegistro);
       return true;
     } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('⚠️ Ups.. algo ha ido mal. Revisa los datos introducidos.')),
       );
       return false;
     }
   }
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
            CamposPersonalizados.normal(titulo: "Nombre", controller: controllers!['nombre']!),
            const SizedBox(height: 20,),
            CamposPersonalizados.normal(titulo: "Apellidos", controller: controllers!['apellidos']!),
            const SizedBox(height: 20,),
            CamposPersonalizados.normal(titulo: "Correo electrónico", controller: controllers!['email']!),
            const SizedBox(height: 20,),
            CamposPersonalizados.password(titulo: "Contraseña", controller: controllers!['password']!),
            const SizedBox(height: 20,),
            CamposPersonalizados.password(titulo: "Repite contraseña", controller: controllers!['password2']!),
            const SizedBox(height: 20,),
            //Extendible
            _desplegable(titulo: "Localidad"),
            const SizedBox(height: 20,),
            // Fechas
            _calendario(titulo: "Fecha de nacimiento",controler: controllers!['fechaNacimiento']!),
            const SizedBox(height: 20,),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                    children: [
                      _check(
                          checked: _checkedTerminos,
                          pulsar: (valor) => setState(() => _checkedTerminos = valor ?? false)),
                      _textoConLink(
                          normal: 'Aceptar nuestros ',
                          link: 'Términos y Condiciones',
                          onTap: () => TerminosCondicionesDialog.mostrar(context)),
                    ]
                ),
                Row(
                    children: [
                      _check(
                          checked: _checkedPolitica,
                          pulsar: (valor) => setState(() => _checkedPolitica = valor ?? false)),
                      _textoConLink(
                          normal: 'Aceptar nuestra ',
                          link: 'Política de Privacidad',
                          onTap: () => PoliticaPrivacidadDialog.mostrar(context)),
                    ]
                ),
              ],
            ),
            const SizedBox(height: 20,),
            Row(mainAxisAlignment: .center,
                children:[
                  BotonesGenerico(
                      titulo:"Registrarse",
                      ancho:127,
                    pulsar: () async {
                        if(await registrarUsuario()){
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                showCloseIcon: true,
                                content: Text(textAlign: .center,''
                                    '✅¡Registro completado!')),
                          );

                      }
                    }
                  ),
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

  Widget _textoConLink({required String normal, required String link, VoidCallback? onTap}){
    return RichText(
        text: TextSpan(
            style: const TextStyle(
                fontFamily: 'RobotoCondensed',
                color: Colors.black,
                fontSize: 14
            ),
            children: [
              TextSpan(text: normal),
              TextSpan(
                text: link,
                style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline
                ),
                recognizer: onTap != null
                    ? (TapGestureRecognizer()..onTap = onTap)
                    : null,
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

  Widget _calendario({required String titulo, double ancho = 364, TextEditingController? controler }){
    return SizedBox(
      width: ancho,
      child: TextField(
        controller: controler!,
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
              controler.text = fechaFormateada(fecha);
            });
          }
        }

      )
    );
  }

   String fechaFormateada(DateTime fecha) {
     final month = fecha.month.toString().padLeft(2,'0');
     final day = fecha.day.toString().padLeft(2,'0');
     return "${fecha.year}-$month-$day";
   }

  Widget _desplegable({required String titulo, double ancho = 364, TextEditingController? controler}){
    return /*SizedBox(
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
        child:*/
          FutureBuilder<List<Localidad>>(
            future: futureLocalidades,
            builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.waiting)
                return const CircularProgressIndicator(color: Color.fromARGB(255, 166, 226, 70));
              else if (snapshot.hasError)
                return Text('Ups..Error al cargar las localidades. Prueba a reiniciar la APP');
              else if (!snapshot.hasData || snapshot.data!.isEmpty)
                return const Text('Noy ha localidades disponibles.');
              else{}
              final localidades = snapshot.data!;
              return Container(
                child: DropdownMenu<Localidad>(
                  width: ancho,
                    initialSelection: _localidadSeleccionada,
                    label: const Text('Ubicación'),
                    menuHeight: 250,
                    dropdownMenuEntries: localidades.map((localidad) =>
                    DropdownMenuEntry<Localidad>(
                      value: localidad,
                      label: localidad.nombre
                    )).toList(),
                  onSelected: (Localidad? seleccionada){
                    setState((){
                      _localidadSeleccionada = seleccionada;
                      controllers!['localidad']!.text = seleccionada?.ine.toString() ?? '';
                    });
                  },
                )
              );
            }
          );
     // )
   // );
  }




}
