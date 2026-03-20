# Feature Specification: Project Scaffold

**Feature Branch**: `001-project-scaffold`
**Created**: 2026-03-21
**Status**: Draft
**Input**: 기술스택 설정 및 프로젝트 초기 구조 생성. Flutter 앱 + Express 백엔드 + Vite+React 프론트엔드. 모두 "hi sunon"만 표시하는 최소 실행 확인용 scaffold.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 웹 앱에서 hi sunon 확인 (Priority: P1)

개발자가 백엔드(Express)와 프론트엔드(Vite+React)를 각각 실행하고, 브라우저에서 접속하면 화면에 "hi sunon"이 표시된다.

**Why this priority**: 웹은 가장 빠르게 확인 가능한 플랫폼이고, 백엔드-프론트엔드 연결이 이후 모든 기능의 기반이 된다.

**Independent Test**: 백엔드와 프론트엔드를 각각 실행한 뒤 브라우저에서 접속하여 "hi sunon" 텍스트가 화면에 보이는지 확인.

**Acceptance Scenarios**:

1. **Given** 백엔드 서버가 실행 중일 때, **When** API 엔드포인트에 요청을 보내면, **Then** 정상 응답을 반환한다
2. **Given** 프론트엔드 개발 서버가 실행 중일 때, **When** 브라우저에서 접속하면, **Then** 화면에 "hi sunon" 텍스트가 표시된다
3. **Given** 프론트엔드가 백엔드에 연결된 상태일 때, **When** 페이지를 로드하면, **Then** 백엔드로부터 데이터를 받아 "hi sunon"을 표시한다

---

### User Story 2 - Flutter 앱에서 hi sunon 확인 (Priority: P2)

개발자가 Flutter 앱을 빌드하고 실행하면, 앱 화면에 "hi sunon"이 표시된다.

**Why this priority**: 모바일/데스크톱 앱이 최종 주력 클라이언트이지만, 웹 연결이 먼저 확인되어야 한다.

**Independent Test**: Flutter 앱을 실행하여 화면에 "hi sunon" 텍스트가 보이는지 확인.

**Acceptance Scenarios**:

1. **Given** Flutter 프로젝트가 생성된 상태일 때, **When** 앱을 빌드하고 실행하면, **Then** 화면에 "hi sunon" 텍스트가 표시된다
2. **Given** Flutter 앱이 실행 중일 때, **When** 웹 브라우저에서도 Flutter 웹 빌드를 실행하면, **Then** 동일하게 "hi sunon"이 표시된다

---

### Edge Cases

- Flutter 프로젝트와 웹 프론트엔드가 동시에 실행될 때 포트 충돌이 없어야 한다
- 백엔드가 꺼져 있을 때 프론트엔드가 단독으로 에러 없이 표시되어야 한다

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Express 백엔드 서버가 단일 명령으로 실행 가능해야 한다
- **FR-002**: Vite+React 프론트엔드가 단일 명령으로 실행 가능해야 한다
- **FR-003**: Flutter 앱이 단일 명령으로 빌드 및 실행 가능해야 한다
- **FR-004**: 모든 클라이언트(웹, Flutter)에서 "hi sunon" 텍스트가 화면 중앙에 표시되어야 한다
- **FR-005**: 백엔드는 프론트엔드의 요청에 응답하는 health check 엔드포인트를 제공해야 한다
- **FR-006**: 프로젝트 루트에서 각 서브 프로젝트(backend, frontend, flutter)의 위치와 실행 방법이 명확해야 한다

### Assumptions

- Flutter는 최신 stable 버전을 사용한다
- Express 백엔드는 기본 포트 3000, Vite 프론트엔드는 기본 포트 5173을 사용한다
- Flutter 앱은 우선 로컬 실행(시뮬레이터/에뮬레이터 또는 웹)만 확인한다
- 이 단계에서는 인증, 데이터베이스, 상태 관리 등은 포함하지 않는다

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 개발자가 3개 명령 이내로 모든 서브 프로젝트를 각각 실행할 수 있다
- **SC-002**: 웹 브라우저에서 "hi sunon" 텍스트가 3초 이내에 표시된다
- **SC-003**: Flutter 앱 실행 시 "hi sunon" 텍스트가 화면에 표시된다
- **SC-004**: 각 서브 프로젝트가 독립적으로 실행 및 중단 가능하다
