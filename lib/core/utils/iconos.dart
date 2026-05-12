class Iconos{
  static const Map<String, String> iconosAlojamiento = {
    "HOTEL":"assets/iconos/hotel.svg",
    "HOSTAL":"assets/iconos/hostal.svg",
    "APARTAMENTO_TURISTICO":"assets/iconos/apartamento.svg",
    "CASA_RURAL":"assets/iconos/casa_rural.svg",
    "PENSION":"assets/iconos/hostal.svg",
    "CAMPING":"assets/iconos/casa_rural.svg",
    "ALBERGUE":"assets/iconos/casa_rural.svg",
    "PARADOR": "assets/iconos/casa_rural.svg",
    "RESORT":"assets/iconos/hotel.svg",
    "BALNEARIO":"assets/iconos/hotel.svg",
    "APARTAHOTEL":"assets/iconos/hostal.svg",
    "BUNGALOW":"assets/iconos/hostal.svg",
    "FINCA":"assets/iconos/casa_rural.svg",
  };
  static const Map<String, String> iconosRestaurante = {
    "TRADICIONAL":"assets/iconos/restaurantes.svg",
    "EXTREMEÑA":"assets/iconos/restaurantes.svg",
    "INTERNACIONAL":"assets/iconos/restaurantes.svg",
    "ESPAÑOLA":"assets/iconos/restaurantes.svg",
    "ALTA_COCINA":"assets/iconos/restaurantes.svg",
    "ASADORES_Y_PARRILLAS":"assets/iconos/restaurantes.svg",
    "MARISQUERIAS":"assets/iconos/restaurantes.svg",
    "ITALIANO": "assets/iconos/restaurantes.svg",
    "MEXICANO":"assets/iconos/restaurantes.svg",
    "ASIATICO":"assets/iconos/restaurantes.svg",
    "VEGETARIANO":"assets/iconos/restaurantes.svg",
    "VEGANO":"assets/iconos/restaurantes.svg",
    "TAPAS":"assets/iconos/cerveceria.svg",
    "CAFETERIA":"assets/iconos/cafeteria.svg",
    "HAMBURGUESERIA":"assets/iconos/restaurantes.svg",
    "PIZZERIA":"assets/iconos/restaurantes.svg",
    "COPAS":"assets/iconos/copas.svg"
  };

  static String getIconoAlojamiento(String categoria){
    return iconosAlojamiento[categoria] ?? 'assets/iconos/hotel.svg';
  }

  static String getIconoRestaurante(String categoria){
    return iconosRestaurante[categoria] ?? 'assets/iconos/restaurantes.svg';
  }

}