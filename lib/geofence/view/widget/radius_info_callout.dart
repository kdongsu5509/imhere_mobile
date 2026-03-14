import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RadiusInfoCallout extends StatelessWidget {
  final String message;
  final IconData icon;

  const RadiusInfoCallout({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(child: Text(message, style: _infoTextStyle())),
        ],
      ),
    );
  }

  TextStyle _infoTextStyle() {
    return TextStyle(
      fontSize: 14.sp,
      color: Color(0xFF2C3E50),
      height: 1.4,
      fontWeight: FontWeight.bold,
    );
  }
}
