part of 'map_cubit.dart';

class MapState extends Equatable {
  final FormStatus formStatus;
  final FormStatus pointInfoStatus;

  const MapState({required this.formStatus, required this.pointInfoStatus});

  MapState copyWith({FormStatus? formStatus, FormStatus? pointInfoStatus}) =>
      MapState(
        formStatus: formStatus ?? this.formStatus,
        pointInfoStatus: pointInfoStatus ?? this.pointInfoStatus,
      );

  @override
  List<Object?> get props => [];
}
