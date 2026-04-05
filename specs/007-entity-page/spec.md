# Feature Specification: Entity Page

**Feature Branch**: `007-entity-page`
**Created**: 2026-04-05
**Status**: Draft
**Input**: User description: "엔티티 페이지를 만들자. 엔티티는 디비처럼 타이틀과 데이터 형식 등을 지정할 수 있게 만들어야 한다. 엔티티 리스트 페이지에서 엔티티 리스트를 불러오고, Add Entity 버튼으로 엔티티를 추가할 수 있다. 엔티티 추가 버튼을 누르면 엔티티명 입력 모달이 뜨고, create하면 로컬 entities 디렉토리 하위에 해당 엔티티명의 md 파일이 생성된다. 해당 페이지에서 엔티티의 칼럼과 속성을 추가하면 md 파일 형식으로 저장되며, 화면에는 해당 md 파일을 파싱해서 보기 좋게 보여주는 상세페이지도 제공한다."

## User Scenarios & Testing

### User Story 1 - View Entity List (Priority: P1)

사용자가 프로젝트 상세 페이지의 사이드바에서 "Entities" 메뉴를 클릭하면, 해당 프로젝트의 `entities/` 디렉토리에 저장된 엔티티 목록이 표시된다. 각 엔티티는 파일명(확장자 제외)을 기반으로 이름이 표시된다.

**Why this priority**: 엔티티 목록을 확인하는 것이 모든 엔티티 관련 기능의 진입점이므로 가장 기본적인 기능이다.

**Independent Test**: Entities 메뉴 클릭 후 entities 디렉토리의 md 파일 목록이 화면에 표시되는지 확인하여 독립적으로 테스트할 수 있다.

**Acceptance Scenarios**:

1. **Given** 프로젝트에 entities 디렉토리가 존재하고 md 파일이 있을 때, **When** 사이드바에서 Entities 메뉴를 클릭하면, **Then** 각 md 파일에 해당하는 엔티티 이름이 리스트로 표시된다.
2. **Given** 프로젝트에 entities 디렉토리가 비어있을 때, **When** 사이드바에서 Entities 메뉴를 클릭하면, **Then** 빈 상태 안내 메시지와 Add Entity 버튼이 표시된다.
3. **Given** 엔티티 리스트가 표시된 상태에서, **When** 특정 엔티티를 클릭하면, **Then** 해당 엔티티의 상세 페이지로 이동한다.

---

### User Story 2 - Add New Entity (Priority: P1)

사용자가 엔티티 리스트 페이지에서 "Add Entity" 버튼을 클릭하면 엔티티명 입력 모달이 나타난다. 엔티티명을 입력하고 Create 버튼을 누르면 `entities/` 디렉토리 하위에 해당 이름의 md 파일이 생성되고, 엔티티 리스트가 갱신된다.

**Why this priority**: 엔티티 생성은 데이터 모델링의 핵심 진입점이며, 이후 칼럼 추가 등 모든 기능의 전제 조건이다.

**Independent Test**: Add Entity 버튼 → 모달에서 이름 입력 → Create 클릭 후, entities 디렉토리에 md 파일이 생성되고 리스트에 새 엔티티가 나타나는지 확인한다.

**Acceptance Scenarios**:

1. **Given** 엔티티 리스트 페이지에서, **When** Add Entity 버튼을 클릭하면, **Then** 엔티티명을 입력할 수 있는 모달 다이얼로그가 표시된다.
2. **Given** 모달에서 유효한 엔티티명을 입력한 상태에서, **When** Create 버튼을 클릭하면, **Then** `entities/{entity_name}.md` 파일이 생성되고 리스트에 새 엔티티가 추가된다.
3. **Given** 모달에서 이미 존재하는 엔티티명을 입력한 상태에서, **When** Create 버튼을 클릭하면, **Then** 중복 이름 오류 메시지가 표시되고 파일은 생성되지 않는다.
4. **Given** 모달에서 빈 이름으로 Create를 시도하면, **Then** 이름 필수 입력 안내가 표시되고 생성되지 않는다.
5. **Given** 모달이 표시된 상태에서, **When** Cancel 또는 모달 외부를 클릭하면, **Then** 모달이 닫히고 아무 변경도 발생하지 않는다.

---

### User Story 3 - Entity Detail Page with Column Management (Priority: P1)

사용자가 엔티티 상세 페이지에서 칼럼(필드)을 추가, 편집, 삭제할 수 있다. 각 칼럼에는 이름과 데이터 타입을 지정할 수 있으며, 변경 내용은 자동으로 md 파일에 저장된다. 화면에는 md 파일을 파싱하여 테이블 형태로 보기 좋게 표시한다.

**Why this priority**: 엔티티의 핵심 가치는 칼럼과 속성을 정의하는 것이므로 리스트/생성과 동일한 우선순위로 구현이 필요하다.

**Independent Test**: 엔티티 상세 페이지에서 칼럼을 추가하고, md 파일에 올바르게 저장되는지 확인하며, 화면에 테이블 형태로 표시되는지 검증한다.

**Acceptance Scenarios**:

1. **Given** 엔티티 상세 페이지에 진입했을 때, **When** 해당 엔티티의 md 파일에 칼럼 정보가 있으면, **Then** 칼럼 목록이 테이블 형태로 보기 좋게 표시된다.
2. **Given** 엔티티 상세 페이지에서, **When** Add Column 버튼을 클릭하면, **Then** 새 칼럼 행이 추가되어 이름과 데이터 타입을 입력할 수 있다.
3. **Given** 칼럼 정보를 입력 또는 수정한 상태에서, **When** 일정 시간이 경과하면(디바운스), **Then** 변경 내용이 자동으로 md 파일에 저장된다.
4. **Given** 칼럼이 존재하는 상태에서, **When** 삭제 버튼을 클릭하면, **Then** 해당 칼럼이 제거되고 md 파일이 갱신된다.
5. **Given** md 파일이 외부에서 수정된 경우에도, **When** 상세 페이지를 열면, **Then** md 파일을 파싱하여 최신 내용을 표시한다.
6. **Given** 엔티티 상세 페이지에서, **When** 뒤로가기 버튼을 클릭하면, **Then** 엔티티 리스트 페이지로 돌아간다.

---

### User Story 4 - Delete Entity (Priority: P2)

사용자가 엔티티 리스트에서 특정 엔티티를 삭제할 수 있다. 삭제 시 확인 다이얼로그가 표시되며, 확인하면 해당 md 파일이 삭제되고 리스트가 갱신된다.

**Why this priority**: 잘못 생성한 엔티티를 정리할 수 있어야 하지만, 생성/조회/편집보다는 사용 빈도가 낮다.

**Independent Test**: 엔티티 리스트에서 삭제 버튼 클릭 → 확인 → md 파일 삭제 및 리스트 갱신을 확인한다.

**Acceptance Scenarios**:

1. **Given** 엔티티 리스트에서, **When** 특정 엔티티의 삭제 버튼을 클릭하면, **Then** 삭제 확인 다이얼로그가 표시된다.
2. **Given** 삭제 확인 다이얼로그에서, **When** 확인을 클릭하면, **Then** 해당 `entities/{entity_name}.md` 파일이 삭제되고 리스트에서 제거된다.
3. **Given** 삭제 확인 다이얼로그에서, **When** 취소를 클릭하면, **Then** 다이얼로그가 닫히고 아무 변경도 발생하지 않는다.

---

### Edge Cases

- 엔티티명에 파일 시스템에서 허용되지 않는 특수문자가 포함된 경우 유효성 검사에서 거부한다.
- entities 디렉토리가 존재하지 않는 프로젝트(이전 버전에서 생성된 프로젝트)에서는 자동으로 디렉토리를 생성한다.
- md 파일이 예상과 다른 형식으로 작성된 경우 파싱 가능한 부분만 표시하고 나머지는 보존한다.
- 엔티티명에 공백이 포함된 경우 파일명에서 공백을 허용한다(OS 지원 범위 내).

## Requirements

### Functional Requirements

- **FR-001**: 시스템은 프로젝트의 `entities/` 디렉토리를 스캔하여 `.md` 파일 목록을 엔티티 리스트로 표시해야 한다.
- **FR-002**: 시스템은 "Add Entity" 버튼을 제공하여 새 엔티티 생성 모달을 열 수 있어야 한다.
- **FR-003**: 시스템은 모달에서 입력된 엔티티명으로 `entities/{entity_name}.md` 파일을 생성해야 한다.
- **FR-004**: 시스템은 중복 엔티티명 및 빈 이름에 대한 유효성 검사를 수행해야 한다.
- **FR-005**: 시스템은 엔티티 상세 페이지에서 칼럼(이름, 데이터 타입, 배열 여부, 필수 여부, 설명)을 추가, 편집, 삭제할 수 있어야 한다.
- **FR-006**: 시스템은 칼럼 변경 시 디바운스 방식으로 자동 저장하여 md 파일에 반영해야 한다.
- **FR-007**: 시스템은 md 파일을 파싱하여 칼럼 정보를 테이블 형태로 표시해야 한다.
- **FR-008**: 시스템은 entities 디렉토리가 없는 경우 자동으로 생성해야 한다.
- **FR-009**: 시스템은 엔티티명에 포함된 파일 시스템 비허용 문자를 검증하고 거부해야 한다.
- **FR-010**: 시스템은 엔티티 리스트에서 삭제 기능을 제공하며, 확인 다이얼로그 후 해당 md 파일을 삭제해야 한다.

### Markdown Format Definition

엔티티 md 파일은 다음 구조를 따른다:

```
# {entity_name}

## columns

| name | type | isList | required | description |
|------|------|--------|----------|-------------|
| id | int | false | true | 고유 식별자 |
| title | string | false | true | 제목 |
| tags | string | true | false | 태그 목록 |
| created_at | datetime | false | false | 생성 일시 |
```

- 최상위 `# ` 헤딩은 엔티티 이름을 나타낸다.
- `## columns` 섹션은 마크다운 테이블 형식으로 칼럼을 정의한다.
- 테이블 헤더는 `name`, `type`, `isList`, `required`, `description`으로 고정한다.
- 지원하는 기본 데이터 타입: `int`, `string`, `float`, `bool`, `datetime`, `text`
- 동일 프로젝트 내 다른 엔티티 및 커스텀 타입도 칼럼의 타입으로 사용할 수 있다. 드롭다운에서 기본 타입, 엔티티, 커스텀 타입을 구분선(Divider)으로 구분하여 표시한다.
- 커스텀 타입은 엔티티와 동일한 구조(이름 + 칼럼 목록)를 가지며, `types/` 디렉토리에 저장한다. 엔티티 자체는 아니지만 칼럼의 하위 타입으로 사용되는 복합 타입이다.
- `isList` 값은 `true` 또는 `false`이며, 기본값은 `false`이다. `true`이면 해당 타입의 배열을 나타낸다.
- `required` 값은 `true` 또는 `false`이며, 기본값은 `false`이다.
- `description`은 칼럼에 대한 간단한 설명이며, 비워둘 수 있다.

### Key Entities

- **Entity**: 데이터 모델을 나타내는 단위. 이름을 가지며 여러 칼럼을 포함한다. 각 엔티티는 하나의 md 파일에 대응한다.
- **Column**: 엔티티를 구성하는 필드. 이름(name), 데이터 타입(type), 배열 여부(isList), 필수 여부(required), 설명(description)을 속성으로 가진다.

## Clarifications

### Session 2026-04-05

- Q: 엔티티 삭제 기능 포함 여부 → A: 삭제 포함 (리스트에서 삭제 버튼 + 확인 다이얼로그, md 파일 삭제)
- Q: 칼럼 속성 범위 (name/type 외 추가 속성) → A: name, type, required, description 4개 속성 포함
- Q: 엔티티 상세 페이지 표시 방식 → A: 메인 영역 교체 (리스트 → 상세, 뒤로가기 버튼으로 리스트 복귀)

## Success Criteria

### Measurable Outcomes

- **SC-001**: 사용자가 Entities 메뉴 클릭 후 1초 이내에 엔티티 리스트를 확인할 수 있다.
- **SC-002**: 사용자가 Add Entity 모달에서 이름 입력 후 Create까지 10초 이내에 새 엔티티를 생성할 수 있다.
- **SC-003**: 칼럼 추가/편집/삭제 후 자동 저장이 완료되어 md 파일에 반영된다.
- **SC-004**: md 파일을 외부 편집기에서 열었을 때 사람이 읽을 수 있는 구조화된 마크다운 형식이 유지된다.
- **SC-005**: 엔티티 상세 페이지에서 칼럼 정보가 정렬된 테이블 형태로 표시되어 한눈에 데이터 구조를 파악할 수 있다.

## Assumptions

- 프로젝트 템플릿에 이미 `entities/` 디렉토리가 포함되어 있다(004-add-project에서 생성).
- 기존 Product 페이지와 동일한 디바운스 자동 저장 패턴(500ms)을 따른다.
- 엔티티명은 파일명으로 사용되므로 영문, 숫자, 밑줄, 하이픈, 공백을 허용한다.
- 데이터 타입은 기본 타입(`int`, `string`, `float`, `bool`, `datetime`, `text`)과 프로젝트 내 엔티티 타입을 모두 지원한다.
- 사이드바의 Entities 메뉴(index 1)는 이미 존재하며, 현재 플레이스홀더 텍스트를 실제 엔티티 페이지로 교체한다.
