import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/core/models/activity.dart';
import 'package:kultux/core/models/accommodation.dart';
import 'package:kultux/core/models/restaurant.dart';
import 'package:kultux/core/models/image.dart' as img;
import 'package:kultux/core/models/time_slot.dart';
import 'package:kultux/core/models/user.dart';
import 'package:kultux/data/api/interaction_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kultux/shared/widget/alert_modal.dart';
import 'package:kultux/core/utils/sharing.dart';
import 'package:kultux/core/utils/app_icons.dart';
import 'package:kultux/core/utils/formatter.dart';

import '../../shared/widget/booking_button.dart';


class AppColors {
  static const green     = Color(0xFFA6E246);
  static const greenDark = Color(0xFF639922);
  static const fondo     = Color(0xFFF1EFE9);
  static const card      = Color(0xFFFFFFFF);
  static const texto     = Color(0xFF1A1A1A);
  static const suave     = Color(0xFF6B6B6B);
  static const borde     = Color(0xFFE8E8E8);
  static const rojo      = Color(0xFFA32D2D);
  static const azul      = Color(0xFF185FA5);
}

class DetailPage extends StatefulWidget {
  final String title;
  final String? coverImage;
  final String? description;
  final String? companyPhone;
  final String? businessEmail;
  final String? startDate;
  final String? endDate;
  final String? location;
  final List<img.Image>? images;
  final Map<String, List<TimeSlot>>? schedule;
  final bool? isOpen;
  final String? bookingUrl;
  final String? webUrl;
  final String? address;
  final int? activityId;
  final int? restaurantId;
  final int? accommodationId;
  final String? companyName;
  final String? companyLogo;
  final String? category;
  final String? labelIcon;
  final double? price;
  final int? maxCapacity;
  final String? startTime;
  final String? endTime;
  final String? status;

  const DetailPage._({
    super.key,
    required this.title,
    this.coverImage,
    this.description,
    this.companyPhone,
    this.businessEmail,
    this.startDate,
    this.endDate,
    this.schedule,
    this.location,
    this.images,
    this.isOpen,
    this.bookingUrl,
    this.webUrl,
    this.address,
    this.activityId,
    this.restaurantId,
    this.accommodationId,
    this.companyName,
    this.companyLogo,
    this.category,
    this.labelIcon,
    this.price,
    this.maxCapacity,
    this.startTime,
    this.endTime,
    this.status,
  });

  List<String> get imagesList {
    if (images == null || images!.isEmpty) {
      return ['https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg'];
    }
    final sortedImages = [...images!];
    sortedImages.sort((a, b) => a.isCover ? -1 : 1);
    return sortedImages.map((i) => i.url).toList();
  }

  factory DetailPage.fromObject({required dynamic objeto}) {
    if (objeto is Activity) {
      return DetailPage._(
        title: objeto.title,
        coverImage: objeto.coverImage,
        location: objeto.location,
        description: objeto.description,
        companyPhone: objeto.companyPhone,
        businessEmail: objeto.businessEmail,
        startDate: objeto.startDate,
        endDate: objeto.endDate,
        images: objeto.images,
        bookingUrl: objeto.bookingUrl,
        webUrl: objeto.webUrl,
        address: objeto.address,
        activityId: objeto.id,
        companyName: objeto.companyName,
        companyLogo: objeto.companyLogo,
        category: objeto.activityCategory,
        labelIcon: 'assets/iconos/actividad_etiquetas.svg',
        price: objeto.price,
        maxCapacity: objeto.maxCapacity,
        startTime: objeto.startTime,
        endTime: objeto.endTime,
        status: objeto.status,
      );
    }
    if (objeto is Accommodation) {
      return DetailPage._(
        accommodationId: objeto.id,
        title: objeto.name,
        coverImage: objeto.coverImage,
        location: objeto.location,
        companyPhone: objeto.companyPhone,
        businessEmail: objeto.businessEmail,
        images: objeto.images,
        bookingUrl: objeto.bookingUrl,
        webUrl: objeto.webUrl,
        description: objeto.description,
        address: objeto.address,
        category: objeto.accommodationCategory,
        labelIcon: AppIcons.getAccommodationIcon(objeto.accommodationCategory),
      );
    }
    if (objeto is Restaurant) {
      return DetailPage._(
        restaurantId: objeto.id,
        title: objeto.name,
        coverImage: objeto.coverImage,
        location: objeto.location,
        description: objeto.description,
        companyPhone: objeto.companyPhone ?? '',
        businessEmail: objeto.businessEmail ?? '',
        schedule: objeto.schedule,
        images: objeto.images,
        isOpen: objeto.isOpen,
        bookingUrl: objeto.bookingUrl,
        webUrl: objeto.webUrl,
        address: objeto.address,
        category: objeto.restaurantCategory,
        labelIcon: AppIcons.getRestaurantIcon(objeto.restaurantCategory),
      );
    }
    throw Exception('Tipo de objeto no soportado');
  }

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _index = 0;
  late PageController _pageCtrl;

  bool get _hasBooking => widget.bookingUrl?.trim().isNotEmpty == true;
  bool get _hasWeb => widget.webUrl?.trim().isNotEmpty == true;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActivity   = widget.activityId != null;
    final isRestaurant = widget.restaurantId != null;
    final isAccommodation = widget.accommodationId != null;

    return ColoredBox(
      color: AppColors.fondo,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroCard(
              imagesList: widget.imagesList,
              index: _index,
              pageCtrl: _pageCtrl,
              status: widget.status,
              category: widget.category,
              labelIcon: widget.labelIcon,
              isActivity: isActivity,
              isRestaurant: isRestaurant,
              isAccommodation: isAccommodation,
              activityId: widget.activityId,
              restaurantId: widget.restaurantId,
              accommodationId: widget.accommodationId,
              userId: User.activeUser?.id,
              title: widget.title,
              coverImage: widget.coverImage,
              description: widget.description,
              startDate: widget.startDate,
              onPageChanged: (i) => setState(() => _index = i),
            ),


            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    widget.title,
                    style:  TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.texto,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),


                  if (widget.location != null)
                    _Direction(
                      icon: Icons.location_on_outlined,
                      text: widget.location!,
                      color: AppColors.green,
                    ),
                  if (widget.address != null && widget.address!.isNotEmpty)
                    _Direction(
                      icon: Icons.near_me_outlined,
                      text: widget.address!,
                      color: AppColors.suave,
                    ),

                  const SizedBox(height: 14),


                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (isActivity && widget.startDate != null)
                        _DateTime(
                          icon: Icons.calendar_today_outlined,
                          text: '${dateFormatter(widget.startDate)}'
                              '${widget.endDate != null ? ' – ${dateFormatter(widget.endDate)}' : ''}',
                        ),
                      if (isActivity && widget.startTime != null)
                        _DateTime(
                          icon: Icons.access_time_outlined,
                          text: widget.endTime != null
                              ? '${widget.startTime} – ${widget.endTime}'
                              : widget.startTime!,
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.borde, height: 1),
                  const SizedBox(height: 20),
                  if (isActivity && (widget.price != null || widget.maxCapacity != null)) ...[
                    Row(
                      children: [
                        if (widget.price != null)
                          Expanded(child: _PriceCapacity(
                            icon: Icons.euro_outlined,
                            label: 'Precio',
                            value: widget.price == 0 ? 'Gratis' : '${widget.price}€',
                          )),
                        if (widget.price != null && widget.maxCapacity != null)
                          const SizedBox(width: 12),
                        if (widget.maxCapacity != null)
                          Expanded(child: _PriceCapacity(
                            icon: Icons.people_alt_outlined,
                            label: 'Aforo',
                            value: widget.maxCapacity == 0 ? 'Sin límite' : '${widget.maxCapacity} personas',
                          )),
                      ],
                    ),
                  ],
                  const Divider(color: AppColors.borde, height: 1),
                  const SizedBox(height: 20),

                  if (widget.description?.trim().isNotEmpty == true) ...[
                    _Title('Descripción'),
                    const SizedBox(height: 8),
                    Text(
                      widget.description!,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.65,
                        color: AppColors.texto,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.borde, height: 1),
                    const SizedBox(height: 20),
                  ],

                  if (isRestaurant && widget.schedule != null) ...[
                    _Schedule(schedule: widget.schedule!, isOpen: widget.isOpen),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.borde, height: 1),
                    const SizedBox(height: 20),
                  ],


                  _Title('Información'),
                  const SizedBox(height: 12),

                  if (isActivity && widget.companyName != null)
                    _InfoRow(icon: Icons.store_outlined, label: 'Organizado por', text: widget.companyName!),
                  if (_hasWeb)
                    _InfoRow(
                      icon: Icons.language_outlined,
                      label: 'Web oficial',
                      text: widget.webUrl!,
                      isUrl: true,
                      onTap: () async => launchUrl(Uri.parse(normUrl(widget.webUrl!)), mode: LaunchMode.externalApplication),
                    ),
                  if (widget.companyPhone?.trim().isNotEmpty == true)
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Teléfono',
                      text: widget.companyPhone!,
                      isUrl: true,
                      onTap: () async => launchUrl(Uri.parse('tel:${widget.companyPhone}')),
                    ),
                  if (widget.businessEmail?.trim().isNotEmpty == true)
                    _InfoRow(
                      icon: Icons.mail_outline,
                      label: 'Correo',
                      text: widget.businessEmail!,
                      isUrl: true,
                      onTap: () async => launchUrl(Uri.parse('mailto:${widget.businessEmail}')),
                    ),
                  const SizedBox(height: 28),
                  BookingButton(
                    enable: _hasBooking,
                    isActivity: isActivity,
                    isRestaurant: isRestaurant,
                    onTap: _hasBooking
                        ? () async {
                      final uri = Uri.parse(normUrl(widget.bookingUrl!));
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    }
                        : null,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _HeroCard extends StatelessWidget {
  final List<String> imagesList;
  final int index;
  final PageController pageCtrl;
  final String? status;
  final String? category;
  final String? labelIcon;
  final bool isActivity;
  final bool isRestaurant;
  final bool isAccommodation;
  final int? activityId;
  final int? restaurantId;
  final int? accommodationId;
  final int? userId;
  final String title;
  final String? coverImage;
  final String? description;
  final String? startDate;
  final ValueChanged<int> onPageChanged;

  const _HeroCard({
    required this.imagesList,
    required this.index,
    required this.pageCtrl,
    required this.isActivity,
    required this.isRestaurant,
    required this.isAccommodation,
    required this.onPageChanged,
    required this.title,
    this.status,
    this.category,
    this.labelIcon,
    this.activityId,
    this.restaurantId,
    this.accommodationId,
    this.userId,
    this.coverImage,
    this.description,
    this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    final hasMultiple = imagesList.length > 1;

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Stack(
        fit: StackFit.expand,
        children: [

          PageView.builder(
            controller: pageCtrl,
            onPageChanged: onPageChanged,
            itemCount: imagesList.length,
            itemBuilder: (_, i) => CachedNetworkImage(
              imageUrl: imagesList[i],
              fit: BoxFit.cover,
              memCacheWidth: 800,
              placeholder: (_, __) => const ColoredBox(color: Color(0xFFD4D0C8)),
              errorWidget: (_, __, ___) => Container(
                color: const Color(0xFFD4D0C8),
                child: const Icon(Icons.image_outlined, color: Color(0xFF999999), size: 48),
              ),
            ),
          ),


          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x88000000), Colors.transparent],
                ),
              ),
            ),
          ),


          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 140,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xCC000000), Colors.transparent],
                ),
              ),
            ),
          ),


          if (status != null && status!.isNotEmpty)
            Positioned(
              top: 14, left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: status == 'PROXIMAMENTE' ? const Color(0xE0185FA5) : const Color(0xE0A32D2D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status!,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
                ),
              ),
            ),


          Positioned(
            top: 10, right: 12,
            child: Row(
              children: [
                _SaveButton(
                  isActivity: isActivity,
                  isRestaurant: isRestaurant,
                  isAccommodation: isAccommodation,
                  activityId: activityId,
                  restaurantId: restaurantId,
                  accommodationId: accommodationId,
                  userId: userId,
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    final tipo = isActivity ? Tipe.actividad : isRestaurant ? Tipe.restaurante : Tipe.alojamiento;
                    coverImage != null
                        ? Sharing.sharingImage(titulo: title, tipo: tipo, imagenUrl: coverImage!, descripcion: description, fecha: startDate)
                        : Sharing.sharing(titulo: title, tipo: tipo, descripcion: description, fecha: startDate);
                  },
                  child: _Buttons(icon: Icons.share_outlined),
                ),
              ],
            ),
          ),


          if (category != null && labelIcon != null)
            Positioned(
              bottom: 14, left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(labelIcon!, width: 13, height: 13,
                        colorFilter: const ColorFilter.mode(AppColors.green, BlendMode.srcIn)),
                    const SizedBox(width: 5),
                    Text(categoryFormatter(category!),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.green, letterSpacing: 0.4)),
                  ],
                ),
              ),
            ),


          if (hasMultiple)
            Positioned(
              bottom: 14, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imagesList.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == index ? AppColors.green : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                )),
              ),
            ),


          if (hasMultiple) ...[
            Positioned(
              left: 10, top: 0, bottom: 0,
              child: Center(child: _ArrowNav(icon: Icons.chevron_left, onTap: () {
                pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
              })),
            ),
            Positioned(
              right: 10, top: 0, bottom: 0,
              child: Center(child: _ArrowNav(icon: Icons.chevron_right, onTap: () {
                pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
              })),
            ),
          ],
        ],
      ),
    );
  }
}

class _Buttons extends StatelessWidget {
  final IconData icon;
  const _Buttons({required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    width: 36, height: 36,
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.4),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: Colors.white, size: 18),
  );
}

class _ArrowNav extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowNav({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    ),
  );
}


class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.texto, letterSpacing: -0.2),
  );
}


class _Direction extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _Direction({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13.5, color: color == AppColors.green ? AppColors.suave : AppColors.suave))),
      ],
    ),
  );
}


class _DateTime extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DateTime({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.green.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.green.withOpacity(0.35)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.greenDark),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.greenDark)),
      ],
    ),
  );
}


class _Schedule extends StatelessWidget {
  final Map<String, List<TimeSlot>> schedule;
  final bool? isOpen;
  const _Schedule({required this.schedule, this.isOpen});

  static const _days = {1:'Lun',2:'Mar',3:'Mié',4:'Jue',5:'Vie',6:'Sáb',7:'Dom'};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Title('Horario'),
            const Spacer(),
            if (isOpen != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOpen! ? AppColors.green.withOpacity(0.15) : AppColors.rojo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isOpen! ? AppColors.greenDark : AppColors.rojo, width: 0.8),
                ),
                child: Text(
                  isOpen! ? '● Abierto' : '● Cerrado',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isOpen! ? AppColors.greenDark : AppColors.rojo),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        ...[1,2,3,4,5,6,7].map((d) {
          final franjas = schedule['$d'] ?? [];
          final cerrado = franjas.isEmpty;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 36, child: Text(_days[d]!, style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: cerrado ? AppColors.suave : AppColors.texto,
                ))),
                const SizedBox(width: 10),
                Container(
                  width: 2,
                  height: cerrado ? 20 : (franjas.length * 28).toDouble(),
                  decoration: BoxDecoration(
                    color: cerrado ? AppColors.borde : AppColors.green.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: cerrado
                      ? const Text('Cerrado', style: TextStyle(fontSize: 13, color: AppColors.suave, fontStyle: FontStyle.italic))
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: franjas.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.green.withOpacity(0.3), width: 0.8),
                        ),
                        child: Text('${f.start} – ${f.end}',
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.texto)),
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final bool isUrl;
  final VoidCallback? onTap;
  const _InfoRow({required this.icon, required this.label, required this.text, this.isUrl = false, this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: AppColors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: AppColors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.suave, fontWeight: FontWeight.w500)),
                const SizedBox(height: 1),
                Text(text, style: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w500,
                  color: isUrl ? const Color(0xFF3B6FE8) : AppColors.texto,
                  decoration: isUrl ? TextDecoration.underline : null,
                )),
              ],
            ),
          ),
          if (isUrl) const Icon(Icons.open_in_new, size: 14, color: AppColors.suave),
        ],
      ),
    ),
  );
}



class _SaveButton extends StatefulWidget {
  final bool isActivity, isRestaurant, isAccommodation;
  final int? activityId, restaurantId, accommodationId, userId;

  const _SaveButton({
    required this.isActivity, required this.isRestaurant, required this.isAccommodation,
    this.activityId, this.restaurantId, this.accommodationId, this.userId,
  });

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool? _saved;
  bool _loading = false;

  bool get _isLoged => widget.userId != null;
  bool get _support =>
      (widget.isActivity && widget.activityId != null) ||
          (widget.isRestaurant && widget.restaurantId != null) ||
          (widget.isAccommodation && widget.accommodationId != null);

  @override
  void initState() {
    super.initState();
    if (_isLoged && _support) _loadState();
  }

  Future<void> _loadState() async {
    try {
      bool saved;
      if (widget.isActivity) {
        final r = await InteractionApiService.activitySavedState(activityId: widget.activityId!, userId: widget.userId!);
        saved = r.saved;
      } else if (widget.isRestaurant) {
        final r = await InteractionApiService.restaurantSavedState(restaurantId: widget.restaurantId!, userId: widget.userId!);
        saved = r.saved;
      } else {
        final r = await InteractionApiService.accommodationSavedState(accommodationId: widget.accommodationId!, userId: widget.userId!);
        saved = r.saved;
      }
      if (mounted) setState(() => _saved = saved);
    } catch (_) {
      if (mounted) setState(() => _saved = false);
    }
  }

  Future<void> _toggle(BuildContext context) async {
    if (_loading || !_support) return;
    if (!_isLoged) { AlertModal.show(context, message: 'Inicia sesión para guardar'); return; }
    setState(() => _loading = true);
    try {
      if (_saved == true) {
        if (widget.isActivity) await InteractionApiService.unsavedActivity(activityId: widget.activityId!, userId: widget.userId!);
        else if (widget.isRestaurant) await InteractionApiService.unsavedRestaurant(restaurantId: widget.restaurantId!, userId: widget.userId!);
        else await InteractionApiService.unsavedAccommodation(accommodationId: widget.accommodationId!, userId: widget.userId!);
        if (mounted) setState(() => _saved = false);
      } else {
        if (widget.isActivity) await InteractionApiService.saveActivity(activityId: widget.activityId!, userId: widget.userId!);
        else if (widget.isRestaurant) await InteractionApiService.saveRestaurant(restaurantId: widget.restaurantId!, userId: widget.userId!);
        else await InteractionApiService.saveAccommodation(accommodationId: widget.accommodationId!, userId: widget.userId!);
        if (mounted) setState(() => _saved = true);
      }
    } catch (_) {
      if (mounted) AlertModal.show(context, message: 'Error al guardar. Inténtalo de nuevo.', type: AlertType.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_support) return const SizedBox.shrink();
    final icono = _saved == true ? Icons.bookmark : Icons.bookmark_border;
    final color = _saved == true ? AppColors.green : Colors.white;
    return GestureDetector(
      onTap: () => _toggle(context),
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(12)),
        child: _loading
            ? const Padding(padding: EdgeInsets.all(9), child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.green))
            : Icon(icono, color: color, size: 18),
      ),
    );
  }
}

class _PriceCapacity extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _PriceCapacity({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.green.withOpacity(0.10),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.green.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: AppColors.greenDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.suave, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.greenDark)),
            ],
          ),
        ),
      ],
    ),
  );
}
