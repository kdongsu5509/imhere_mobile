import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iamhere/user_permission/view_model/user_permission_view_model.dart';

import 'widgets/finish_page.dart';
import 'widgets/intro_page.dart';
import 'widgets/permission_page.dart';

class UserPermissionView extends ConsumerStatefulWidget {
  const UserPermissionView({super.key});

  @override
  ConsumerState<UserPermissionView> createState() => _UserPermissionViewState();
}

class _UserPermissionViewState extends ConsumerState<UserPermissionView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 총 페이지 수 = (인트로 1) + (권한 개수) + (완료 1)

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onFinish() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("메인 페이지로 이동합니다!")));
    context.go('/geofence');
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.read(userPermissionViewModelProvider);
    final permissionItems = ref.watch(userPermissionViewModelProvider);
    int _totalPages = permissionItems.length + 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 진행바 (Progress Bar)
            LinearProgressIndicator(
              value: (_currentPage + 1) / _totalPages,
              backgroundColor: Colors.grey[100],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF48D1CC),
              ),
              minHeight: 4,
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // 버튼으로만 이동
                itemCount: _totalPages,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // 1. 인트로
                    return IntroPage(onNext: _nextPage);
                  } else if (index == _totalPages - 1) {
                    // 3. 완료
                    return FinishPage(onFinish: _onFinish);
                  } else {
                    // 2. 권한 페이지들
                    return PermissionPage(
                      item: permissionItems[index - 1],
                      onNext: _nextPage,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
