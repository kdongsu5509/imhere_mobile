import '../permission_item.dart';

class LocationPermissionItem extends PermissionItem {
  LocationPermissionItem({
    required super.title,
    required super.icon,
    required super.shortDesc,
    required super.detailedDesc,
    super.isRequired = true,
    super.isGranted,
  });

  @override
  LocationPermissionItem copyWith({bool? isGranted}) {
    return LocationPermissionItem(
      title: title,
      icon: icon,
      shortDesc: shortDesc,
      detailedDesc: detailedDesc,
      isRequired: isRequired,
      // 중요: super.isGranted가 아니라 그냥 매개변수로 전달
      isGranted: isGranted ?? this.isGranted,
    );
  }
}
