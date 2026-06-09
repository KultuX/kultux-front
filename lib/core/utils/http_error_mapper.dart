import 'package:kultux/core/utils/ui_state.dart';

class UiError {
  final UiState estado;
  final String mensaje;

  const UiError(this.estado, this.mensaje);
}

UiError statusCodeMapper(int statusCode) {
  switch (statusCode) {
    case 204:
    case 404:
      return const UiError(UiState.empty, 'No se han encontrado resultados');
    case 400:
      return const UiError(UiState.error, 'Los datos no son correctos');
    case 401:
      return const UiError(
        UiState.error,
        'No tienes permiso para realizar esta acción.',
      );
    case 403:
      return const UiError(
        UiState.error,
        'Tu sesión ha caducado. Inicia sesión de nuevo.',
      );
    case 409:
      return const UiError(UiState.error, 'Ya existe este usuario.');

    case >= 500:
      return const UiError(
        UiState.error,
        'Error del servidor. Inténtalo más tarde.',
      );

    default:
      return const UiError(UiState.error, 'Ha ocurrido un error inesperado');
  }
}
