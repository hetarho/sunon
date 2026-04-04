# Tasks: Entity Page

**Input**: Design documents from `/specs/007-entity-page/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: Not explicitly requested — test tasks omitted per Constitution I (Speed Over Stability).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter desktop app**: `app/lib/` at repository root
- Models: `app/lib/models/`
- Services: `app/lib/services/`
- Screens: `app/lib/screens/`

---

## Phase 1: Setup

**Purpose**: 공유 모델과 서비스 생성 — 모든 User Story의 기반

- [x] T001 [P] Create EntityDocument and EntityColumn models in app/lib/models/entity_document.dart — EntityDocument(name, columns, unknownSections), EntityColumn(name, type, required, description), EntitySummary(name, filePath) 클래스 정의. RawSection은 기존 product_document.dart에서 재사용. 지원 타입 목록 상수 정의: `int`, `string`, `float`, `bool`, `datetime`, `text`
- [x] T002 [P] Create EntityService in app/lib/services/entity_service.dart — ProductService 패턴을 따라 구현: (1) `listEntities(String projectPath)` → entities/ 디렉토리 스캔, .md 파일 목록을 EntitySummary 리스트로 반환, 디렉토리 없으면 자동 생성 (2) `load(String filePath)` → md 파일 읽기 + parse 호출 (3) `parse(String markdown)` → h1에서 name 추출, `## columns` 이후 마크다운 테이블 파싱(파이프 구분, 헤더/구분선 skip), 알 수 없는 h2 섹션은 unknownSections로 보존 (4) `serialize(EntityDocument doc)` → EntityDocument를 마크다운 문자열로 변환 (5) `save(String filePath, EntityDocument doc)` → serialize 후 파일 쓰기 (6) `createEntity(String projectPath, String entityName)` → 이름 유효성 검사(빈값, 중복, 특수문자) + 초기 md 파일 생성(h1 + 빈 columns 테이블) (7) `deleteEntity(String filePath)` → 파일 삭제 (8) `validateEntityName(String name, List<String> existingNames)` → 오류 메시지 또는 null 반환

**Checkpoint**: 모델과 서비스가 준비되어 UI 구현을 시작할 수 있다

---

## Phase 2: User Story 1 - View Entity List (Priority: P1) 🎯 MVP

**Goal**: 사이드바 Entities 메뉴 클릭 시 entities/ 디렉토리의 엔티티 목록을 표시한다

**Independent Test**: Entities 메뉴 클릭 후 entities 디렉토리의 md 파일 목록이 화면에 리스트로 표시되는지 확인

### Implementation for User Story 1

- [x] T003 [US1] Create EntityListPage in app/lib/screens/entity_list_page.dart — StatefulWidget, projectPath를 생성자 파라미터로 받음. initState에서 EntityService.listEntities() 호출하여 엔티티 목록 로드. 목록이 있으면 ListView로 각 엔티티 이름 표시(클릭 시 상세 페이지 이동을 위한 콜백). 목록이 비어있으면 빈 상태 안내 메시지("엔티티가 없습니다") + Add Entity 버튼 표시. 상단에 "Add Entity" 버튼 항상 표시. 내부 상태로 `_selectedEntity`(String?)를 관리하여 null이면 리스트, 값이 있으면 EntityDetailPage를 렌더링하는 리스트↔상세 전환 구현
- [x] T004 [US1] Wire EntityListPage to ProjectDetailScreen sidebar index 1 in app/lib/screens/project_detail_screen.dart — _selectedIndex == 1일 때 기존 플레이스홀더 텍스트를 EntityListPage(projectPath: activeProject.path)로 교체

**Checkpoint**: Entities 메뉴 클릭 시 엔티티 리스트가 표시된다. 빈 상태와 목록 상태 모두 동작.

---

## Phase 3: User Story 2 - Add New Entity (Priority: P1)

**Goal**: Add Entity 버튼 → 이름 입력 모달 → md 파일 생성 → 리스트 갱신

**Independent Test**: Add Entity 버튼 클릭, 모달에서 이름 입력, Create 후 entities/ 디렉토리에 md 파일 생성 및 리스트 반영 확인

### Implementation for User Story 2

- [x] T005 [US2] Add entity creation modal and logic to EntityListPage in app/lib/screens/entity_list_page.dart — Add Entity 버튼 클릭 시 showDialog로 엔티티명 입력 모달 표시. TextField + Create/Cancel 버튼. Create 클릭 시: (1) EntityService.validateEntityName() 호출하여 빈값/중복/특수문자 검증 (2) 유효하면 EntityService.createEntity() 호출하여 초기 md 파일 생성 (3) 리스트 새로고침(setState + listEntities 재호출). 유효성 오류 시 모달 내에 오류 메시지 표시. Cancel 또는 모달 외부 클릭 시 모달 닫기

**Checkpoint**: 엔티티 생성이 동작한다. 모달 유효성 검사, 파일 생성, 리스트 갱신 모두 확인.

---

## Phase 4: User Story 3 - Entity Detail Page with Column Management (Priority: P1)

**Goal**: 엔티티 상세 페이지에서 칼럼(name, type, required, description) CRUD + 500ms 디바운스 자동 저장 + 테이블 형태 표시

**Independent Test**: 엔티티 상세 페이지에서 칼럼 추가/편집/삭제 후 md 파일에 올바르게 저장되고, 화면에 테이블로 표시되는지 확인

### Implementation for User Story 3

- [x] T006 [US3] Create EntityDetailPage in app/lib/screens/entity_detail_page.dart — StatefulWidget, entityFilePath와 onBack 콜백을 생성자 파라미터로 받음. ProductPage 패턴을 따라 구현: (1) initState에서 EntityService.load()로 md 파일 로드, 각 칼럼별 TextEditingController 생성 (2) 상단에 뒤로가기 버튼(onBack 호출) + 엔티티 이름 표시 (3) 칼럼 목록을 테이블/카드 형태로 표시: 각 행에 name(TextField), type(DropdownButton with 6 types), required(Checkbox), description(TextField), 삭제 버튼(IconButton) (4) "Add Column" 버튼으로 새 빈 칼럼 행 추가 (5) 모든 필드 변경 시 _onFieldChanged() 호출 → 500ms 디바운스 타이머로 _saveToFile() 실행 (6) _saveToFile(): 현재 컨트롤러 값으로 EntityDocument 빌드 → EntityService.save() 호출 (7) dispose()에서 디바운스 타이머 활성 시 즉시 저장, 모든 컨트롤러 dispose
- [x] T007 [US3] Integrate EntityDetailPage into EntityListPage navigation in app/lib/screens/entity_list_page.dart — _selectedEntity가 null이 아닐 때 EntityDetailPage(entityFilePath: selectedFilePath, onBack: () => setState(() => _selectedEntity = null)) 렌더링. 엔티티 리스트 아이템 클릭 시 setState로 _selectedEntity 설정. 뒤로가기 시 리스트 새로고침(listEntities 재호출)

**Checkpoint**: 엔티티 상세 페이지에서 칼럼 CRUD와 자동 저장이 동작한다. md 파일이 올바른 마크다운 테이블 형식으로 저장된다.

---

## Phase 5: User Story 4 - Delete Entity (Priority: P2)

**Goal**: 엔티티 리스트에서 삭제 버튼 → 확인 다이얼로그 → md 파일 삭제 → 리스트 갱신

**Independent Test**: 엔티티 삭제 버튼 클릭, 확인 다이얼로그에서 확인 후 파일 삭제 및 리스트 반영 확인

### Implementation for User Story 4

- [x] T008 [US4] Add delete functionality to EntityListPage in app/lib/screens/entity_list_page.dart — 각 엔티티 리스트 아이템에 삭제 아이콘 버튼 추가. 클릭 시 showDialog로 삭제 확인 다이얼로그 표시("정말 삭제하시겠습니까?"). 확인 클릭 시 EntityService.deleteEntity() 호출 후 리스트 새로고침. 취소 클릭 시 다이얼로그 닫기

**Checkpoint**: 엔티티 삭제가 동작한다. 확인 다이얼로그, 파일 삭제, 리스트 갱신 모두 확인.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 전체 기능 점검 및 엣지 케이스 처리

- [x] T009 Edge case handling: entities 디렉토리 자동 생성(EntityService.listEntities에서), 비정상 md 파일 파싱 시 가능한 부분만 표시 + unknownSections 보존, 엔티티명 공백 허용 확인
- [x] T010 Run quickstart.md validation — 전체 플로우 테스트: 엔티티 생성 → 칼럼 추가/편집/삭제 → 자동 저장 → 뒤로가기 → 리스트 확인 → 엔티티 삭제

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — T001, T002 병렬 실행 가능
- **Phase 2 (US1)**: Phase 1 완료 후 시작. T003 → T004 순서
- **Phase 3 (US2)**: Phase 2 완료 후 시작 (EntityListPage 필요)
- **Phase 4 (US3)**: Phase 2 완료 후 시작 (EntityListPage 필요). US2와 병렬 가능하나 순차 권장
- **Phase 5 (US4)**: Phase 2 완료 후 시작 (EntityListPage 필요)
- **Phase 6 (Polish)**: 모든 User Story 완료 후

### User Story Dependencies

- **US1 (View List)**: Phase 1 이후 독립 실행 가능 — 다른 Story 의존 없음
- **US2 (Add Entity)**: US1 필요 (EntityListPage에 모달 추가)
- **US3 (Detail + Columns)**: US1 필요 (EntityListPage에 네비게이션 통합)
- **US4 (Delete)**: US1 필요 (EntityListPage에 삭제 버튼 추가)

### Within Each User Story

- Models/Services before Screens
- Core implementation before integration

### Parallel Opportunities

- T001 (모델) + T002 (서비스) 병렬 가능 (Phase 1)
- US2, US3, US4는 모두 US1 완료 후 이론적으로 병렬 가능하나, 동일 파일(entity_list_page.dart) 수정이므로 순차 권장

---

## Parallel Example: Phase 1

```bash
# 두 파일을 동시에 생성:
Task T001: "Create EntityDocument/EntityColumn models in app/lib/models/entity_document.dart"
Task T002: "Create EntityService in app/lib/services/entity_service.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 + 2)

1. Complete Phase 1: Setup (T001, T002)
2. Complete Phase 2: US1 — Entity List (T003, T004)
3. Complete Phase 3: US2 — Add Entity (T005)
4. **STOP and VALIDATE**: 엔티티 생성 + 리스트 확인
5. 동작 확인 후 다음 진행

### Incremental Delivery

1. Phase 1 → 모델/서비스 기반 완성
2. US1 (리스트) → US2 (생성) → 기본 엔티티 관리 가능 (MVP!)
3. US3 (상세/칼럼) → 핵심 가치 완성
4. US4 (삭제) → CRUD 완성
5. Polish → 엣지 케이스 처리

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- ProductPage/ProductService 패턴을 최대한 따라 일관성 유지
- 500ms 디바운스 자동 저장 + dispose 시 강제 저장 패턴 재사용
- 마크다운 테이블 파싱은 파이프(|) 기반 직접 구현 (외부 라이브러리 없음)
- Commit after each task or logical group
