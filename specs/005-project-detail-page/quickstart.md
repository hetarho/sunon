# Quickstart: 프로젝트 상세 페이지 (Project Detail Page)

**Date**: 2026-03-30 | **Branch**: `005-project-detail-page`

## Prerequisites

- Flutter SDK (stable channel, Dart ^3.11.1)
- macOS desktop development environment
- 워크스페이스에 프로젝트가 1개 이상 존재

## Setup

```bash
cd app
flutter pub get
```

## Run

```bash
cd app
flutter run -d macos
```

## Test

```bash
cd app
flutter test
```

## Key Files

1. **`app/lib/screens/project_detail_screen.dart`** — 🆕 사이드바 + TBD 콘텐츠 영역
2. **`app/lib/providers/workspace_provider.dart`** — `isInProjectView` 상태 + `navigateToProject()` / `navigateBack()`
3. **`app/lib/screens/workspace_home_screen.dart`** — 프로젝트 탭 시 상세 뷰 전환 연결

## Verification Flow

```text
1. 앱 실행 → 워크스페이스 열기
2. 프로젝트 탭 → 상세 뷰 진입 확인
3. 사이드바에 6개 메뉴 표시 확인 (Product, Entities, Policies, User Stories, Elements, Specs)
4. 각 메뉴 클릭 → 우측에 해당 페이지 이름 표시 확인
5. 뒤로가기 → 프로젝트 목록 복귀 확인
```
