import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionItem {
  final Permission permission;
  final String title;
  final IconData icon;
  final String shortDesc;
  final String detailedDesc;
  final bool isRequired;
  final bool isGranted;

  PermissionItem({
    required this.permission,
    required this.title,
    required this.icon,
    required this.shortDesc,
    required this.detailedDesc,
    this.isRequired = false,
    this.isGranted = false,
  });

  PermissionItem copyWith({bool? isGranted}) {
    return PermissionItem(
      permission: permission,
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
    required super.permission,
    required super.title,
    required super.icon,
    required super.shortDesc,
    required super.detailedDesc,
    super.isRequired = true,
  });
}

class ContactPermission extends PermissionItem {
  ContactPermission({
    required super.permission,
    required super.title,
    required super.icon,
    required super.shortDesc,
    required super.detailedDesc,
    super.isRequired = true,
  });
}

class SmsPermission extends PermissionItem {
  SmsPermission({
    required super.permission,
    required super.title,
    required super.icon,
    required super.shortDesc,
    required super.detailedDesc,
    super.isRequired = true,
  });
}

class FcmAlertPermission extends PermissionItem {
  FcmAlertPermission({
    required super.permission,
    required super.title,
    required super.icon,
    required super.shortDesc,
    required super.detailedDesc,
    super.isRequired = false,
  });
}
