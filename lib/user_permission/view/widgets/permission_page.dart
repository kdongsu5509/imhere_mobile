import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iamhere/common/view_component/black_button.dart';
import 'package:iamhere/user_permission/view_model/user_permission_view_model.dart';

import '../../model/permission_item.dart';

/// 개별 권한 요청 페이지 위젯
class PermissionPage extends ConsumerWidget {
  final int pageIndex;
  final PermissionItem item;
  final VoidCallback onNext;

  const PermissionPage({
    super.key,
    required this.pageIndex,
    required this.item,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          _buildPermissionPageTitle(),
          const Spacer(),
          Text(
            item.detailedDesc,
            style: TextStyle(fontSize: 17.sp, height: 1.6),
          ),
          const Spacer(),
          _buildButtons(context, ref),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Column _buildButtons(BuildContext context, WidgetRef ref) {
    final laterText = '나중에';
    final skipText = '건너뛰기 (권장하지 않음)';
    return Column(
      children: [
        _buildAllowButton(ref),
        SizedBox(height: 12.h),

        if (!item.isRequired)
          _buildLaterButton(message: laterText, onPressed: onNext)
        else
          _buildLaterButton(
            message: skipText,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("원활한 서비스 이용을 위해 필수 권한입니다.")),
              );
            },
          ),
      ],
    );
  }

  TextButton _buildLaterButton({
    required String message,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        message,
        style: TextStyle(color: Colors.grey, fontSize: 15.w),
      ),
    );
  }

  Widget _buildAllowButton(WidgetRef ref) {
    final vm = ref.read(userPermissionViewModelProvider.notifier);

    final allowText = '허용하기';
    return BlackButton(
      onPressed: () async {
        await vm.requestPermission(pageIndex - 1);
        onNext();
      },
      message: allowText,
    );
  }

  Column _buildPermissionPageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              item.title,
              style: TextStyle(fontSize: 32.h, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 5.w),
            Icon(item.icon, color: Colors.grey[700]),
          ],
        ),
        if (item.isRequired) _buildRequiredText(),
      ],
    );
  }

  Text _buildRequiredText() {
    final text = ' (필수)';
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.h,
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
