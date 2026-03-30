# Data Model: 프로젝트 추가 (Add Project)

**Date**: 2026-03-30 | **Branch**: `004-add-project`

## Entities

### Project (기존, 변경 없음)

| Field    | Type   | Description            |
|----------|--------|------------------------|
| path     | String | 프로젝트 디렉토리 절대 경로 |
| name     | String | 프로젝트 이름 (폴더명)     |
| isActive | bool   | 현재 활성 프로젝트 여부    |

### Workspace (기존, 변경 없음)

| Field    | Type           | Description             |
|----------|----------------|-------------------------|
| path     | String         | 워크스페이스 디렉토리 절대 경로 |
| name     | String         | 워크스페이스 이름 (폴더명)    |
| projects | List\<Project\> | 하위 프로젝트 목록         |

### Project Template Structure (새 개념, 모델 클래스 불필요)

프로젝트 생성 시 자동으로 만들어지는 고정 구조. 코드 내 상수로 정의.

```text
{project-name}/
├── product.md           # 빈 파일
├── policies/
│   ├── data/
│   ├── format/
│   ├── system/
│   ├── ux/
│   └── validate/
├── entities/
├── elements/
├── user stories/
└── specs/
```

**폴더 목록** (10개):
- `policies/data`
- `policies/format`
- `policies/system`
- `policies/ux`
- `policies/validate`
- `entities`
- `elements`
- `user stories`
- `specs`

**파일 목록** (1개):
- `product.md` (빈 파일)

## Validation Rules

### 프로젝트명 유효성

| Rule                  | Condition                                     | Error Message (예시)         |
|-----------------------|-----------------------------------------------|------------------------------|
| 비어있지 않음          | `name.trim().isNotEmpty`                      | "프로젝트명을 입력해 주세요"    |
| 금지 문자 없음         | `RegExp(r'[/\\:*?"<>|]').hasMatch(name)` = false | "사용할 수 없는 문자가 포함되어 있습니다" |
| 마침표 시작 금지       | `!name.startsWith('.')`                       | "마침표로 시작할 수 없습니다"   |
| 중복 없음 (case-insensitive) | 기존 프로젝트 이름과 `toLowerCase()` 비교 | "이미 존재하는 프로젝트입니다"   |
| 길이 제한              | `name.length <= 255`                          | "프로젝트명이 너무 깁니다"     |

## Relationships

- Workspace 1:N Project (기존)
- Project 1:1 Template Structure (생성 시 일회성)
