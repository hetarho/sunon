# Tasks: Global Context Panel

**Input**: Design documents from `/specs/008-global-context-panel/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/ui-contract.md

**Tests**: Not requested. Manual testing via desktop app.

**Organization**: Tasks grouped by user story. All changes concentrated in 2 files.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Foundational

**Purpose**: 기존 코드 수정 — 패널에서 Product rename 시 전체 UI 갱신을 위한 사전 작업

- [x] T001 `workspace_provider.dart`의 `updateProjectPath()`에 `notifyListeners()` 추가하여 rename 후 UI rebuild가 트리거되도록 변경 in `app/lib/providers/workspace_provider.dart`

**Checkpoint**: Provider 변경 완료. 기존 Product 페이지에서 이름 변경 동작이 정상인지 확인.

---

## Phase 2: User Story 1 - 패널 열기/닫기 토글 (Priority: P1) 🎯 MVP

**Goal**: AppBar 우측에 토글 버튼을 추가하고, 클릭 시 메인 콘텐츠 우측에 패널 영역이 나타나는 레이아웃 분할 구현.

**Independent Test**: 토글 버튼 클릭 → 우측에 빈 패널 영역(320px) 등장 → 다시 클릭 → 패널 닫힘. 메뉴 전환 시 패널 상태 유지.

### Implementation for User Story 1

- [x] T002 [US1] `ProjectDetailScreen`에 `_isPanelOpen` state 변수 추가 (기본값 false) in `app/lib/screens/project_detail_screen.dart`
- [x] T003 [US1] AppBar의 `actions`에 패널 토글 IconButton 추가 (Icons.vertical_split). 클릭 시 `setState(() => _isPanelOpen = !_isPanelOpen)` in `app/lib/screens/project_detail_screen.dart`
- [x] T004 [US1] `build()` 메서드의 body Row에 패널 영역 조건부 추가: `if (_isPanelOpen) ...[VerticalDivider, SizedBox(width: 320, child: placeholder)]` in `app/lib/screens/project_detail_screen.dart`

**Checkpoint**: 토글 버튼으로 우측 패널 열기/닫기 동작 확인. 패널에는 임시 placeholder 텍스트 표시.

---

## Phase 3: User Story 2 - 엔티티 페이지에서 Product 정보 조회 및 편집 (Priority: P1)

**Goal**: 패널에 기존 ProductPage 위젯을 직접 임베드하여 Entities 페이지에서 Product 편집 가능.

**Independent Test**: Entities 메뉴 → 패널 열기 → Product Mission 수정 → Product 메뉴로 이동 → 수정 내용 반영 확인. Entity 칼럼 편집과 패널 Product 편집 동시 진행 시 각각 독립 저장.

### Implementation for User Story 2

- [x] T005 [US2] `_buildContextPanel(String projectPath)` 메서드 추가. 현재 `_selectedIndex`가 1(Entities)일 때 `ProductPage(projectPath: projectPath)`를 반환, 나머지는 "향후 지원" placeholder 반환 in `app/lib/screens/project_detail_screen.dart`
- [x] T006 [US2] Phase 2에서 추가한 패널 SizedBox의 child를 placeholder에서 `_buildContextPanel(projectPath)` 호출로 교체 in `app/lib/screens/project_detail_screen.dart`

**Checkpoint**: Entities 페이지에서 패널을 열면 Product 편집 폼이 표시. 패널에서 Mission 수정 → product.md 자동 저장 → Product 메뉴에서 반영 확인. 엔티티 칼럼 편집과 동시 진행 테스트.

---

## Phase 4: User Story 3 - 현재 페이지에 따른 컨텍스트 자동 구성 (Priority: P2)

**Goal**: 문서 계층의 의존성 규칙에 따라 패널 토글 버튼 활성화/비활성화 자동 결정 및 페이지 전환 시 패널 내용 자동 갱신.

**Independent Test**: Product 메뉴 → 토글 버튼 비활성화(greyed out) 확인. Entities 메뉴 → 토글 버튼 활성화. 패널 열린 상태에서 메뉴 전환 → 패널 내용 갱신.

### Implementation for User Story 3

- [x] T007 [US3] `_layerReferences` 상수 Map 추가 (메뉴 인덱스 → 참조 가능 인덱스 리스트). {0: [], 1: [0], 2: [0,1], 3: [0,1,2], 4: [0,1,2], 5: [0,1,2,3,4]} in `app/lib/screens/project_detail_screen.dart`
- [x] T008 [US3] AppBar 토글 버튼에 `_layerReferences[_selectedIndex]!.isEmpty` 조건으로 비활성화 적용 (onPressed: null, 아이콘 opacity 조절) in `app/lib/screens/project_detail_screen.dart`
- [x] T009 [US3] 패널이 열린 상태에서 `_selectedIndex` 변경 시, 참조 가능 목록이 비면 `_isPanelOpen = false`로 자동 닫기 (Product 페이지 이동 시) in `app/lib/screens/project_detail_screen.dart`

**Checkpoint**: Product 메뉴에서 토글 비활성화. Entities에서 패널 열기 후 Product 메뉴로 이동 → 패널 자동 닫힘 + 버튼 비활성화. 다시 Entities로 이동 → 버튼 활성화.

---

## Phase 5: User Story 4 - 패널 내 섹션 접기/펼치기 (Priority: P3)

**Goal**: 패널에 여러 섹션이 있을 때 접기/펼치기 가능. 초기 구현에서 섹션이 1개(Product)뿐이므로 최소 구현.

**Independent Test**: 패널의 섹션 헤더 클릭 → 접힘 → 다시 클릭 → 펼침.

### Implementation for User Story 4

- [x] T010 [US4] `_buildContextPanel()`에서 섹션을 `ExpansionTile` (또는 유사 위젯)으로 래핑. "Product" 헤더와 접기/펼치기 동작 추가 in `app/lib/screens/project_detail_screen.dart`

**Checkpoint**: 패널의 Product 섹션 헤더 클릭으로 접기/펼치기 동작 확인.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T011 패널 열림/닫힘 시 부드러운 전환 확인 (AnimatedContainer 또는 기본 Flutter layout 애니메이션 활용 검토) in `app/lib/screens/project_detail_screen.dart`
- [ ] T012 전체 시나리오 통합 테스트: quickstart.md의 4개 테스트 시나리오 수동 검증

---

## Dependencies & Execution Order

### Phase Dependencies

- **Foundational (Phase 1)**: No dependencies — 즉시 시작 가능
- **US1 (Phase 2)**: Foundational 완료 후 시작
- **US2 (Phase 3)**: US1 완료 후 시작 (패널 레이아웃이 있어야 콘텐츠 배치 가능)
- **US3 (Phase 4)**: US2 완료 후 시작 (콘텐츠가 있어야 자동 구성이 의미 있음)
- **US4 (Phase 5)**: US2 완료 후 시작 (US3과 독립적)
- **Polish (Phase 6)**: 모든 User Story 완료 후

### User Story Dependencies

```
Foundational (T001)
    │
    ▼
US1: 패널 토글 (T002-T004)
    │
    ▼
US2: Product 편집 (T005-T006)
    │
    ├──▶ US3: 자동 구성 (T007-T009)
    │
    └──▶ US4: 접기/펼치기 (T010)  ← US3과 병렬 가능
```

### Parallel Opportunities

- **T007 + T010**: US3과 US4는 독립적이므로 US2 완료 후 병렬 진행 가능
- 단, 모든 태스크가 동일 파일(`project_detail_screen.dart`)을 수정하므로 실제 동시 편집은 주의 필요

---

## Implementation Strategy

### MVP First (US1 + US2)

1. T001: Foundational (workspace_provider 수정)
2. T002-T004: US1 (패널 토글 레이아웃)
3. T005-T006: US2 (ProductPage 임베드)
4. **STOP and VALIDATE**: 엔티티에서 Product 편집 동작 확인
5. 여기까지가 MVP — 핵심 가치(흐름 유지하면서 맥락 편집) 달성

### Incremental Delivery

1. MVP (US1+US2) → 핵심 가치 달성
2. US3 추가 → Product 페이지에서 버튼 비활성화, 계층별 규칙
3. US4 추가 → 접기/펼치기 (향후 다중 섹션 대비)
4. Polish → 전환 애니메이션, 통합 검증

---

## Notes

- 모든 구현이 2개 파일에 집중됨 (`project_detail_screen.dart` 95%, `workspace_provider.dart` 5%)
- 신규 파일 생성 없음
- 기존 `ProductPage` 위젯을 변경 없이 그대로 재사용
- Constitution "Speed Over Stability" + "Minimal Viable Iteration" 준수
