import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iamhere/setting/view/privacy_view.dart';
import 'package:iamhere/setting/view/setting_components.dart';
import 'package:iamhere/setting/view_model/setting_view_model.dart';
import 'package:iamhere/setting/view_model/setting_view_model_state.dart';
import 'package:iamhere/user_permission/model/permission_state.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingView extends ConsumerWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingStateAsync = ref.watch(settingViewModelProvider);

    return Scaffold(
      body: settingStateAsync.when(
        data: (state) => ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          children: [
            _buildPermissionsSection(state),
            SizedBox(height: 24.h),
            _buildPrivacySection(context),
            SizedBox(height: 24.h),
            _buildCustomerSupportSection(context),
            SizedBox(height: 24.h),
            _buildAppInfoSection(state),
            SizedBox(height: 40.h),
            _buildFooter(context),
            SizedBox(height: 20.h),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('설정을 불러오는 중 오류가 발생했습니다.')),
      ),
    );
  }

  Widget _buildPermissionsSection(SettingViewModelState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingSectionHeader(title: '권한'),
        SettingItem(
          title: '푸시 알림',
          trailingText: _mapPermissionStateToString(
            state.pushPermission,
            isToggle: true,
          ),
        ),
        SettingItem(
          title: '메시지 알림',
          trailingText: _mapPermissionStateToString(
            state.pushPermission,
            isToggle: true,
          ),
        ),
        SettingItem(
          title: '문자 메시지 권한',
          trailingText: _mapPermissionStateToString(state.smsPermission),
        ),
        SettingItem(
          title: '위치 추적',
          trailingText: _mapPermissionStateToString(state.locationPermission),
        ),
        const SettingItem(title: '위치 기록 보관', trailingText: '30일'),
      ],
    );
  }

  String _mapPermissionStateToString(
    PermissionState state, {
    bool isToggle = false,
  }) {
    if (isToggle) {
      switch (state) {
        case PermissionState.grantedAlways:
        case PermissionState.grantedWhenInUse:
          return '켜짐';
        default:
          return '꺼짐';
      }
    } else {
      switch (state) {
        case PermissionState.grantedAlways:
          return '항상 허용됨';
        case PermissionState.grantedWhenInUse:
          return '사용 중 허용됨';
        case PermissionState.denied:
        case PermissionState.permanentlyDenied:
        case PermissionState.restricted:
          return '거부됨';
      }
    }
  }

  Widget _buildPrivacySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingSectionHeader(title: '개인정보'),
        SettingItem(
          title: '개인정보 보호 정책',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyView(title: '개인정보 보호 정책'),
              ),
            );
          },
        ),
        SettingItem(
          title: '서비스 이용약관',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyView(title: '서비스 이용약관'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCustomerSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingSectionHeader(title: '고객 지원'),
        SettingItem(
          title: '문의하기',
          onTap: () async {
            final Uri url = Uri.parse(
              'https://dsko.notion.site/d75b9924c10c47f0b91e4da6ee4251ec?pvs=105',
            );
            if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('문의하기 페이지를 열 수 없습니다.')),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildAppInfoSection(SettingViewModelState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingSectionHeader(title: '앱 정보'),
        SettingItem(
          title: '버전 정보',
          trailingText: state.appVersion.isEmpty ? '정보 없음' : state.appVersion,
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Imhere © 2025',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          SizedBox(height: 4.h),
          Text(
            '위치 기반 알림 서비스',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
