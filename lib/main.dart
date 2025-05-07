import 'package:flutter/material.dart';
import 'package:flutter_yandex_mapkit_example/get_location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late YandexMapController _mapController;
  Point? _selectedPoint;
  Point? _myLocation;
  String _pointInfo = '';
  bool a = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Foydalanuvchi joylashuvini aniqlash
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Geolokatsiya xizmati yoqilganligini tekshirish
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // Ruxsatlarni tekshirish
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Hozirgi joylashuvni olish
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _myLocation = Point(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      });
      findMe();
    } catch (e) {
      print("Joylashuvni aniqlashda xatolik: $e");
    }
  }

  findMe() async {
    setState(() {
      a = !a;
    });
    // Foydalanuvchining hozirgi joylashuvini olish
    try {
      final position = await Geolocator.getCurrentPosition();
      final userLocation = Point(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _myLocation = userLocation;
      _pointInfo = await getAddress(position.latitude, position.longitude);
      setState(() {
        // _pointInfo =
        //     'Mening joylashuvim: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      });

      // Xaritani foydalanuvchi joylashuviga ko'chirish
      _mapController.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLocation, zoom: 15.0),
        ),
        animation: const MapAnimation(duration: 0.5),
      );
      setState(() {
        _selectedPoint = userLocation;
      });
    } catch (e) {
      print("Joylashuvni aniqlashda xatolik: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Joylashuvni aniqlashda xatolik yuz berdi'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Yandex Map')),
        body: Stack(
          children: [
            YandexMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onMapTap: (point) async {
                _selectedPoint = point;
                _pointInfo = await getAddress(point.latitude, point.longitude);
                setState(() {});

                _mapController.moveCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: point, zoom: 15.0),
                  ),
                  animation: const MapAnimation(duration: 0.5),
                );

                // getLocationInfo(point.latitude, point.longitude);
              },
              mapObjects: [
                if (_selectedPoint != null)
                  PlacemarkMapObject(
                    mapId: const MapObjectId('selected_point'),
                    point: _selectedPoint!,
                    icon: PlacemarkIcon.single(
                      PlacemarkIconStyle(
                        image: BitmapDescriptor.fromAssetImage(
                          a ? 'assets/my_location.png' : 'assets/marker.png',
                        ),
                        scale: 0.3,
                        anchor: Offset(0.5, 1.0),
                      ),
                    ),
                  ),
                if (_myLocation != null)
                  CircleMapObject(
                    mapId: const MapObjectId('user_location_radius'),
                    strokeColor: Colors.blue.withOpacity(0.4),
                    fillColor: Colors.blue.withOpacity(0.2),
                    strokeWidth: 1,
                    circle: Circle(center: _myLocation!, radius: 30),
                  ),
                if (_myLocation != null)
                  CircleMapObject(
                    mapId: const MapObjectId('user_dot'),
                    fillColor: Colors.blue,
                    strokeColor: Colors.white,
                    strokeWidth: 2,
                    circle: Circle(center: _myLocation!, radius: 4),
                  ),
              ],
            ),
            if (_pointInfo.isNotEmpty)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(_pointInfo, style: const TextStyle(fontSize: 16)),
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: findMe,
          child: const Icon(Icons.location_on),
        ),
      ),
    );
  }
}
