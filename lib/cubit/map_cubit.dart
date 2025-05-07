import 'dart:math';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_yandex_mapkit_example/cubit/form_status.dart';
import 'package:flutter_yandex_mapkit_example/get_location.dart';
import 'package:geolocator/geolocator.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  late Point currentPoint;
  String pointInfo = "";
  MapCubit()
    : super(
        const MapState(
          formStatus: FormStatus.pure,
          pointInfoStatus: FormStatus.pure,
        ),
      ) {
    _determinePosition(
      onPermissioned: () async {
        final position = await Geolocator.getCurrentPosition();
        setPoint(position: position);

        emit(state.copyWith(formStatus: FormStatus.initialized));
      },
    );
  }

  void setPoint({required Position position}) async {
    currentPoint = Point(position.latitude, position.longitude);
    try {
      emit(state.copyWith(pointInfoStatus: FormStatus.loading));
      pointInfo = await getAddress(position.latitude, position.longitude);
      emit(state.copyWith(pointInfoStatus: FormStatus.success));
    } catch (e) {
      pointInfo = "";
      emit(state.copyWith(pointInfoStatus: FormStatus.failed));
    }
  }

  void _determinePosition({required VoidCallback onPermissioned}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    onPermissioned();
  }
}
