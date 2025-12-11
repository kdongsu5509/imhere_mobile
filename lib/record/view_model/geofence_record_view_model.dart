import 'package:iamhere/record/repository/geofence_record_entity.dart';
import 'package:iamhere/record/repository/geofence_record_local_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'geofence_record_view_model.g.dart';

@riverpod
class GeofenceRecordViewModel extends _$GeofenceRecordViewModel {
  final GeofenceRecordLocalRepository repository;
  GeofenceRecordViewModel(this.repository);

  @override
  Future<List<GeofenceRecordEntity>> build() async {
    return await repository.findAllOrderByCreatedAtDesc();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await repository.findAllOrderByCreatedAtDesc();
    });
  }
}
