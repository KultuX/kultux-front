import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kultux/data/api/activity_api.dart';
import 'package:kultux/core/models/activity.dart';
import 'package:kultux/core/models/pages.dart';
import 'package:kultux/core/models/user.dart';
import 'package:kultux/data/api/accommodation_api.dart';
import 'package:kultux/data/api/location_api.dart';
import 'package:kultux/data/api/restaurant_api.dart';
import 'package:kultux/data/repository/user_repository.dart';

import 'package:kultux/features/home/home.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      final results = await Future.wait(
        [
          ActivityApiService.trendingActivities(0),
          LocationApiService.locationsNames(),
          LocationApiService.locationsMap(),
          ActivityApiService.activityCategories(),
          RestaurantApiService.restaurantsCategories(),
          AccommodationApiService.accommodationCategories(),
          UserRepository.load(),
          _preloadGeoJson(),
        ],
        eagerError: false,
      );

      final page = results[0] as Pages<Activity>;
      final user = results[6] as User?;

      await Future.wait(
        page.content
            .take(5)
            .where((a) => a.coverImage != null)
            .map(
              (a) => precacheImage(
            NetworkImage(a.coverImage!),
            context,
          ).catchError((_) {}),
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MyHomePage(
            startActivities: page.content,
            totalPages: page.totalPages,
            startUser: user,
          ),
        ),
      );
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyHomePage()),
      );
    }
  }

  Future<void> _preloadGeoJson() async {
    await rootBundle.loadString('assets/assets/extremadura.geojson');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/imagen_splash.png"),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: Color(0xFFE0DDD6),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA6E246)),
            ),
          ),
        ],
      ),
    );
  }
}