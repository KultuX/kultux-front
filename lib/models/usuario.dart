class Usuario{
  final String email;
  String? password;
  String? nombre;
  String? apellidos;
  String? fechaNacimiento;

  Usuario._({
    required this.email,
    this.password

  });

/*
  Usuario.loggeado(Map<String, json> json){
    return Usuario._(
      email: json['email'],

    )
    ;
  }
  Usuario.toJson(){
    return {

    }
  }
  Map<String, dynamic> toJson(){
    return {
      'nombre' : this.nombre,
      'apellidos' : this.apellidos,
      'correo' : this.email,
      'pass' : this.password,

    }
  }*/




}