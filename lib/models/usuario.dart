class Usuario{
  final String email;
  int? id;
  String? password;
  String? nombre;
  String? apellidos;
  int? localidad;
  String? fechaNacimiento;
  String? imagenPerfil;

  static Usuario? usuarioActual;

  Usuario._({
    required this.email,
    this.id,
    this.password,
    this.nombre,
    this.localidad,
    this.apellidos,
    this.fechaNacimiento,
    this.imagenPerfil
  });


  factory Usuario.logeado(Map<String, dynamic> json){
    return Usuario._(
      email: json['email'],
      id: json['id'],
      apellidos:json['apellidos'],
      password: json['password'],
      nombre: json['nombre'],
      localidad: json['localidad'],
      fechaNacimiento: json['fechaNacimiento'],
      imagenPerfil: json['imagenPerfil']
    );
  }

  factory Usuario.registro(Map<String, dynamic> datos){
    return Usuario._(
      nombre: datos['nombre'],
      apellidos: datos['apellidos'],
      email: datos['email'],
      password: datos['password'],
      localidad: datos['localidad'],
      fechaNacimiento: datos['fechaNacimiento']
    );
  }
  factory Usuario.login(String email, String password){
    return Usuario._(
      email: email,
      password: password
    );
  }

  Map<String, dynamic> toJsonLogin(){
    return {
      'email' : this.email,
      'password' : this.password
    };
  }
  Map<String, dynamic> toJsonRegistro(){
    return {
      "nombre" : this.nombre,
      "apellidos" : this.apellidos,
      "email" : this.email,
      "password" : this.password,
      "localidad" : this.localidad,
      "fechaNacimiento" : this.fechaNacimiento
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'id': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'localidad': localidad,
      'fechaNacimiento': fechaNacimiento,
      'imagenPerfil': imagenPerfil,
      // password no se guarda en disco por seguridad
    };
  }

  /// Construye un Usuario desde SharedPreferences
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario._(
      email: json['email'],
      id: json['id'],
      nombre: json['nombre'],
      apellidos: json['apellidos'],
      localidad: json['localidad'],
      fechaNacimiento: json['fechaNacimiento'],
      imagenPerfil: json['imagenPerfil'],
    );
  }

  factory Usuario.desdeEdicion(Map<String, dynamic> json) {
    return Usuario._(
      email: json['email'],
      nombre: json['nombre'],
      apellidos: json['apellidos'],
      localidad: json['localidad'],
      imagenPerfil: json['urlImagenPerfil'],
      id: Usuario.usuarioActual?.id,
    );
  }


  @override
  String toString() {
    return '''
Usuario(
  id: $id,
  email: $email,
  nombre: $nombre,
  apellidos: $apellidos,
  localidad: $localidad,
  fechaNacimiento: $fechaNacimiento,
  imagenPerfil: $imagenPerfil
)
''';
  }

}