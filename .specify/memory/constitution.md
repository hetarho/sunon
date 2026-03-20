<!--
Sync Impact Report
- Version change: 0.0.0 → 1.0.0
- Bump rationale: MAJOR — initial constitution ratification
- Added principles:
  - I. Speed Over Stability
  - II. Spec-Driven Development
  - III. Minimal Viable Iteration
  - IV. Platform Agnostic Authoring
- Added sections:
  - Development Philosophy
  - Document Architecture
- Templates requiring updates:
  - .specify/templates/plan-template.md ✅ (Constitution Check compatible)
  - .specify/templates/spec-template.md ✅ (User story structure compatible)
  - .specify/templates/tasks-template.md ✅ (Phase structure compatible)
- Follow-up TODOs: none
-->

# Sunon Constitution

## Core Principles

### I. Speed Over Stability
이 브랜치의 목적은 원하는 제품을 빠르게 만들어보는 것이다.
- 완벽한 설계보다 빠른 실행을 우선한다
- 안정성을 위한 추가 레이어(과도한 에러 핸들링, 방어적 코딩)보다 핵심 기능 구현에 집중한다
- 리팩토링은 동작하는 결과물이 나온 뒤에 한다
- "일단 돌아가게" 만든 뒤 개선하는 방식을 택한다

### II. Spec-Driven Development
모든 개발은 구조화된 spec 문서에서 시작한다.
- `source/` 디렉토리의 계층 구조(product → entities → policies → userstories/elements → specs)를 따른다
- 의존성은 안쪽에서 바깥쪽으로만 허용된다
- spec 문서가 agent의 일관된 결과물을 보장하는 single source of truth이다
- 코드를 작성하기 전에 해당 기능의 spec이 존재해야 한다

### III. Minimal Viable Iteration
최소 단위로 빠르게 반복한다.
- 한 번에 하나의 userstory 단위로 구현한다
- 동작 확인이 가능한 최소 단위로 커밋한다
- 불필요한 추상화, 유틸리티, 헬퍼를 만들지 않는다
- 3줄 중복이 섣부른 추상화보다 낫다

### IV. Platform Agnostic Authoring
문서는 어디서든 작성할 수 있어야 한다.
- 모든 문서는 markdown 기반이다
- 특정 에디터나 플랫폼에 종속되는 기능을 사용하지 않는다
- 문서 작성이 쉽고 재미있어야 한다

## Development Philosophy

- 테스트는 핵심 경로에만 작성한다 — 커버리지 목표를 두지 않는다
- 타입 안정성보다 개발 속도를 우선한다 — `any`나 타입 단언을 두려워하지 않는다
- 외부 라이브러리를 적극 활용한다 — 직접 구현하기 전에 npm/pip을 먼저 찾는다
- 완성도 80%에서 다음으로 넘어간다 — 나머지 20%는 필요할 때 한다

## Document Architecture

sunon의 spec 문서는 클린 아키텍처의 의존성 규칙을 따른다:

| 계층 | 위치 | 관심사 | 참조 가능 |
|------|------|--------|-----------|
| product | `source/product.md` | 핵심 가치 | 없음 |
| entities | `source/entities/` | 도메인 최소 단위 | product |
| policies | `source/policies/` | 의사결정 기준 | product, entities |
| userstories | `source/userstories/` | 사용자 시나리오 | product, entities, policies |
| elements | `source/elements/` | UI 구성 요소 | product, entities, policies |
| specs | `source/specs/` | 개발 작업 단위 | 전부 |

## Governance

- 이 Constitution은 모든 개발 의사결정의 최상위 기준이다
- product.md의 mission과 principles에 위배되는 변경은 허용하지 않는다
- Constitution 수정 시 변경 사유와 영향 범위를 기록한다
- 속도를 위한 기술 부채는 허용하되, 의도적으로 기록한다

**Version**: 1.0.0 | **Ratified**: 2026-03-21 | **Last Amended**: 2026-03-21
