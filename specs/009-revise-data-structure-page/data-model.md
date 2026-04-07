# Data Model: 데이터 구조 페이지 개편

**Date**: 2026-04-07 | **Branch**: `009-revise-data-structure-page`

## Entities

### DataItem (데이터 항목)

서비스에서 다루는 데이터의 단위. 하나의 md 파일에 대응.

| Field | Description |
|-------|-------------|
| name | 데이터 항목 이름 (파일명과 동일, H1 헤딩) |
| attributes | 속성 목록 (순서 보존) |
| unknownSections | 파싱 대상이 아닌 `## ` 섹션들 (원본 보존) |

**Identity**: name (프로젝트 내 고유, 대소문자 무시)
**Lifecycle**: 생성 → 속성 편집 (반복) → 삭제

### Attribute (속성)

데이터 항목을 구성하는 정보 단위.

| Field | Description |
|-------|-------------|
| name | 속성명 (자유 텍스트) |
| info | 속성 정보 (자연어 설명, 자유 텍스트) |

**Identity**: 순서 기반 (이름 중복 가능)
**Lifecycle**: DataItem 내에서 추가/편집/삭제

### DataItemSummary (목록용)

| Field | Description |
|-------|-------------|
| name | 데이터 항목 이름 |
| filePath | md 파일 경로 |

## 제거되는 엔티티 (007 대비)

- `EntityColumn` → `Attribute`로 대체 (5필드 → 2필드)
- `LocalType` → 제거
- `LocalEnum` → 제거
- `supportedColumnTypes` 상수 → 제거

## 관계

```
DataItem 1 ──── * Attribute
DataItem 1 ──── * RawSection (unknownSections)
```

## 저장소

- 경로: `{project_path}/data/{item_name}.md`
- 형식: Markdown (계약 문서 참조)
- 디렉토리 자동 생성: `data/` 없으면 생성
