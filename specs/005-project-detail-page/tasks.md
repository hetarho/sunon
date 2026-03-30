# Tasks: 프로젝트 상세 페이지 (Project Detail Page)

**Input**: Design documents from `/specs/005-project-detail-page/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, quickstart.md

**Tests**: Not requested — test tasks excluded.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter desktop app**: `app/lib/` for source code
- Screens: `app/lib/screens/`
- Providers: `app/lib/providers/`

---

## Phase 1: Setup

**Purpose**: No new project setup needed. All infrastructure exists. This phase is empty.

**Checkpoint**: Existing codebase is ready for feature implementation.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Provider 상태 확장 — 프로젝트 상세 뷰 진입/복귀 상태 관리

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T001 Add `isInProjectView` bool state, `navigateToProject()` and `navigateBack()` methods to `WorkspaceProvider` in `app/lib/providers/workspace_provider.dart` — `navigateToProject()` sets active project + isInProjectView=true, `navigateBack()` sets isInProjectView=false

**Checkpoint**: `WorkspaceProvider`에 프로젝트 뷰 내비게이션 상태가 추가됨

---

## Phase 3: User Story 1 - 사이드바 메뉴와 상세 페이지 표시 (Priority: P1) 🎯 MVP

**Goal**: 프로젝트 선택 시 좌측 사이드바(6개 메뉴) + 우측 TBD 플레이스홀더 페이지를 표시한다.

**Independent Test**: 프로젝트 탭 → 사이드바 6개 메뉴 확인 → 각 메뉴 클릭 시 우측에 페이지 이름 표시 확인

### Implementation for User Story 1

- [x] T002 [US1] Create `project_detail_screen.dart` as StatefulWidget with Row layout: left NavigationRail (6 menu items: Product, Entities, Policies, User Stories, Elements, Specs) + right Expanded area showing TBD placeholder (center Text with selected menu name) in `app/lib/screens/project_detail_screen.dart`
- [x] T003 [US1] Update `workspace_home_screen.dart` — change project ListTile `onTap` to call `provider.navigateToProject(index)` instead of `provider.setActiveProject(index)` in `app/lib/screens/workspace_home_screen.dart`
- [x] T004 [US1] Update the main screen builder (Consumer in `workspace_home_screen.dart` or parent widget) to conditionally show `ProjectDetailScreen` when `provider.isInProjectView` is true, otherwise show project list in `app/lib/screens/workspace_home_screen.dart`

**Checkpoint**: 프로젝트 탭 → 사이드바 + TBD 페이지 표시, 메뉴 전환 동작

---

## Phase 4: User Story 2 - 프로젝트 목록으로 복귀 (Priority: P2)

**Goal**: 프로젝트 상세 뷰에서 뒤로가기 버튼으로 프로젝트 목록 화면으로 돌아간다.

**Independent Test**: 프로젝트 상세 뷰에서 뒤로가기 클릭 → 프로젝트 목록 복귀 확인

### Implementation for User Story 2

- [x] T005 [US2] Add AppBar with back button (leading: BackButton) and project name as title to `ProjectDetailScreen`, calling `provider.navigateBack()` on press in `app/lib/screens/project_detail_screen.dart`

**Checkpoint**: 뒤로가기 → 프로젝트 목록 복귀, 재진입 가능

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: 전체 기능 점검

- [x] T006 Run `flutter analyze` and fix any warnings in `app/`
- [ ] T007 Run quickstart.md validation — `cd app && flutter run -d macos`로 전체 플로우 수동 확인

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 비어있음 — 기존 인프라 사용
- **Foundational (Phase 2)**: T001 단독 실행
- **User Story 1 (Phase 3)**: Phase 2 완료 후 시작. T002 → T003 → T004 (순차, T003/T004는 같은 파일)
- **User Story 2 (Phase 4)**: Phase 3 완료 후 시작 (ProjectDetailScreen이 존재해야 AppBar 추가 가능)
- **Polish (Phase 5)**: 모든 User Story 완료 후

### User Story Dependencies

- **User Story 1 (P1)**: Phase 2 완료 후 시작 — 독립적
- **User Story 2 (P2)**: User Story 1 완료 후 시작 (ProjectDetailScreen 필요)

### Within Each User Story

- Screen 생성 → 기존 화면 연결 → 조건부 렌더링 순서

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 2: Foundational (T001)
2. Complete Phase 3: User Story 1 (T002–T004)
3. **STOP and VALIDATE**: 프로젝트 탭 → 사이드바 + TBD 페이지 동작 확인
4. 이 시점에서 핵심 내비게이션 골격 완성

### Incremental Delivery

1. Phase 2 → Foundation ready
2. Phase 3 (US1) → 사이드바 + TBD 페이지 (MVP!)
3. Phase 4 (US2) → 뒤로가기 내비게이션
4. Phase 5 → 최종 점검

---

## Notes

- 새 파일 1개 생성: `project_detail_screen.dart`
- 기존 파일 2개 수정: `workspace_provider.dart`, `workspace_home_screen.dart`
- 모든 태스크는 `app/lib/` 하위 경로
- Commit after each phase or logical group
