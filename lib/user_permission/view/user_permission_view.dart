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
    final asyncPermissionState = ref.watch(userPermissionViewModelProvider);

    return asyncPermissionState.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('초기화 오류: $error'))),
      data: (permissionItems) {
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
