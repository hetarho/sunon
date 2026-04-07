# Tasks: Policy 페이지

**Input**: Design documents from `/specs/010-policy-page/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Not requested — test tasks omitted per constitution (핵심 경로만).

**Organization**: Tasks grouped by user story for independent implementation.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

---

## Phase 1: Setup

**Purpose**: 신규 파일 생성 및 기본 구조

- [x] T001 [P] Create PolicyDocument and PolicySummary model in `app/lib/models/policy_document.dart`
- [x] T002 [P] Create PolicyService with parse/serialize/CRUD in `app/lib/services/policy_service.dart`

**Checkpoint**: Model과 Service가 독립적으로 동작 가능

---

## Phase 2: Foundational (Wire-up)

**Purpose**: PolicyListPage를 ProjectDetailScreen에 연결

- [x] T003 Create PolicyListPage scaffold (빈 StatefulWidget) in `app/lib/screens/policy_list_page.dart`
- [x] T004 Create PolicyDetailPage scaffold (빈 StatefulWidget) in `app/lib/screens/policy_detail_page.dart`
- [x] T005 Wire PolicyListPage to ProjectDetailScreen case 2 in `app/lib/screens/project_detail_screen.dart`

**Checkpoint**: Policies 메뉴 클릭 시 빈 PolicyListPage 표시

---

## Phase 3: User Story 1 - Policy 목록 조회 (Priority: P1) MVP

**Goal**: Policies 메뉴 클릭 시 policy 목록 표시, 빈 상태 안내

**Independent Test**: Policies 메뉴 클릭 → 기존 policy 파일들이 리스트로 표시되는지 확인

### Implementation

- [x] T006 [US1] Implement `listPolicies(projectPath)` in PolicyService — `policies/*.md` 스캔, PolicySummary 리스트 반환 in `app/lib/services/policy_service.dart`
- [x] T007 [US1] Implement PolicyListPage — `_loadPolicies()` 호출, 목록 표시, 빈 상태 안내 in `app/lib/screens/policy_list_page.dart`
- [x] T008 [US1] Implement 항목 클릭 → PolicyDetailPage 인라인 전환 (`_selectedPath` 패턴) in `app/lib/screens/policy_list_page.dart`

**Checkpoint**: 목록 조회 + 항목 클릭 시 상세 페이지 전환 동작

---

## Phase 4: User Story 2 - Policy 추가 (Priority: P1)

**Goal**: "Policy 추가" 버튼 → 이름 입력 모달 → 생성 후 상세 페이지 이동

**Independent Test**: 추가 버튼 → 이름 입력 → 생성 → 상세 페이지 이동 확인

### Implementation

- [x] T009 [US2] Implement `createPolicy(projectPath, name)` in PolicyService — 파일 생성, `policies/` 디렉토리 자동 생성 포함 in `app/lib/services/policy_service.dart`
- [x] T010 [US2] Implement `validatePolicyName(name, existingNames)` in PolicyService — 빈 이름, 중복, 특수문자 검증 in `app/lib/services/policy_service.dart`
- [x] T011 [US2] Implement `_showAddDialog()` in PolicyListPage — AlertDialog + TextField + 유효성 검사 + 생성 후 상세 이동 in `app/lib/screens/policy_list_page.dart`

**Checkpoint**: 새 policy 추가 및 상세 페이지 자동 이동 동작

---

## Phase 5: User Story 3 - Policy 편집 (Priority: P1)

**Goal**: 상세 페이지에서 제목 필드 + 본문 에디터로 자유 형식 마크다운 편집, 자동 저장

**Independent Test**: 상세 페이지에서 제목/본문 편집 → 파일에 자동 저장 확인

### Implementation

- [x] T012 [US3] Implement `load(filePath)` and `parse(markdown)` in PolicyService — `# ` 제목 분리, 나머지 본문 in `app/lib/services/policy_service.dart`
- [x] T013 [US3] Implement `serialize(PolicyDocument)` and `save(filePath, doc)` in PolicyService in `app/lib/services/policy_service.dart`
- [x] T014 [US3] Implement PolicyDetailPage — 제목 TextField + 본문 multiline TextField + onBack 콜백 in `app/lib/screens/policy_detail_page.dart`
- [x] T015 [US3] Implement 자동 저장 — 500ms 디바운스 Timer, dispose 시 flush in `app/lib/screens/policy_detail_page.dart`

**Checkpoint**: 제목/본문 편집 → 자동 저장 → 파일 내용 반영 확인

---

## Phase 6: User Story 4 - Policy 삭제 (Priority: P2)

**Goal**: 리스트에서 삭제 버튼 → 확인 다이얼로그 → 삭제

**Independent Test**: 삭제 → 확인 → 목록에서 제거 확인

### Implementation

- [x] T016 [US4] Implement `deletePolicy(filePath)` in PolicyService in `app/lib/services/policy_service.dart`
- [x] T017 [US4] Implement `_showDeleteDialog()` in PolicyListPage — 확인 AlertDialog + 삭제 후 목록 갱신 in `app/lib/screens/policy_list_page.dart`

**Checkpoint**: 삭제 + 목록 갱신 동작

---

## Phase 7: User Story 5 - Policy 이름 변경 (Priority: P2)

**Goal**: 상세 페이지에서 제목 변경 시 파일명 리네임

**Independent Test**: 제목 수정 → 파일명 변경 확인

### Implementation

- [x] T018 [US5] Implement `renamePolicy(oldPath, newName, projectPath)` in PolicyService — File.rename + 중복 검사 in `app/lib/services/policy_service.dart`
- [x] T019 [US5] Integrate rename into PolicyDetailPage 자동 저장 — 제목 변경 감지 시 rename 호출, 실패 시 원복 in `app/lib/screens/policy_detail_page.dart`

**Checkpoint**: 제목 변경 → 파일명 리네임 + 목록 복귀 시 변경된 이름 표시

---

## Phase 8: Polish & Cross-Cutting Concerns

- [x] T020 Run quickstart.md validation — 전체 흐름 (추가 → 편집 → 목록 → 삭제) 검증
- [x] T021 Edge case 처리 — `# ` 없는 파일 fallback, 외부 편집 파일 호환성 in `app/lib/services/policy_service.dart`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — T001, T002 병렬 실행 가능
- **Phase 2 (Foundational)**: Phase 1 완료 후 — T003~T005 순차
- **Phase 3 (US1 목록)**: Phase 2 완료 후
- **Phase 4 (US2 추가)**: Phase 2 완료 후 (US1과 병렬 가능하나 순차 권장)
- **Phase 5 (US3 편집)**: Phase 2 완료 후
- **Phase 6 (US4 삭제)**: Phase 3 완료 후 (목록 페이지에 삭제 버튼 추가)
- **Phase 7 (US5 이름 변경)**: Phase 5 완료 후 (상세 페이지에 rename 통합)
- **Phase 8 (Polish)**: 모든 user story 완료 후

### User Story Dependencies

- **US1 (목록)**: Foundational만 필요 — 독립
- **US2 (추가)**: Foundational만 필요 — 독립 (US1과 병렬 가능)
- **US3 (편집)**: Foundational만 필요 — 독립
- **US4 (삭제)**: US1 필요 (목록 페이지에 삭제 UI 추가)
- **US5 (이름 변경)**: US3 필요 (상세 페이지에 rename 통합)

### Parallel Opportunities

- T001, T002 병렬 (Phase 1)
- US1, US2, US3 병렬 가능 (Phase 2 완료 후)

---

## Parallel Example: Phase 1

```bash
# Launch model and service creation together:
Task: "Create PolicyDocument model in app/lib/models/policy_document.dart"
Task: "Create PolicyService in app/lib/services/policy_service.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 + 2 + 3)

1. Phase 1: Setup (T001-T002)
2. Phase 2: Wire-up (T003-T005)
3. Phase 3: 목록 조회 (T006-T008)
4. Phase 4: 추가 (T009-T011)
5. Phase 5: 편집 (T012-T015)
6. **STOP and VALIDATE**: 추가 → 편집 → 목록 흐름 검증

### Incremental Delivery

1. Setup + Foundational → 빈 페이지 표시
2. + US1 → 목록 조회 가능
3. + US2 → 추가 가능 (MVP!)
4. + US3 → 편집 가능 (Core Complete!)
5. + US4 → 삭제 가능
6. + US5 → 이름 변경 가능
7. Polish → 엣지 케이스 처리

---

## Notes

- Entity 패턴(entity_list_page, entity_detail_page, entity_service)을 그대로 따름
- Policy는 Entity보다 단순 (속성 테이블 → 자유 텍스트)
- 총 21개 태스크, 8개 Phase
- 커밋은 각 Phase 완료 시 또는 논리적 단위로
