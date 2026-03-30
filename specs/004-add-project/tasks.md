# Tasks: 프로젝트 추가 (Add Project)

**Input**: Design documents from `/specs/004-add-project/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, quickstart.md

**Tests**: Not requested — test tasks excluded.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter desktop app**: `app/lib/` for source code
- Services: `app/lib/services/`
- Providers: `app/lib/providers/`
- Screens: `app/lib/screens/`
- Models: `app/lib/models/`

---

## Phase 1: Setup

**Purpose**: No new project setup needed. All infrastructure exists. This phase is empty.

**Checkpoint**: Existing codebase is ready for feature implementation.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core service logic that all user stories depend on — template structure definition and project creation service method.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T001 Define project template structure constants (폴더 목록 9개 + 파일 1개) in `app/lib/services/workspace_service.dart`
- [x] T002 Implement `createProject(String workspacePath, String projectName)` method that creates project folder with full template structure (product.md + all subdirectories) in `app/lib/services/workspace_service.dart`

**Checkpoint**: `WorkspaceService.createProject()` can create a project folder with complete template structure on disk.

---

## Phase 3: User Story 1 - 프로젝트 추가 버튼으로 새 프로젝트 생성 (Priority: P1) 🎯 MVP

**Goal**: 사용자가 워크스페이스 홈 화면에서 "프로젝트 추가" 버튼을 클릭하고, 프로젝트명을 입력하면 템플릿 구조가 포함된 프로젝트 폴더가 생성되고, 목록에 활성 상태로 표시된다.

**Independent Test**: 앱 실행 → 워크스페이스 열기 → 추가 버튼 클릭 → 이름 입력 → 확인 → 파일 시스템에서 폴더 구조 확인 + 목록에 활성 표시 확인

### Implementation for User Story 1

- [x] T003 [US1] Add `addProject(String name)` method to `WorkspaceProvider` that calls `createProject()`, `refreshProjects()`, and sets the new project as active in `app/lib/providers/workspace_provider.dart`
- [x] T004 [US1] Add "프로젝트 추가" IconButton to AppBar actions in `app/lib/screens/workspace_home_screen.dart`
- [x] T005 [US1] Implement project name input dialog (`showDialog` with `AlertDialog` + `TextField`) that calls `provider.addProject(name)` on confirm in `app/lib/screens/workspace_home_screen.dart`

**Checkpoint**: 프로젝트 추가 버튼 → 이름 입력 → 폴더 생성 → 목록 갱신 + 활성화 전체 플로우 동작

---

## Phase 4: User Story 2 - 프로젝트명 유효성 검증 (Priority: P2)

**Goal**: 빈 이름, 중복 이름(case-insensitive), 금지 문자, 마침표 시작, 길이 초과를 사전 차단하여 오류 메시지를 표시한다.

**Independent Test**: 다이얼로그에서 빈 이름, 중복 이름, 금지 문자 포함 이름, "." 시작 이름, 256자 이름을 각각 입력하고 오류 메시지 확인

### Implementation for User Story 2

- [x] T006 [US2] Implement `validateProjectName(String name, List<String> existingNames)` method that returns error message string or null in `app/lib/services/workspace_service.dart` — 검증 규칙: 빈 이름, 금지 문자(`/\:*?"<>|`), 마침표 시작, 대소문자 무시 중복, 255자 초과, 앞뒤 공백 trim
- [x] T007 [US2] Update project name input dialog to call `validateProjectName()` before creation and display error message in the dialog in `app/lib/screens/workspace_home_screen.dart`
- [x] T008 [US2] Update `addProject()` in `WorkspaceProvider` to trim name and pass existing project names to validation in `app/lib/providers/workspace_provider.dart`

**Checkpoint**: 모든 유효하지 않은 입력이 오류 메시지로 차단되고 파일 시스템에 아무것도 생성되지 않음

---

## Phase 5: User Story 3 - 프로젝트 생성 중 오류 처리 (Priority: P3)

**Goal**: 파일 시스템 오류 시 부분 생성된 폴더를 롤백하고 사용자에게 오류 메시지를 표시한다.

**Independent Test**: 읽기 전용 디렉토리에서 프로젝트 생성 시도 → 오류 메시지 확인 + 부분 폴더 없음 확인

### Implementation for User Story 3

- [x] T009 [US3] Add try-catch with rollback logic to `createProject()` — 실패 시 `Directory.delete(recursive: true)`로 프로젝트 폴더 전체 삭제 in `app/lib/services/workspace_service.dart`
- [x] T010 [US3] Update `addProject()` in `WorkspaceProvider` to catch exceptions and return/expose error message for UI display in `app/lib/providers/workspace_provider.dart`
- [x] T011 [US3] Update dialog in `workspace_home_screen.dart` to show SnackBar or error dialog when `addProject()` fails in `app/lib/screens/workspace_home_screen.dart`

**Checkpoint**: 파일 시스템 오류 발생 시 사용자에게 오류 안내 + 부분 생성된 폴더 0개

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 전체 기능 점검

- [x] T012 Run `flutter analyze` and fix any warnings in `app/`
- [ ] T013 Run quickstart.md validation — `cd app && flutter run -d macos`로 전체 플로우 수동 확인

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 비어있음 — 기존 인프라 사용
- **Foundational (Phase 2)**: T001 → T002 (순차)
- **User Story 1 (Phase 3)**: Phase 2 완료 후 시작. T003 → T004, T005 (T004/T005는 같은 파일이므로 순차)
- **User Story 2 (Phase 4)**: Phase 3 완료 후 시작 (다이얼로그가 이미 존재해야 검증 추가 가능)
- **User Story 3 (Phase 5)**: Phase 2 완료 후 시작 가능 (US1과 독립적이나, US1/US2 이후 순차 진행 권장)
- **Polish (Phase 6)**: 모든 User Story 완료 후

### User Story Dependencies

- **User Story 1 (P1)**: Phase 2 완료 후 시작 — 독립적
- **User Story 2 (P2)**: User Story 1 완료 후 시작 (다이얼로그 UI가 필요)
- **User Story 3 (P3)**: Phase 2 완료 후 시작 가능하나, US1 이후 권장 (같은 파일 수정)

### Within Each User Story

- Service 메서드 → Provider 메서드 → Screen UI 순서

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 2: Foundational (T001–T002)
2. Complete Phase 3: User Story 1 (T003–T005)
3. **STOP and VALIDATE**: 프로젝트 추가 → 폴더 구조 생성 → 목록 표시 확인
4. 이 시점에서 핵심 기능 완성

### Incremental Delivery

1. Phase 2 → Foundation ready
2. Phase 3 (US1) → 프로젝트 생성 기본 동작 (MVP!)
3. Phase 4 (US2) → 입력 검증 추가
4. Phase 5 (US3) → 오류 처리 + 롤백 추가
5. Phase 6 → 최종 점검

---

## Notes

- 새 파일 생성 없이 기존 3개 파일만 수정: `workspace_service.dart`, `workspace_provider.dart`, `workspace_home_screen.dart`
- 모든 태스크는 `app/lib/` 하위 경로
- Commit after each phase or logical group
