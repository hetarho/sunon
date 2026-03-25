# Data Model: 003-workspace-project

**Date**: 2026-03-25

## Entities

### Workspace

사용자가 선택한 디렉토리. 앱의 최상위 컨텍스트.

| Field | Type | Description |
|-------|------|-------------|
| path | String | 디렉토리 절대 경로 |
| name | String | 디렉토리명 (path에서 추출) |
| projects | List<Project> | 하위 폴더 기반 프로젝트 목록 |

**Rules**:
- path는 유효한 디렉토리 경로여야 함
- projects는 path 하위 1-depth 폴더만 포함 (숨김 폴더 제외)
- projects는 알파벳 순(A→Z) 정렬

### Project

workspace 내 직접 하위 폴더 하나.

| Field | Type | Description |
|-------|------|-------------|
| path | String | 프로젝트 디렉토리 절대 경로 |
| name | String | 폴더명 (path에서 추출) |
| isActive | bool | 현재 활성 프로젝트 여부 |

**Rules**:
- 폴더만 프로젝트로 인식 (파일 제외)
- 숨김 폴더(`.`으로 시작) 제외
- 심볼릭 링크 폴더 포함

## State Transitions

### App Launch Flow

```
App Start
  → 저장된 workspace path 확인
    → 유효함 → Workspace Loaded (프로젝트 목록 표시)
    → 유효하지 않음 / 없음 → Workspace Selection Screen
```

### Workspace Lifecycle

```
No Workspace → [Open Workspace] → Directory Picker → [선택] → Workspace Loaded
Workspace Loaded → [Open Workspace] → Directory Picker → [선택] → Workspace Replaced
Workspace Loaded → [포커스 획득] → Projects Refreshed
Workspace Loaded → [New Window] → New Window (Workspace Selection Screen)
```

## Persisted Data

- **마지막 workspace 경로**: shared_preferences에 단일 문자열로 저장
  - Key: `last_workspace_path`
  - Value: 디렉토리 절대 경로 String
