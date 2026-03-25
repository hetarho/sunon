# Feature Specification: Workspace & Project Management (Flutter Desktop)

**Feature Branch**: `003-workspace-project`
**Created**: 2026-03-25
**Status**: Draft
**Input**: User description: "Flutter 앱에서 workspace/project 개념 구현 - workspace는 디렉토리 선택으로 열리고 하위 폴더가 프로젝트가 됨. VSCode처럼 마지막 열었던 경로 기억, 새 창에서는 workspace 선택 UI 제공"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Open Workspace via Directory Selection (Priority: P1)

사용자가 앱을 처음 실행하거나 "Open Workspace"를 선택하면, 시스템 디렉토리 선택 대화상자가 나타난다. 사용자가 디렉토리를 선택하면 해당 디렉토리가 workspace로 열리고, 바로 하위에 있는 폴더들이 각각 하나의 project로 인식되어 목록에 표시된다.

**Why this priority**: 이것이 핵심 기능이다. workspace를 열 수 없으면 앱의 다른 기능이 동작하지 않는다.

**Independent Test**: 앱 실행 후 디렉토리를 선택하고, 해당 디렉토리 내 하위 폴더들이 프로젝트 목록으로 표시되는지 확인한다.

**Acceptance Scenarios**:

1. **Given** 앱이 실행되었고 열린 workspace가 없음, **When** 사용자가 "Open Workspace" 버튼을 누름, **Then** OS 네이티브 디렉토리 선택 대화상자가 표시됨
2. **Given** 디렉토리 선택 대화상자가 열림, **When** 사용자가 특정 디렉토리를 선택함, **Then** 해당 디렉토리가 workspace로 열리고, 직접 하위 폴더들이 프로젝트 목록에 나타남
3. **Given** 선택한 workspace 디렉토리에 `app-a/`, `app-b/`, `lib-c/` 폴더가 있음, **When** workspace가 열림, **Then** 3개의 프로젝트(app-a, app-b, lib-c)가 목록에 표시됨

---

### User Story 2 - Restore Last Opened Workspace on App Launch (Priority: P1)

사용자가 앱을 종료한 후 다시 실행하면, 마지막에 열었던 workspace 경로가 자동으로 복원되어 바로 해당 workspace와 프로젝트 목록이 표시된다. VSCode처럼 이전 작업 상태를 그대로 이어갈 수 있다.

**Why this priority**: 매번 앱을 열 때마다 workspace를 다시 선택해야 한다면 사용성이 크게 떨어진다. 핵심 UX 요소이다.

**Independent Test**: workspace를 열고 앱을 종료한 뒤, 다시 실행하여 이전 workspace가 자동으로 열리는지 확인한다.

**Acceptance Scenarios**:

1. **Given** 사용자가 특정 디렉토리를 workspace로 열고 앱을 종료함, **When** 앱을 다시 실행함, **Then** 해당 디렉토리가 자동으로 workspace로 열리고 프로젝트 목록이 표시됨
2. **Given** 마지막 열었던 workspace 디렉토리가 더 이상 존재하지 않음, **When** 앱을 실행함, **Then** workspace 선택 화면이 표시됨 (에러 없이 graceful fallback)

---

### User Story 3 - Open New Window with Workspace Selection (Priority: P2)

사용자가 이미 workspace가 열려있는 상태에서 "새 창"을 열면, workspace 선택 화면이 나타난다. 다른 workspace를 선택하여 별도의 창에서 작업할 수 있다.

**Why this priority**: 여러 workspace를 동시에 작업하는 것은 고급 기능이지만, VSCode와 유사한 경험을 위해 중요하다.

**Independent Test**: 앱에서 새 창 열기를 실행하고, workspace 선택 화면이 나타나는지 확인한다.

**Acceptance Scenarios**:

1. **Given** 사용자가 workspace A를 열고 있음, **When** "새 창 열기(New Window)" 메뉴를 선택함, **Then** 새 앱 창이 열리며 workspace 선택 화면이 표시됨
2. **Given** 새 창에서 workspace 선택 화면이 표시됨, **When** 사용자가 workspace B 디렉토리를 선택함, **Then** 새 창에 workspace B의 프로젝트 목록이 표시됨
3. **Given** 두 개의 창이 각각 다른 workspace를 열고 있음, **When** 각 창을 확인함, **Then** 각 창은 독립적으로 자신의 workspace와 프로젝트 목록을 유지함

---

### User Story 4 - View Project List within Workspace (Priority: P1)

workspace가 열리면 사용자는 하위 프로젝트 목록을 볼 수 있다. 각 프로젝트는 폴더 이름으로 식별되며, 프로젝트를 선택하면 해당 프로젝트 컨텍스트로 진입한다.

**Why this priority**: workspace를 연 후 프로젝트를 탐색하고 선택하는 것은 핵심 워크플로우이다.

**Independent Test**: workspace를 열고 프로젝트 목록이 표시되는지, 프로젝트를 선택할 수 있는지 확인한다.

**Acceptance Scenarios**:

1. **Given** workspace가 열려있고 3개의 하위 폴더가 있음, **When** 프로젝트 목록을 확인함, **Then** 3개 프로젝트가 폴더명과 함께 목록에 표시됨
2. **Given** 프로젝트 목록이 표시됨, **When** 사용자가 특정 프로젝트를 클릭함, **Then** 해당 프로젝트가 활성 프로젝트로 표시됨 (상세 콘텐츠는 이후 기능에서 정의)
3. **Given** workspace 디렉토리에 하위 폴더가 없음, **When** workspace를 열면, **Then** "프로젝트가 없습니다" 안내 메시지가 표시됨

---

### Edge Cases

- workspace 디렉토리를 선택한 뒤, 해당 디렉토리가 외부에서 삭제되면 어떻게 되는가? → workspace 선택 화면으로 fallback
- workspace 내 하위 폴더가 수백 개인 경우에도 목록이 정상적으로 표시되는가? → 목록은 스크롤 가능해야 함
- 디렉토리 선택 대화상자에서 취소를 누르면 어떻게 되는가? → 이전 상태 유지 (workspace가 없으면 선택 화면, 있으면 기존 workspace)
- 숨김 폴더(`.`으로 시작하는 폴더)는 프로젝트 목록에서 제외되어야 하는가? → 기본적으로 숨김 폴더는 제외
- 심볼릭 링크 폴더는 프로젝트로 인식되는가? → 심볼릭 링크 폴더도 프로젝트로 포함
- 파일(폴더가 아닌)은 프로젝트 목록에서 제외되는가? → 오직 폴더만 프로젝트로 인식

## Clarifications

### Session 2026-03-25

- Q: 프로젝트 선택 시 사용자가 보게 되는 화면은? → A: 프로젝트명이 활성 상태로 표시되고, 상세 콘텐츠는 이후 기능에서 정의
- Q: 같은 창에서 "Open Workspace" 재선택 시 동작은? → A: 현재 창의 workspace를 새로 선택한 것으로 교체
- Q: 최근 workspace 기록 기능 포함 여부? → A: 이번 범위는 마지막 1개 경로 복원만. 최근 기록 목록은 이후 기능으로 분리
- Q: workspace 내 폴더 추가/삭제 시 프로젝트 목록 갱신 방식? → A: 앱이 포커스를 받을 때 자동으로 목록 갱신
- Q: 프로젝트 목록 정렬 순서? → A: 알파벳 순(A→Z)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 시스템은 사용자가 "Open Workspace"를 통해 OS 네이티브 디렉토리 선택 대화상자를 열 수 있어야 하며, 선택 시 현재 창의 workspace를 교체해야 한다
- **FR-002**: 시스템은 선택된 디렉토리를 workspace로 설정하고, 직접 하위 폴더들을 프로젝트로 인식해야 한다
- **FR-003**: 시스템은 파일과 숨김 폴더(`.`으로 시작)를 프로젝트 목록에서 제외해야 한다
- **FR-004**: 시스템은 마지막으로 열었던 workspace 경로 1개만 로컬에 영구 저장해야 한다 (최근 기록 목록은 이번 범위 외)
- **FR-005**: 시스템은 앱 실행 시 저장된 workspace 경로가 유효하면 자동으로 해당 workspace를 열어야 한다
- **FR-006**: 시스템은 저장된 workspace 경로가 유효하지 않으면 workspace 선택 화면을 표시해야 한다
- **FR-007**: 시스템은 "새 창(New Window)" 기능을 제공하여, 새 창에서는 workspace 선택 화면을 표시해야 한다
- **FR-008**: 각 앱 창은 독립적인 workspace를 유지해야 한다
- **FR-009**: 시스템은 프로젝트 목록에서 프로젝트 선택 시 해당 프로젝트를 활성 상태로 표시해야 한다 (프로젝트 상세 콘텐츠는 이후 기능 범위)
- **FR-010**: workspace 디렉토리에 하위 폴더가 없을 경우, 빈 상태 안내 메시지를 표시해야 한다
- **FR-011**: 시스템은 앱 창이 포커스를 받을 때 workspace 내 프로젝트 목록을 자동으로 갱신해야 한다
- **FR-012**: 프로젝트 목록은 알파벳 순(A→Z)으로 정렬되어야 한다

### Key Entities

- **Workspace**: 사용자가 선택한 디렉토리. 하나의 workspace는 여러 project를 포함한다. 속성: 경로(path), 이름(디렉토리명)
- **Project**: workspace 내 직접 하위 폴더 하나. 속성: 이름(폴더명), 경로(path), workspace 소속

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 사용자가 디렉토리 선택 후 3초 이내에 workspace가 열리고 프로젝트 목록이 표시되어야 한다
- **SC-002**: 앱 재실행 시 1초 이내에 이전 workspace가 자동으로 복원되어야 한다
- **SC-003**: 100개 이상의 하위 폴더가 있는 workspace에서도 프로젝트 목록이 정상적으로 스크롤되며 표시되어야 한다
- **SC-004**: 새 창 열기 시 2초 이내에 workspace 선택 화면이 표시되어야 한다
- **SC-005**: 유효하지 않은 workspace 경로에 대해 에러 없이 workspace 선택 화면으로 전환되어야 한다

## Assumptions

- 데스크톱(macOS, Windows, Linux) 환경에서 실행되는 Flutter 앱을 대상으로 한다
- OS 네이티브 디렉토리 선택 대화상자를 활용할 수 있다
- workspace 경로 저장은 로컬 파일 시스템 기반의 영구 저장소(앱 설정)를 사용한다
- 프로젝트 인식은 직접 하위 폴더(1 depth)만을 대상으로 하며, 재귀적으로 탐색하지 않는다
- 심볼릭 링크 폴더도 일반 폴더와 동일하게 프로젝트로 인식한다
- macOS sandbox는 비활성화 상태. Mac App Store 배포 시 Security-Scoped Bookmark 구현 + sandbox 활성화 필요
