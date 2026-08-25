import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  double? currentHeading;

  double qiblaDirection = 0;

  double? distanceToQibla;

  double? latitude;
  double? longitude;

  String locationName = "Getting location...";

  String errorMessage = "";

  StreamSubscription<CompassEvent>? compassSubscription;

  final Color primaryColor = const Color(0xff5B35D5);

  final Color darkColor = const Color(0xff101044);

  final Color lightPurple = const Color(0xffF1EEFF);

  @override
  void initState() {
    super.initState();

    startCompass();

    getCurrentLocation();
  }

  // REAL COMPASS

  void startCompass() {
    compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (!mounted) return;

      setState(() {
        currentHeading = event.heading;
      });
    });
  }

  // GET LOCATION

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          errorMessage = "Please turn on Location/GPS";
        });

        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          setState(() {
            errorMessage = "Location permission denied";
          });

          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage = "Location permission permanently denied";
        });

        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      double lat = position.latitude;
      double lng = position.longitude;

      double bearing = Geolocator.bearingBetween(
        lat,
        lng,
        kaabaLatitude,
        kaabaLongitude,
      );

      if (bearing < 0) {
        bearing += 360;
      }

      double distance = Geolocator.distanceBetween(
        lat,
        lng,
        kaabaLatitude,
        kaabaLongitude,
      );

      setState(() {
        latitude = lat;
        longitude = lng;

        qiblaDirection = bearing;

        distanceToQibla = distance / 1000;

        locationName = "Your Current Location";

        errorMessage = "";
      });
    } catch (e) {
      setState(() {
        errorMessage = "Unable to get location";
      });
    }
  }

  // COMPASS ROTATION

  double getCompassRotation() {
    if (currentHeading == null) {
      return 0;
    }

    double difference = qiblaDirection - currentHeading!;

    return difference * math.pi / 180;
  }

  // DIRECTION NAME

  String getDirectionName(double degree) {
    if (degree >= 337.5 || degree < 22.5) {
      return "North";
    } else if (degree < 67.5) {
      return "North-East";
    } else if (degree < 112.5) {
      return "East";
    } else if (degree < 157.5) {
      return "South-East";
    } else if (degree < 202.5) {
      return "South";
    } else if (degree < 247.5) {
      return "South-West";
    } else if (degree < 292.5) {
      return "West";
    } else {
      return "North-West";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    buildHeader(),

                    const SizedBox(height: 18),

                    // LOCATION
                    buildLocationCard(),

                    const SizedBox(height: 15),

                    // ERROR
                    if (errorMessage.isNotEmpty) buildErrorCard(),

                    // COMPASS
                    buildCompass(),

                    const SizedBox(height: 10),

                    // DIRECTION
                    buildDirectionCard(),

                    const SizedBox(height: 12),

                    // DISTANCE + COORDINATES
                    buildInfoCards(),

                    const SizedBox(height: 12),

                    buildSuccessCard(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        Container(
          height: 65,
          width: 65,
          decoration: BoxDecoration(
            color: lightPurple,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(Icons.mosque, color: primaryColor, size: 38),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Qibla Compass",
                style: TextStyle(
                  color: darkColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                "Find the Direction of Qibla",
                style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
              ),
            ],
          ),
        ),

        Container(
          height: 50,
          width: 50,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.settings_outlined,
            color: Colors.grey.shade700,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: lightPurple,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: const BoxDecoration(
              color: Color(0xffE9E3FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: primaryColor,
              size: 32,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Location",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),

                const SizedBox(height: 3),

                Text(
                  locationName,
                  style: TextStyle(
                    color: darkColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.chevron_right, color: primaryColor, size: 30),
        ],
      ),
    );
  }

  Widget buildErrorCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // COMPASS

  Widget buildCompass() {
    return SizedBox(
      height: 350,
      width: 350,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Compass circle
          Container(
            height: 330,
            width: 330,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xffFAF9FF),
              border: Border.all(color: primaryColor, width: 8),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.10),
                  blurRadius: 20,
                ),
              ],
            ),
          ),

          // Directions
          Positioned(
            top: 32,
            child: Text(
              "N",
              style: TextStyle(
                color: darkColor,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Positioned(
            right: 32,
            child: Text(
              "E",
              style: TextStyle(
                color: darkColor,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Positioned(
            bottom: 32,
            child: Text(
              "S",
              style: TextStyle(
                color: darkColor,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Positioned(
            left: 32,
            child: Text(
              "W",
              style: TextStyle(
                color: darkColor,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // RED NORTH POINTER
          Positioned(
            top: 4,
            child: Container(
              width: 0,
              height: 0,
              decoration: const BoxDecoration(),
              child: CustomPaint(
                size: const Size(26, 22),
                painter: NorthPointerPainter(),
              ),
            ),
          ),

          // QIBLA ARROW
          if (currentHeading != null)
            Transform.rotate(
              angle: getCompassRotation(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.navigation, size: 100, color: primaryColor),

                  const SizedBox(height: 5),

                  buildKaaba(),
                ],
              ),
            ),

          if (currentHeading == null)
            const CircularProgressIndicator(color: Color(0xff5B35D5)),
        ],
      ),
    );
  }

  Widget buildKaaba() {
    return Container(
      height: 75,
      width: 75,
      decoration: const BoxDecoration(
        color: Color(0xffF1EEFF),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          height: 48,
          width: 42,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),

              Container(height: 5, width: 42, color: const Color(0xffD7AA32)),
            ],
          ),
        ),
      ),
    );
  }

  // DIRecTION CARD

  Widget buildDirectionCard() {
    String degree = "${qiblaDirection.toStringAsFixed(0)}°";

    String direction = getDirectionName(qiblaDirection);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
      decoration: BoxDecoration(
        color: lightPurple,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: const BoxDecoration(
              color: Color(0xffE9E3FF),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.navigation, color: primaryColor, size: 30),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Direction to Qibla",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),

                Text(
                  degree,
                  style: TextStyle(
                    color: darkColor,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Container(height: 50, width: 1, color: Colors.grey.shade300),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Qibla is to the",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),

                Text(
                  direction,
                  style: TextStyle(
                    color: darkColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoCards() {
    String distanceText = distanceToQibla == null
        ? "Calculating..."
        : "${distanceToQibla!.toStringAsFixed(1)} km";

    String coordinateText;

    if (latitude == null) {
      coordinateText = "Getting location...";
    } else {
      coordinateText =
          "${latitude!.toStringAsFixed(4)}° N\n"
          "${longitude!.toStringAsFixed(4)}° E";
    }

    return Row(
      children: [
        Expanded(
          child: buildInfoCard(
            icon: Icons.straighten,
            title: "Distance to Qibla",
            value: distanceText,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: buildInfoCard(
            icon: Icons.mosque,
            title: "Qibla Coordinate",
            value: "21.4225° N\n39.8262° E",
          ),
        ),
      ],
    );
  }

  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xffE6E5EB)),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              color: Color(0xffF0ECFF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 26),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: TextStyle(
                    color: darkColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSuccessCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffE2F9EF),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            height: 35,
            width: 35,
            decoration: const BoxDecoration(
              color: Color(0xff25B47E),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 22),
          ),

          const SizedBox(width: 10),

          const Text(
            "Qibla direction detected successfully",
            style: TextStyle(
              color: Color(0xff16845E),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    compassSubscription?.cancel();
    super.dispose();
  }
}

class NorthPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.redAccent;

    final path = Path();

    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
