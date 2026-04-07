# Research: 데이터 구조 페이지 개편

**Date**: 2026-04-07 | **Branch**: `009-revise-data-structure-page`

## 1. 기존 코드 구조 분석

### Decision: 기존 4개 파일 인플레이스 수정

**Rationale**: 신규 파일을 만들면 import 변경이 연쇄적으로 필요해지고, 기존 파일 삭제도 해야 한다. 기존 파일명은 유지하되 내부 구조만 변경하는 것이 가장 빠르다.

**Alternatives considered**:
- 파일명까지 변경 (entity → data_item): import 경로 변경이 모든 참조 파일에 전파됨. 비용 대비 이점 없음.
- 새 파일 생성 + 기존 파일 삭제: 동일한 이유로 불필요.

### 수정 대상 파일 및 범위

| File | 변경 범위 |
|------|----------|
| `models/entity_document.dart` | `EntityColumn` → `Attribute` (name, info 2필드만). `LocalType`, `LocalEnum`, `supportedColumnTypes` 제거. `EntityDocument` → name + attributes + unknownSections |
| `services/entity_service.dart` | 디렉토리 `entities/` → `data/`. 파싱/직렬화를 2칸 테이블로 변경. `listTypes`, `createType`, `deleteType` 제거 |
| `screens/entity_list_page.dart` | Types 섹션 제거. 용어 변경 (엔티티 → 데이터 항목). UI 텍스트 한글화 |
| `screens/entity_detail_page.dart` | 5칸 테이블 → 2칸 테이블. Local Type/Enum UI 제거. 드롭다운/체크박스 제거 |
| `screens/project_detail_screen.dart` | 사이드바 메뉴명 `Entities` → `데이터 구조` |

## 2. 마크다운 형식 변경

### Decision: `## columns` (5칸) → `## 속성` (2칸)

**Rationale**: 기획자가 자연어로 속성 정보를 기술하도록 하므로, type/isList/required 칼럼이 불필요하다. 속성명과 속성 정보 2칸이면 충분하다.

**New format**:
```
# {item_name}

## 속성

| 속성명 | 속성 정보 |
|--------|----------|
| {name} | {natural language description} |
```

**Alternatives considered**:
- 3칸 (속성명 | 속성 정보 | 비고): 비고 칸이 거의 사용되지 않을 것으로 판단. 단순함 우선.
- YAML frontmatter + 본문: markdown 테이블이 더 직관적이고 기획자가 외부 편집기에서도 쉽게 읽을 수 있음.

## 3. 마이그레이션 전략

### Decision: 마이그레이션 없음

**Rationale**: 사용자 결정에 따라 기존 `entities/` 디렉토리는 그대로 두고 새 프로젝트만 `data/` 사용. 이 제품은 빠른 프로토타이핑 단계이므로 마이그레이션 코드 작성은 과도함.

**Alternatives considered**:
- 자동 마이그레이션: 복잡도 증가 (구 형식 파싱 + 새 형식 변환 + 디렉토리 이동). Speed Over Stability 원칙에 어긋남.
- 프롬프트 마이그레이션: 사용자 경험은 좋지만 구현 비용이 여전히 높음.

## 4. 검증 유효성 메시지

### Decision: 기존 에러 메시지 한글 유지, 용어만 변경

**Rationale**: 이미 한글 메시지가 잘 작성되어 있으므로 "엔티티" → "데이터 항목"으로만 치환.

| 기존 메시지 | 변경 후 |
|------------|--------|
| 엔티티 이름을 입력해주세요 | 데이터 항목 이름을 입력해주세요 |
| 이미 존재하는 엔티티 이름입니다 | 이미 존재하는 이름입니다 |
| 사용할 수 없는 문자가 포함되어 있습니다 | (유지) |
