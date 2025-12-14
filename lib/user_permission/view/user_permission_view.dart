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
    // 1. 이제 이 값은 AsyncValue<List<PermissionItem>> 입니다.
    final asyncPermissionState = ref.watch(userPermissionViewModelProvider);

    // 2. .when()을 사용하여 상태(로딩/에러/데이터)에 따라 분기 처리합니다.
    return asyncPermissionState.when(
      // [로딩 중] 화면
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      // [에러 발생] 화면
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('초기화 오류: $error'))),
      // [데이터 로드 완료] 화면 (기존 로직은 여기로 들어옵니다)
      data: (permissionItems) {
        // 데이터가 준비되었으므로, 기존 로직 수행
        int _totalPages = permissionItems.length + 2;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildLinearProgressIndicator(_totalPages),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _totalPages,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return IntroPage(onNext: _nextPage);
                      } else if (index == _totalPages - 1) {
                        return FinishPage(onFinish: _onFinish);
                      } else {
                        // permissionItems는 실제 List 데이터입니다.
                        // index 계산 주의: 0번은 Intro, 1번부터 아이템이므로 (index - 1)
                        return PermissionPage(
                          pageIndex: _currentPage,
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
      },
    );
  }

  LinearProgressIndicator _buildLinearProgressIndicator(int _totalPages) {
    return LinearProgressIndicator(
      value: _totalPages > 0 ? (_currentPage + 1) / _totalPages : 0,
      backgroundColor: Colors.grey[100],
      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF48D1CC)),
      minHeight: 4,
    );
  }
}
