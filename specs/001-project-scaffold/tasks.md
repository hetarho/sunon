# Tasks: Project Scaffold

**Input**: Design documents from `/specs/001-project-scaffold/`
**Prerequisites**: plan.md (required), spec.md (required)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: 3개 서브 프로젝트 디렉토리 초기화

- [x] T001 Initialize Express backend project with package.json and TypeScript in backend/
- [x] T002 Scaffold Vite+React frontend project with TypeScript template in frontend/
- [x] T003 Create Flutter project in app/

**Checkpoint**: 3개 서브 프로젝트 디렉토리가 존재하고 각각 의존성 설치 가능

---

## Phase 2: User Story 1 - 웹 앱에서 hi sunon 확인 (Priority: P1) 🎯 MVP

**Goal**: Express BE + Vite+React FE 실행 시 브라우저에서 "hi sunon" 표시

**Independent Test**: `cd backend && npm run dev` 후 `curl localhost:3000/api/health` → `{"message":"hi sunon"}`, `cd frontend && npm run dev` 후 브라우저 localhost:5173 → "hi sunon" 표시

### Implementation for User Story 1

- [x] T004 [US1] Implement Express server with GET /api/health endpoint returning {"message":"hi sunon"} in backend/src/index.ts
- [x] T005 [US1] Add CORS middleware and dev script to backend (backend/package.json, backend/src/index.ts)
- [x] T006 [US1] Replace default Vite+React app with "hi sunon" display fetching from backend API in frontend/src/App.tsx
- [x] T007 [US1] Configure Vite proxy to backend in frontend/vite.config.ts
- [x] T008 [US1] Verify BE+FE running together: backend serves API, frontend displays "hi sunon" from API response

**Checkpoint**: 백엔드와 프론트엔드를 각각 실행하면 브라우저에서 "hi sunon"이 표시됨

---

## Phase 3: User Story 2 - Flutter 앱에서 hi sunon 확인 (Priority: P2)

**Goal**: Flutter 앱 실행 시 화면 중앙에 "hi sunon" 표시

**Independent Test**: `cd app && flutter run` → 앱 화면 중앙에 "hi sunon" 텍스트 표시

### Implementation for User Story 2

- [x] T009 [US2] Replace default Flutter counter app with centered "hi sunon" text in app/lib/main.dart
- [x] T010 [US2] Verify Flutter app runs on simulator/web and displays "hi sunon"

**Checkpoint**: Flutter 앱 실행 시 화면 중앙에 "hi sunon" 표시

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - T001, T002, T003 can all run in parallel
- **User Story 1 (Phase 2)**: Depends on T001 (backend) and T002 (frontend) completion
- **User Story 2 (Phase 3)**: Depends on T003 (Flutter) completion only — can run in parallel with US1

### Parallel Opportunities

```bash
# Phase 1: All setup tasks in parallel
T001 (backend init) | T002 (frontend init) | T003 (flutter init)

# Phase 2+3: User stories can run in parallel
US1 (T004→T005→T006→T007→T008) | US2 (T009→T010)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete T001, T002 (Setup for web)
2. Complete T004-T008 (User Story 1)
3. **STOP and VALIDATE**: 브라우저에서 "hi sunon" 확인
4. Proceed to User Story 2

### Parallel Strategy

1. T001 + T002 + T003 (모든 프로젝트 동시 초기화)
2. US1 (T004-T008) + US2 (T009-T010) 동시 진행
3. 각 스토리 독립 검증

---

## Notes

- [P] tasks = different files, no dependencies
- Tests not included (spec에서 테스트 미요청, constitution "핵심 경로만")
- 각 user story는 독립적으로 완성 및 검증 가능
- Commit after each task or logical group
