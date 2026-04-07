# Tasks: 데이터 구조 페이지 개편

**Input**: Design documents from `/specs/009-revise-data-structure-page/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Not requested. Test tasks excluded.

**Organization**: Tasks are grouped by user story. Foundational phase covers shared model/service changes.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter desktop app**: `app/lib/` at repository root

---

## Phase 1: Foundational (Model & Service Refactoring)

**Purpose**: 모델과 서비스를 새 스펙에 맞게 단순화. 모든 UI 작업의 전제 조건.

**⚠️ CRITICAL**: UI 작업(Phase 2+)은 이 phase 완료 후 시작 가능

- [x] T001 [P] 모델 단순화 — `EntityColumn` → `Attribute`(name, info), `LocalType`/`LocalEnum`/`supportedColumnTypes` 제거, `EntityDocument` 필드를 name/attributes/unknownSections로 변경 in `app/lib/models/entity_document.dart`
- [x] T002 [P] 서비스 리팩터링 — 디렉토리 `entities/` → `data/`, 파싱을 `## 속성` 2칸 테이블로 변경, 직렬화를 `속성명 | 속성 정보` 형식으로 변경, `listTypes`/`createType`/`deleteType` 제거, 검증 메시지 "엔티티" → "데이터 항목"으로 변경 in `app/lib/services/entity_service.dart`

**Checkpoint**: 모델과 서비스가 새 마크다운 형식(2칸 테이블)으로 파싱/직렬화 가능

---

## Phase 2: User Story 1+2 — 데이터 항목 목록 조회 및 추가 (Priority: P1) 🎯 MVP

**Goal**: 사이드바에서 "데이터 구조" 메뉴 클릭 시 데이터 항목 리스트 표시. "데이터 항목 추가" 버튼으로 새 항목 생성.

**Independent Test**: 데이터 구조 메뉴 클릭 → 리스트 표시. 추가 버튼 → 모달 → 이름 입력 → 생성 → `data/` 디렉토리에 md 파일 생성 + 리스트 갱신.

### Implementation

- [x] T003 [US1] 리스트 페이지 리팩터링 — Types 섹션 전체 제거, `DetailKind` 참조 제거, 용어 "엔티티" → "데이터 항목" 변경, 섹션 헤더 "Entities" → "데이터 항목", 빈 상태 메시지 변경, "Add Entity" → "데이터 항목 추가" in `app/lib/screens/entity_list_page.dart`
- [x] T004 [US1] 사이드바 메뉴명 변경 — `_menuLabels[1]`을 `'Entities'` → `'데이터 구조'`로 변경 in `app/lib/screens/project_detail_screen.dart`

**Checkpoint**: 사이드바 "데이터 구조" 클릭 → 데이터 항목 리스트 표시 + 추가 기능 동작

---

## Phase 3: User Story 3 — 데이터 항목 상세 페이지에서 속성 관리 (Priority: P1)

**Goal**: 상세 페이지에서 "속성명 | 속성 정보" 2칸 표 형태로 속성을 추가/편집/삭제. 자동 저장.

**Independent Test**: 항목 클릭 → 상세 페이지 → 속성 추가 → 속성명/속성 정보 입력 → 자동 저장 → md 파일에 2칸 테이블 형식으로 저장 확인.

### Implementation

- [x] T005 [US3] 상세 페이지 전면 리팩터링 — `_LocalTypeCtrl`/`_LocalEnumCtrl` 클래스 제거, `DetailKind` enum 제거, 5칸 테이블 → 2칸 테이블(속성명/속성 정보) TextField 2개로 변경, 타입 드롭다운/isList·required 체크박스 제거, Local Type/Enum 섹션 UI 전체 제거, 헤더 "Add Column" → "속성 추가", 빈 상태 "칼럼이 없습니다" → "속성이 없습니다" in `app/lib/screens/entity_detail_page.dart`

**Checkpoint**: 상세 페이지에서 2칸 표 형태로 속성 추가/편집/삭제 + 자동 저장 동작

---

## Phase 4: User Story 4 — 데이터 항목 삭제 (Priority: P2)

**Goal**: 리스트에서 삭제 버튼 → 확인 다이얼로그 → 항목 삭제.

**Independent Test**: 리스트에서 삭제 클릭 → 확인 → 항목 삭제 및 리스트 갱신.

### Implementation

- [x] T006 [US4] 삭제 다이얼로그 용어 변경 — 삭제 확인 메시지 "엔티티" → "데이터 항목"으로 변경 in `app/lib/screens/entity_list_page.dart`

**Checkpoint**: 삭제 기능이 새 용어로 동작

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: 전체 동작 검증 및 정리

- [x] T007 quickstart.md 검증 — 앱 실행 후 전체 흐름 (리스트 → 추가 → 상세 → 속성 편집 → 삭제) 동작 확인
- [x] T008 불필요 import 및 dead code 정리 — `product_document.dart` import 불필요 시 제거 등 전체 파일 정리

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Foundational)**: No dependencies — 즉시 시작. T001과 T002 병렬 가능.
- **Phase 2 (US1+US2)**: Phase 1 완료 필요. T003과 T004 병렬 가능.
- **Phase 3 (US3)**: Phase 1 완료 필요. Phase 2와 병렬 가능 (다른 파일).
- **Phase 4 (US4)**: Phase 2 완료 필요 (같은 파일 T003 수정 후).
- **Phase 5 (Polish)**: 모든 Phase 완료 후.

### Parallel Opportunities

- T001 ∥ T002 (model과 service는 다른 파일)
- T003 ∥ T004 (list page와 project detail은 다른 파일)
- Phase 2 ∥ Phase 3 (list page와 detail page는 다른 파일)

---

## Parallel Example

```bash
# Phase 1: 모델과 서비스 병렬
Task: "T001 모델 단순화 in app/lib/models/entity_document.dart"
Task: "T002 서비스 리팩터링 in app/lib/services/entity_service.dart"

# Phase 2+3: 리스트와 상세 페이지 병렬
Task: "T003 리스트 페이지 in app/lib/screens/entity_list_page.dart"
Task: "T005 상세 페이지 in app/lib/screens/entity_detail_page.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1+2)

1. Complete Phase 1: Model + Service foundational refactoring
2. Complete Phase 2: List page (view + add)
3. **STOP and VALIDATE**: 데이터 항목 리스트 조회 및 추가 독립 동작 확인
4. Deploy/demo if ready

### Incremental Delivery

1. Phase 1 (Foundational) → Model/Service ready
2. Phase 2 (US1+US2) → List + Add → MVP!
3. Phase 3 (US3) → Detail + Attributes → Core complete
4. Phase 4 (US4) → Delete → Full feature
5. Phase 5 (Polish) → Cleanup → Done

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- US1과 US2는 동일 파일(entity_list_page.dart)에서 처리되므로 하나의 Phase로 통합
- US4(삭제)는 US1+US2의 리스트 페이지 리팩터링 후 용어 변경만 필요
- Commit after each phase for clean history
