import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iamhere/auth/service/token_storage_service.dart';
import 'package:iamhere/auth/view/auth_view.dart';
import 'package:iamhere/auth/view_model/auth_view_model.dart';
import 'package:iamhere/common/view_component/default_view.dart';
import 'package:iamhere/contact/view/contact_view.dart';
import 'package:iamhere/core/di/di_setup.dart';
import 'package:iamhere/geofence/view/geofence_enroll_view.dart';
import 'package:iamhere/geofence/view/geofence_view.dart';
import 'package:iamhere/record/view/record_view.dart';

import 'custom_page_transition/buttom_up_transition.dart';
import 'custom_page_transition/simple_transition.dart';

final GoRouter router = GoRouter(
  initialLocation: '/geofence',
  redirect: (context, state) async {
    if (state.uri.path == '/auth') {
      return null;
    }

    // secure_storage에서 토큰 확인
    final tokenStorage = getIt<TokenStorageService>();
    final accessToken = await tokenStorage.getAccessToken();

    // 토큰이 없으면 /auth로 리다이렉트
    if (accessToken == null || accessToken.isEmpty) {
      return '/auth';
    }

    // 토큰이 있으면 정상 진행
    return null;
  },

  // 모든 라우트 정의
  routes: [
    // 인증 화면
    GoRoute(
      path: '/auth',
      builder: (context, state) => AuthView(getIt<AuthViewModel>()),
    ),

    // 메인 화면 (인증 필요)
    ShellRoute(
      builder: (context, state, child) {
        return DefaultView(child: child);
      },
      routes: [
        GoRoute(
          path: '/geofence',
          pageBuilder: (context, state) => buildPageWithSimpleTransition(
            context: context,
            state: state,
            child: const GeofenceView(),
          ),
          routes: [
            GoRoute(
              path: '/enroll',
              pageBuilder: (context, state) => buildPageWithBottomUpTransition(
                context: context,
                state: state,
                child: const GeofenceEnrollView(),
              ),
            ),
          ],
        ),

        // 2. 연락처 탭 경로
        GoRoute(
          path: '/contact',
          pageBuilder: (context, state) => buildPageWithSimpleTransition(
            context: context,
            state: state,
            child: const ContactView(),
          ),
        ),

        // 3. 기록 탭 경로
        GoRoute(
          path: '/record',
          pageBuilder: (context, state) => buildPageWithSimpleTransition(
            context: context,
            state: state,
            child: const RecordView(),
          ),
        ),

        GoRoute(
          path: '/register',
          builder: (context, state) => const Text("새 등록 페이지"),
        ),
      ],
    ),
  ],

  errorBuilder: (context, state) =>
      const Center(child: Text("페이지를 찾을 수 없습니다.")),
);
