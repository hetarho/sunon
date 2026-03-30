# Data Model: 프로젝트 상세 페이지 (Project Detail Page)

**Date**: 2026-03-30 | **Branch**: `005-project-detail-page`

## Entities

### Project (기존, 변경 없음)

| Field    | Type   | Description            |
|----------|--------|------------------------|
| path     | String | 프로젝트 디렉토리 절대 경로 |
| name     | String | 프로젝트 이름 (폴더명)     |
| isActive | bool   | 현재 활성 프로젝트 여부    |

### Sidebar Menu (새 개념, 별도 모델 클래스 불필요)

사이드바에 표시되는 고정 메뉴 목록. 코드 내 상수 리스트로 정의.

| Index | Label        | Description              |
|-------|--------------|--------------------------|
| 0     | Product      | 핵심 가치 정의            |
| 1     | Entities     | 도메인 최소 단위          |
| 2     | Policies     | 의사결정 기준             |
| 3     | User Stories | 사용자 시나리오           |
| 4     | Elements     | UI 구성 요소              |
| 5     | Specs        | 개발 작업 단위            |

### Navigation State (WorkspaceProvider 확장)

| Field            | Type     | Description                    |
|------------------|----------|--------------------------------|
| isInProjectView  | bool     | 프로젝트 상세 뷰 진입 여부      |

## State Transitions

```text
[프로젝트 목록] → (프로젝트 탭) → [프로젝트 상세 뷰, Product 메뉴 선택]
[프로젝트 상세 뷰] → (메뉴 클릭) → [같은 뷰, 선택된 메뉴 변경]
[프로젝트 상세 뷰] → (뒤로가기) → [프로젝트 목록]
```
