# Data Model: Entity Page

**Feature**: 007-entity-page | **Date**: 2026-04-05

## Entities

### EntityDocument

엔티티 하나를 나타내는 문서 모델. 하나의 md 파일에 대응한다.

| Field | Type | Description |
|-------|------|-------------|
| name | String | 엔티티 이름 (md 파일의 `# ` 헤딩) |
| columns | List\<EntityColumn\> | 칼럼 목록 |
| unknownSections | List\<RawSection\> | 파싱되지 않은 섹션 보존 (ProductDocument 패턴) |

**Identity**: 파일 경로 (`entities/{name}.md`)
**Uniqueness**: 엔티티명은 프로젝트 내에서 고유 (파일명 기반)

### EntityColumn

엔티티의 개별 칼럼(필드)을 나타낸다.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| name | String | '' | 칼럼 이름 |
| type | String | 'string' | 데이터 타입 (`int`, `string`, `float`, `bool`, `datetime`, `text`) |
| required | bool | false | 필수 여부 |
| description | String | '' | 칼럼 설명 |

**Validation**:
- name: 비어있지 않아야 함
- type: 허용된 타입 목록 중 하나

### EntitySummary

엔티티 리스트 표시를 위한 경량 모델.

| Field | Type | Description |
|-------|------|-------------|
| name | String | 엔티티 이름 (파일명에서 `.md` 제거) |
| filePath | String | 절대 파일 경로 |

## Relationships

```
Project 1 ──── * EntityDocument (entities/ 디렉토리 내 md 파일)
EntityDocument 1 ──── * EntityColumn (## columns 테이블 행)
```

## Markdown ↔ Model Mapping

### Serialization (EntityDocument → Markdown)

```markdown
# {entity.name}

## columns

| name | type | required | description |
|------|------|----------|-------------|
| {col.name} | {col.type} | {col.required} | {col.description} |
...

{unknownSections preserved as-is}
```

### Parsing (Markdown → EntityDocument)

1. `# ` (h1) → `entity.name`
2. `## columns` 이후 마크다운 테이블 → `entity.columns`
   - 첫 번째 행: 헤더 (skip)
   - 두 번째 행: 구분선 `|---|` (skip)
   - 이후 행: 데이터 → `EntityColumn`
3. `## *` (알 수 없는 h2 섹션) → `unknownSections` (보존)

## State Transitions

EntityListPage/EntityDetailPage 간 네비게이션:

```
[Entity List] ──(엔티티 클릭)──→ [Entity Detail]
[Entity Detail] ──(뒤로가기)──→ [Entity List]
[Entity List] ──(Add Entity)──→ [Modal] ──(Create)──→ [Entity List + 새 항목]
[Entity List] ──(Delete)──→ [Confirm Dialog] ──(확인)──→ [Entity List - 삭제됨]
```
