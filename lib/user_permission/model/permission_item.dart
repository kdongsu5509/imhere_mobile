import 'package:flutter/material.dart';

class PermissionItem {
  final String title;
  final IconData icon;
  final String shortDesc;
  final String detailedDesc;
  final bool isRequired;
  final bool isGranted;

  const PermissionItem({
    required this.title,
    required this.icon,
    required this.shortDesc,
    required this.detailedDesc,
    this.isRequired = false,
    this.isGranted = false,
  });

  /// 부모 클래스에도 copyWith 정의 (기본 형태)
  PermissionItem copyWith({bool? isGranted}) {
    return PermissionItem(
      title: title,
      icon: icon,
      shortDesc: shortDesc,
      detailedDesc: detailedDesc,
      isRequired: isRequired,
      isGranted: isGranted ?? this.isGranted,
    );
  }
}
