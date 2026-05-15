class Validaciones {

  static bool password(String value) {
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\w\s]).{8,}$',
    );
    return regex.hasMatch(value);
  }

  static String? passwordError(String value) {
    if (value.isEmpty) return null; // opcional
    if (!password(value)) {
      return 'Debe tener al menos 8 caracteres, con mayúsculas, minúsculas, números y un carácter especial (/, -, *, etc.).';
    }
    return null;
  }


  static bool email(String value) {
    final regex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    return regex.hasMatch(value);
  }

  static String? emailError(String value) {
    if (value.isEmpty) return null;
    if (!email(value)) {
      return 'Introduce un email válido (ejemplo@correo.com)';
    }
    return null;
  }


  static bool requerido(String value) => value.trim().isNotEmpty;

  static String? requeridoError(String value, String campo) {
    if (value.trim().isEmpty) {
      return 'El campo $campo es obligatorio';
    }
    return null;
  }
}
