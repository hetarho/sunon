# Contract: Entity Markdown Format

**Version**: 1.0.0 | **Date**: 2026-04-05

## Overview

엔티티 데이터는 프로젝트의 `entities/` 디렉토리 내 개별 마크다운 파일로 저장된다. 이 문서는 파일 형식의 계약(contract)을 정의한다.

## File Location

```
{project_path}/entities/{entity_name}.md
```

## Format Specification

```markdown
# {entity_name}

## columns

| name | type | required | description |
|------|------|----------|-------------|
| {column_name} | {data_type} | {true|false} | {description_text} |
```

### Rules

1. **H1 헤딩** (`# `): 정확히 1개, 엔티티 이름
2. **H2 columns 섹션** (`## columns`): 마크다운 테이블 형식
3. **테이블 헤더**: `name | type | required | description` (고정)
4. **테이블 구분선**: `|------|------|----------|-------------|`
5. **데이터 행**: 파이프(`|`)로 구분된 4개 셀

### Allowed Data Types

| Type | Description |
|------|-------------|
| int | 정수 |
| string | 문자열 (짧은 텍스트) |
| float | 부동 소수점 |
| bool | 참/거짓 |
| datetime | 날짜/시간 |
| text | 장문 텍스트 |

### Required Field Values

- `true`: 필수 칼럼
- `false`: 선택 칼럼 (기본값)

### Unknown Sections

`## columns` 외의 `## ` 섹션은 파싱하지 않고 원본 그대로 보존한다. 이는 향후 확장성과 사용자 커스텀 섹션을 위함이다.

## Examples

### Minimal (새 엔티티 생성 직후)

```markdown
# user

## columns

| name | type | required | description |
|------|------|----------|-------------|
```

### With Columns

```markdown
# user

## columns

| name | type | required | description |
|------|------|----------|-------------|
| id | int | true | 고유 식별자 |
| email | string | true | 이메일 주소 |
| name | string | true | 사용자 이름 |
| bio | text | false | 자기소개 |
| is_active | bool | false | 활성화 여부 |
| created_at | datetime | false | 생성 일시 |
```
