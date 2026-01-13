import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RadiusButton extends StatelessWidget {
  static final THOUSAND = 1_000;
  static final RADIUS_BUTTON_COLOR = Color(0xFF252525);

  final int radius;
  final bool isSelected;
  final VoidCallback onTap;

  const RadiusButton({
    super.key,
    required this.radius,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          border: Border.all(
            color: isSelected ? selectedColor : RADIUS_BUTTON_COLOR,
          ),
          borderRadius: BorderRadius.all(Radius.circular(15.w)),
        ),
        width: 100.w,
        height: 55.h,
        child: Center(
          child: Text(
            _toProperRadiusValue(radius),
            style: TextStyle(
              color: isSelected ? Colors.white : RADIUS_BUTTON_COLOR,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16.sp,
            ),
          ),
        ),
      ),
    );
  }

  String _toProperRadiusValue(int radius) {
    if (radius >= THOUSAND) {
      return "${radius / THOUSAND}km";
    }

    return "${radius}m";
  }
}
