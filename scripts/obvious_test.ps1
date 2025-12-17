# 1. 기존 커버리지 폴더 삭제
if (Test-Path coverage) {
    Remove-Item -Recurse -Force coverage
}

# 2. 테스트 실행
Write-Host "Running Flutter Tests..." -ForegroundColor Green
flutter test --coverage

# 3. lcov 실행 (Chocolatey로 설치했다고 가정)
# 주의: 윈도우에서 lcov 명령어가 안 먹힐 경우 perl 경로를 확인해야 함
Write-Host "Removing excluded files..." -ForegroundColor Green

# 윈도우에서는 줄바꿈 문자로 백틱(`)을 사용합니다.
lcov --remove coverage/lcov.info `
  'lib/**/*.g.dart' `
  'lib/**/*.freezed.dart' `
  'lib/firebase_options.dart' `
  'lib/main.dart' `
  'lib/**/dto/*' `
  -o coverage/lcov.info

# 4. HTML 리포트 생성
Write-Host "Generating HTML report..." -ForegroundColor Green
genhtml coverage/lcov.info -o coverage/html

# 5. 브라우저로 열기
Invoke-Item coverage/html/index.html