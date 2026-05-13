import 'package:kultux/core/utils/estado_ui.dart';

class UiError {
  final EstadoUi estado;
  final String mensaje;

  const UiError(this.estado, this.mensaje);
}

UiError mapearStatusCode(int statusCode) {
  switch (statusCode) {
    case 204:
    case 404:
      return const UiError(
        EstadoUi.vacio,
        'No se han encontrado resultados',
      );
    case 400:
      return const UiError(
        EstadoUi.error,
        'Los datos no son correctos'
      );
    case 401:
      return const UiError(
        EstadoUi.error,
        'No tienes permiso para realizar esta acción.'
      );
    case 403:
      return const UiError(
        EstadoUi.error,
        'Tu sesión ha caducado. Inicia sesión de nuevo.',
      );
    case 409:
      return const UiError(
        EstadoUi.error,
        'Ya existe este usuario.'
      );

    case >= 500:
      return const UiError(
        EstadoUi.error,
        'Error del servidor. Inténtalo más tarde.',
      );

    default:
      return const UiError(
        EstadoUi.error,
        'Ha ocurrido un error inesperado',
      );
  }
}