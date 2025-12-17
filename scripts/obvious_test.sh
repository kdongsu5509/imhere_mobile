#!/bin/bash

# 1. 기존 커버리지 삭제
rm -rf coverage

# 2. 테스트 실행
echo "Running Flutter Tests..."
flutter test --coverage

# 3. lcov 설치 여부 확인
if ! command -v lcov &> /dev/null; then
    echo "lcov가 설치되어 있지 않습니다. 'brew install lcov'를 실행해주세요."
    exit 1
fi

# 4. 제외할 파일 설정 (DTO, Generated 파일 등)
echo "Removing excluded files..."
lcov --remove coverage/lcov.info \
  'lib/**/*.g.dart' \
  'lib/**/*.freezed.dart' \
  'lib/firebase_options.dart' \
  'lib/main.dart' \
  'lib/**/dto/*' \
  -o coverage/lcov.info

# 5. HTML 리포트 생성 및 열기
echo "Generating HTML report..."
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html