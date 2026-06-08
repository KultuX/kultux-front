class User {
  final String email;
  int? id;
  String? password;
  String? name;
  String? surname;
  int? location;
  String? dateOfBirth;
  String? profileImage;

  static User? activeUser;

  User._({
    required this.email,
    this.id,
    this.password,
    this.name,
    this.location,
    this.surname,
    this.dateOfBirth,
    this.profileImage,
  });

  factory User.logged(Map<String, dynamic> json) {
    return User._(
      email: json['email'],
      id: json['id'],
      surname: json['apellidos'],
      password: json['password'],
      name: json['nombre'],
      location: json['localidad'],
      dateOfBirth: json['fechaNacimiento'],
      profileImage: json['imagenPerfil'],
    );
  }

  factory User.register(Map<String, dynamic> datos) {
    return User._(
      name: datos['nombre'],
      surname: datos['apellidos'],
      email: datos['email'],
      password: datos['password'],
      location: datos['localidad'],
      dateOfBirth: datos['fechaNacimiento'],
    );
  }
  factory User.login(String email, String password) {
    return User._(email: email, password: password);
  }

  Map<String, dynamic> toJsonLogin() {
    return {'email': this.email, 'password': this.password};
  }

  Map<String, dynamic> toJsonRegister() {
    return {
      "nombre": this.name,
      "apellidos": this.surname,
      "email": this.email,
      "password": this.password,
      "localidad": this.location,
      "fechaNacimiento": this.dateOfBirth,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'id': id,
      'nombre': name,
      'apellidos': surname,
      'localidad': location,
      'fechaNacimiento': dateOfBirth,
      'imagenPerfil': profileImage,
      // password no se guarda en disco por seguridad
    };
  }

  /// Construye un Usuario desde SharedPreferences
  factory User.fromJson(Map<String, dynamic> json) {
    return User._(
      email: json['email'],
      id: json['id'],
      name: json['nombre'],
      surname: json['apellidos'],
      location: json['localidad'],
      dateOfBirth: json['fechaNacimiento'],
      profileImage: json['imagenPerfil'],
    );
  }

  factory User.fromEdit(Map<String, dynamic> json) {
    return User._(
      email: json['email'],
      name: json['nombre'],
      surname: json['apellidos'],
      location: json['localidad'],
      dateOfBirth: json['fechaNacimiento'],
      profileImage: json['urlImagenPerfil'],
      id: User.activeUser?.id,
    );
  }

  @override
  String toString() {
            return '''
        Usuario(
          id: $id,
          email: $email,
          nombre: $name,
          apellidos: $surname,
          localidad: $location,
          fechaNacimiento: $dateOfBirth,
          imagenPerfil: $profileImage
        )
        ''';
   }
}
