# Tasks: Workspace & Project Management (Flutter Desktop)

**Input**: Design documents from `/specs/003-workspace-project/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Not explicitly requested. Test tasks omitted per Constitution I (Speed Over Stability).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add dependencies and create project structure

- [x] T001 Add file_picker, shared_preferences, window_manager, desktop_multi_window dependencies to app/pubspec.yaml and run flutter pub get
- [x] T002 Create directory structure: app/lib/models/, app/lib/services/, app/lib/providers/, app/lib/screens/

---

## Phase 2: Foundational (Models & Services)

**Purpose**: Core models and services that multiple user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 [P] Create Workspace model with path, name, projects fields in app/lib/models/workspace.dart
- [x] T004 [P] Create Project model with path, name, isActive fields in app/lib/models/project.dart
- [x] T005 Implement WorkspaceService with scanProjects() method (list subdirectories, filter hidden/files, sort A→Z) in app/lib/services/workspace_service.dart
- [x] T006 [P] Implement PersistenceService with saveLastWorkspacePath() and getLastWorkspacePath() using shared_preferences in app/lib/services/persistence_service.dart
- [x] T007 Implement WorkspaceProvider (ChangeNotifier) with workspace state, openWorkspace(), setActiveProject(), refreshProjects() in app/lib/providers/workspace_provider.dart

**Checkpoint**: Foundation ready - models, services, and state management in place

---

## Phase 3: User Story 1 - Open Workspace via Directory Selection (Priority: P1) 🎯 MVP

**Goal**: 사용자가 디렉토리를 선택하면 workspace가 열리고 프로젝트 목록이 표시됨

**Independent Test**: 앱 실행 → Open Workspace 버튼 → 디렉토리 선택 → 프로젝트 목록 표시 확인

### Implementation for User Story 1

- [x] T008 [US1] Create WorkspaceSelectionScreen with "Open Workspace" button that triggers FilePicker.platform.getDirectoryPath() in app/lib/screens/workspace_selection_screen.dart
- [x] T009 [US1] Create WorkspaceHomeScreen with workspace name header, scrollable project list (ListView), empty state message in app/lib/screens/workspace_home_screen.dart
- [x] T010 [US1] Update app/lib/main.dart to use ChangeNotifierProvider for WorkspaceProvider and route between WorkspaceSelectionScreen and WorkspaceHomeScreen based on workspace state

**Checkpoint**: User Story 1 fully functional - can open workspace and see projects

---

## Phase 4: User Story 2 - Restore Last Opened Workspace on App Launch (Priority: P1)

**Goal**: 앱 재실행 시 마지막 workspace가 자동 복원됨

**Independent Test**: workspace 열기 → 앱 종료 → 앱 재실행 → 이전 workspace 자동 로드 확인

### Implementation for User Story 2

- [x] T011 [US2] Add auto-restore logic to WorkspaceProvider.init(): load last path from PersistenceService, validate directory exists, open workspace or fallback to selection screen in app/lib/providers/workspace_provider.dart
- [x] T012 [US2] Add save logic to WorkspaceProvider.openWorkspace(): persist path via PersistenceService after successful workspace open in app/lib/providers/workspace_provider.dart
- [x] T013 [US2] Update app/lib/main.dart to call WorkspaceProvider.init() on app startup and show loading indicator during restoration

**Checkpoint**: User Stories 1 AND 2 functional - workspace persists across restarts

---

## Phase 5: User Story 4 - View Project List within Workspace (Priority: P1)

**Goal**: 프로젝트 목록에서 프로젝트를 선택하면 활성 상태로 표시됨

**Independent Test**: workspace 열기 → 프로젝트 클릭 → 활성 상태 시각적 표시 확인

### Implementation for User Story 4

- [x] T014 [US4] Add project selection tap handler and active project visual highlight (selected state styling) to WorkspaceHomeScreen project list in app/lib/screens/workspace_home_screen.dart
- [x] T015 [US4] Add "Open Workspace" action (menu or button) to WorkspaceHomeScreen that triggers directory picker and replaces current workspace in app/lib/screens/workspace_home_screen.dart

**Checkpoint**: User Stories 1, 2, 4 functional - full single-window workspace experience

---

## Phase 6: User Story 3 - Open New Window with Workspace Selection (Priority: P2)

**Goal**: 새 창을 열면 workspace 선택 화면이 표시되고, 독립적 workspace 유지

**Independent Test**: 메뉴에서 "New Window" → 새 창에 workspace 선택 화면 표시 → 다른 workspace 선택 확인

### Implementation for User Story 3

- [x] T016 [US3] Configure desktop_multi_window in app/lib/main.dart: add multi-window entry point, handle window arguments for new window initialization
- [x] T017 [US3] Add "New Window" menu action to WorkspaceHomeScreen that launches new window via DesktopMultiWindow.createWindow() in app/lib/screens/workspace_home_screen.dart

**Checkpoint**: All user stories functional - multi-window workspace support complete

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Focus-based refresh and final integration

- [x] T018 Integrate window_manager WindowListener in WorkspaceProvider to call refreshProjects() on onWindowFocus event in app/lib/providers/workspace_provider.dart
- [x] T019 Manual smoke test: verify all 4 user stories work end-to-end on primary platform (macOS)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-6)**: All depend on Foundational phase completion
- **Polish (Phase 7)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Depends on US1 (needs openWorkspace flow to exist)
- **User Story 4 (P1)**: Depends on US1 (needs project list UI to exist)
- **User Story 3 (P2)**: Can start after Foundational (Phase 2) - independent multi-window setup

### Within Each User Story

- Models before services
- Services before screens
- Core implementation before integration

### Parallel Opportunities

- T003 and T004 (models) can run in parallel
- T005 and T006 (services) can run in parallel after models
- US3 (multi-window) can be developed in parallel with US2/US4

---

## Parallel Example: Phase 2

```bash
# Launch models in parallel:
Task: "Create Workspace model in app/lib/models/workspace.dart"
Task: "Create Project model in app/lib/models/project.dart"

# Then launch independent services in parallel:
Task: "Implement WorkspaceService in app/lib/services/workspace_service.dart"
Task: "Implement PersistenceService in app/lib/services/persistence_service.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Open workspace and see project list
5. Continue with US2, US4, US3 incrementally

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add US1 → Test → MVP (open workspace, see projects)
3. Add US2 → Test → workspace auto-restore on restart
4. Add US4 → Test → project selection, workspace switching
5. Add US3 → Test → multi-window support
6. Polish → focus refresh, smoke test

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Constitution I: Speed Over Stability — skip tests, use packages, minimize abstractions
- Constitution III: Minimal Viable Iteration — commit after each task or logical group
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
