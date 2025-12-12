import 'package:flutter/material.dart';

class PermissionItem {
  final String title;
  final IconData icon;
  final String shortDesc;
  final String detailedDesc;
  final bool isRequired;
  final bool isGranted;

  PermissionItem({
    required this.title,
    required this.icon,
    required this.shortDesc,
    required this.detailedDesc,
    this.isRequired = false,
    this.isGranted = false,
  });

  PermissionItem copyWith({bool? isGranted}) {
    return PermissionItem(
      icon: icon,
      title: title,
      shortDesc: shortDesc,
      detailedDesc: detailedDesc,
      isRequired: isRequired,
      isGranted: isGranted ?? this.isGranted,
    );
  }
}

class LocationPermission extends PermissionItem {
  LocationPermission({
    required super.title,
    required super.icon,
    required super.shortDesc,
    required super.detailedDesc,
    super.isRequired = true,
  });
}

class ContactPermission extends PermissionItem {
  ContactPermission({
    required super.title,
    required super.icon,
    required super.shortDesc,
    required super.detailedDesc,
    super.isRequired = true,
  });
}

class SmsPermission extends PermissionItem {
  SmsPermission({
    required super.title,
    required super.icon,
    required super.shortDesc,
    required super.detailedDesc,
    super.isRequired = true,
  });
}

class FcmAlertPermission extends PermissionItem {
  FcmAlertPermission({
    required super.title,
    required super.icon,
    required super.shortDesc,
    required super.detailedDesc,
    super.isRequired = false,
  });
}
