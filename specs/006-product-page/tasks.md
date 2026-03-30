# Tasks: Product 페이지 (Product Page)

**Input**: Design documents from `/specs/006-product-page/`
**Tests**: Not requested — test tasks omitted.

## Format: `[ID] [P?] [Story] Description`

## Path Conventions

- Flutter desktop app: `app/lib/` (models, services, screens)

---

## Phase 1: Foundational

**Purpose**: 모델 + 서비스 + 폴더 rename 인프라

- [x] T001 Update ProductDocument model in `app/lib/models/product_document.dart` — remove problem/vision fields. Fields: name, mission, principles, unknownSections
- [x] T002 Update ProductService parse/serialize in `app/lib/services/product_service.dart` — known sections: mission, principles only. Remove problem/vision parsing. Serialize: name → mission → principles
- [x] T003 Add renameProject() to WorkspaceService in `app/lib/services/workspace_service.dart` — validate new name (reuse validateProjectName), Directory.rename(), return new path. Throw on failure

**Checkpoint**: Model/service/rename ready.

---

## Phase 2: User Story 1 — Product 조회/편집 (P1) MVP

**Goal**: Product 메뉴 → 폼(Name, Mission, Principles) 표시. 디바운스 자동 저장.

- [x] T004 [US1] Update ProductPage in `app/lib/screens/product_page.dart` — remove problem/vision controllers and UI. Keep name, mission, principles. On load: if file empty, init name from folder basename. Debounce auto-save with Timer
- [x] T005 [US1] Verify ProductPage integration in `app/lib/screens/project_detail_screen.dart` — already connected, no change needed

**Checkpoint**: Product 폼 3필드 표시, 디바운스 자동 저장 동작.

---

## Phase 3: User Story 2 — Product Name → 폴더 Rename (P1)

**Goal**: Product Name 변경 시 프로젝트 폴더명 rename.

- [x] T006 [US2] Add rename logic to ProductPage._saveToFile() in `app/lib/screens/product_page.dart` — compare current name with folder basename. If different: call WorkspaceService.renameProject(), update WorkspaceProvider project path, save product.md to new path. On rename failure: SnackBar error, revert name field to previous value
- [x] T007 [US2] Add updateProjectPath() to WorkspaceProvider in `app/lib/providers/workspace_provider.dart` — update active project's path and name after rename. notifyListeners()

**Checkpoint**: Name 수정 → 폴더 rename → 프로젝트 목록에 반영.

---

## Phase 4: User Story 3 — 포맷 호환 (P2)

- [x] T008 [P] [US3] Verify unknown section preservation in ProductService — already implemented. Confirm source/product.md round-trip works

---

## Phase 5: User Story 4 — Principles 목록 관리 (P2)

- [x] T009 [P] [US4] Verify principle add/delete UI in ProductPage — already implemented. Confirm empty filtering works

---

## Phase 6: Polish

- [x] T010 Run flutter analyze
- [x] T011 Run quickstart.md verification flow

---

## Dependencies

- Phase 1 → Phase 2 → Phase 3 (순차)
- Phase 4, 5 → Phase 1 이후 병렬 가능
- Phase 6 → 전체 완료 후
