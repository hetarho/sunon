# Quickstart: 프로젝트 추가 (Add Project)

**Date**: 2026-03-30 | **Branch**: `004-add-project`

## Prerequisites

- Flutter SDK (stable channel, Dart ^3.11.1)
- macOS desktop development environment

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

## Key Files to Modify

1. **`app/lib/services/workspace_service.dart`** — `createProject()`, `validateProjectName()` 추가
2. **`app/lib/providers/workspace_provider.dart`** — `addProject()` 메서드 추가
3. **`app/lib/screens/workspace_home_screen.dart`** — AppBar에 추가 버튼 + 이름 입력 다이얼로그

## Implementation Flow

```text
[사용자] → 추가 버튼 클릭
  → [Screen] 다이얼로그 표시
  → [사용자] 이름 입력 + 확인
  → [Provider] addProject(name) 호출
    → [Service] validateProjectName(name) → 검증
    → [Service] createProject(workspacePath, name) → 폴더/파일 생성
    → [Provider] refreshProjects() → 목록 갱신
    → [Provider] setActiveProject(name) → 활성화
  → [Screen] UI 갱신 (notifyListeners)
```
