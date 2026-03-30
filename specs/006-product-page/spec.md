# Feature Specification: Product 페이지 (Product Page)

**Feature Branch**: `006-product-page`
**Created**: 2026-03-30
**Status**: Draft
**Input**: User description: "product 페이지를 만들자. source 디렉토리의 예시를 반영하고, 로컬 product.md 파일과 실시간 동기화. 프로덕트를 왜 만드는지에 대한 근본적인 핵심 내용을 담아야 함."

## Design Rationale

Product 페이지는 sunon 문서 계층의 최상위 레이어(domain)를 정의한다. Clean Architecture의 의존성 규칙을 기획에 적용하여, **하위 계층(entities, policies, user stories...)보다 덜 바뀌고, 이 레이어가 바뀌면 하위가 영향받지만 하위가 바뀌어도 이 레이어는 영향받지 않는** 필드만 포함한다.

**필드 구성**: Name + Mission + Principles
- **Name**: 프로덕트 정체성. 변경 시 프로젝트 폴더명도 함께 rename.
- **Mission**: 프로덕트의 존재 이유. 문제와 해법을 함축 (예: "spec을 구조화해서 agent의 일관성을 높힌다")
- **Principles**: 만드는 방식의 철학. 프로덕트가 피벗해도 유지되는 가치

**제외된 필드**:
- Problem: Mission에 내포됨. Problem → Mission → 하위로 이어지는 구조에서 Problem은 Mission의 input이지 같은 레벨이 아님
- Vision: 하위 계층에 대한 구속력이 약함 (비전이 바뀌어도 entities/policies가 안 바뀔 수 있음). 전략/로드맵 관심사

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Product 정보 조회 및 편집 (Priority: P1)

사용자가 프로젝트 상세 뷰에서 "Product" 메뉴를 선택하면, 해당 프로젝트의 `product.md` 파일 내용이 구조화된 폼으로 표시된다. 폼은 다음 필드를 포함한다:

1. **Product Name** - 프로덕트 이름 (한 줄 텍스트, 프로젝트 폴더명과 동기화)
2. **Mission** - 프로덕트의 미션/존재 이유 (여러 줄 텍스트)
3. **Principles** - 프로덕트를 만들 때 지키는 핵심 원칙들 (목록)

사용자가 필드를 수정하면 변경 내용이 디바운스 후 자동으로 `product.md` 파일에 저장된다.

**Why this priority**: Product 정보를 볼 수 있어야 편집이 의미가 있다. 프로덕트의 핵심 가치를 정의하는 것이 sunon의 문서 계층에서 가장 상위에 있는 근본적인 행위이다.

**Independent Test**: 프로젝트 상세 뷰에서 Product 메뉴 선택 -> `product.md` 내용이 각 필드별로 표시되는지 확인

**Acceptance Scenarios**:

1. **Given** 프로젝트에 `product.md` 파일이 존재하고 내용이 채워져 있는 상태, **When** Product 메뉴를 선택, **Then** 파일 내용이 구조화된 폼에 각 필드별로 파싱되어 표시된다
2. **Given** 프로젝트에 `product.md` 파일이 비어 있는 상태(새 프로젝트), **When** Product 메뉴를 선택, **Then** 빈 폼이 표시되고 각 필드에 힌트 텍스트(placeholder)가 보인다. Product Name은 현재 프로젝트 폴더명으로 초기화된다
3. **Given** Product 폼이 표시된 상태, **When** 사용자가 Mission 필드를 수정, **Then** 디바운스 후 자동으로 `product.md` 파일에 저장된다

---

### User Story 2 - Product Name 변경 시 폴더명 Rename (Priority: P1)

사용자가 Product Name 필드를 수정하면, 프로젝트 폴더명이 새 이름으로 rename된다. Product Name과 프로젝트 폴더명은 항상 동기화 상태를 유지한다.

**Why this priority**: Product Name은 프로젝트 폴더의 정체성이다. 이름이 바뀌면 파일 시스템에도 즉시 반영되어야 일관성이 유지된다.

**Independent Test**: Product Name 수정 -> 디바운스 후 프로젝트 폴더명이 변경되었는지 확인

**Acceptance Scenarios**:

1. **Given** Product Name이 "sunon"인 상태, **When** "sunon-v2"로 수정하고 디바운스 대기, **Then** 프로젝트 폴더가 "sunon-v2"로 rename되고, 앱 내 프로젝트 경로도 업데이트된다
2. **Given** Product Name을 변경하려는 상태, **When** 새 이름이 이미 존재하는 폴더명과 겹치면, **Then** rename하지 않고 오류 메시지를 표시한다
3. **Given** Product Name을 변경하려는 상태, **When** 새 이름에 파일 시스템에서 사용 불가한 문자가 포함되면, **Then** rename하지 않고 오류 메시지를 표시한다
4. **Given** 폴더 rename에 성공한 상태, **When** 뒤로가기로 프로젝트 목록으로 돌아가면, **Then** 변경된 이름으로 프로젝트가 표시된다

---

### User Story 3 - product.md 파일 포맷 호환 (Priority: P2)

저장된 `product.md` 파일은 `source/product.md` 예시와 동일한 마크다운 구조를 따른다. 기존에 수동으로 작성된 `product.md` 파일도 올바르게 파싱하여 폼에 표시할 수 있다.

**Why this priority**: sunon 생태계에서 `product.md`는 사람과 에이전트 모두가 읽는 문서이다. 기존 예시 포맷과의 호환이 보장되어야 한다.

**Independent Test**: `source/product.md` 예시 파일을 프로젝트 폴더에 복사 -> Product 페이지에서 올바르게 파싱되는지 확인

**Acceptance Scenarios**:

1. **Given** `source/product.md`와 동일한 형식의 파일이 프로젝트에 있는 상태, **When** Product 페이지를 열면, **Then** 각 섹션(name, mission, principles)이 올바르게 파싱되어 해당 필드에 표시된다
2. **Given** Product 폼에서 모든 필드를 채우고 자동 저장된 상태, **When** 저장된 `product.md`를 텍스트 에디터로 열면, **Then** 사람이 읽기 쉬운 마크다운 형식이며, 기존 예시와 일관된 구조이다

---

### User Story 4 - Principles 목록 관리 (Priority: P2)

사용자가 Principles 섹션에서 원칙을 추가, 수정, 삭제할 수 있다. 각 원칙은 한 줄의 텍스트이며, 마크다운에서는 `- ` 접두사 불릿 리스트로 저장된다. 목록 변경도 디바운스 후 자동 저장된다.

**Why this priority**: Principles는 목록 형태의 데이터로, 단순 텍스트 입력과 다른 UX가 필요하다. 목록 아이템의 추가/삭제가 직관적이어야 한다.

**Independent Test**: Principles 영역에서 원칙 추가/삭제/수정 -> 자동 저장 후 파일에 불릿 리스트로 저장되는지 확인

**Acceptance Scenarios**:

1. **Given** Product 폼의 Principles 섹션이 표시된 상태, **When** "+" 버튼을 누르면, **Then** 새로운 빈 원칙 입력 필드가 추가된다
2. **Given** Principles에 원칙이 3개 있는 상태, **When** 두 번째 원칙의 삭제 버튼을 누르면, **Then** 해당 원칙이 목록에서 제거되고 나머지가 순서를 유지한다
3. **Given** Principles를 수정 후 자동 저장된 상태, **When** `product.md`를 확인하면, **Then** `## principles` 아래에 `- ` 접두사로 각 원칙이 기록되어 있다

---

### Edge Cases

- `product.md` 파일이 존재하지 않는 경우 (외부에서 삭제): 빈 폼을 표시하고, Product Name은 폴더명으로 초기화. 수정 시 파일 새로 생성
- `product.md`에 인식할 수 없는 섹션이 있는 경우: 알 수 없는 섹션은 무시하되 저장 시에도 유실하지 않음
- 자동 저장 중 오류 발생 (디스크 풀, 권한 없음): 오류 메시지를 사용자에게 표시하고 폼 내용 유지
- 폴더 rename 실패 (권한, 이름 충돌, 사용 불가 문자): 오류 메시지 표시, 이전 이름 유지
- Product Name을 빈 문자열로 변경 시도: rename하지 않음, 폴더명은 빈 문자열 불가
- 빈 Principle 항목: 빈 줄은 저장 시 제외 (빈 `- ` 불릿 방지)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Product 메뉴 선택 시 프로젝트의 `product.md` 파일을 읽어 구조화된 폼으로 표시해야 한다
- **FR-002**: 폼은 다음 필드를 포함해야 한다: Product Name, Mission, Principles
- **FR-003**: 각 텍스트 필드는 인라인 편집이 가능해야 한다
- **FR-004**: Principles는 목록 형태로, 항목 추가/삭제가 가능해야 한다
- **FR-005**: 폼 수정 시 디바운스 후 자동으로 `product.md` 파일에 마크다운 형식으로 저장해야 한다
- **FR-006**: 자동 저장 실패 시 사용자에게 오류 피드백을 표시해야 한다
- **FR-007**: `product.md` 파일이 없으면 빈 폼을 표시하고, Product Name은 폴더명으로 초기화하며, 수정 시 새로 생성해야 한다
- **FR-008**: 저장되는 마크다운 포맷은 `source/product.md` 예시와 호환되어야 한다
- **FR-009**: 빈 필드가 있어도 해당 섹션 헤딩은 유지한 채 저장해야 한다
- **FR-010**: `product.md`에 인식할 수 없는 기존 섹션이 있으면 저장 시 유실하지 않아야 한다
- **FR-011**: 빈 Principle 항목은 저장 시 제외해야 한다
- **FR-012**: Product Name 변경 시 프로젝트 폴더명을 rename해야 한다
- **FR-013**: 폴더 rename 실패 시 (이름 충돌, 사용 불가 문자, 빈 문자열) 오류를 표시하고 이전 이름을 유지해야 한다
- **FR-014**: 폴더 rename 성공 시 앱 내 프로젝트 경로가 업데이트되어야 한다

### Key Entities

- **Product Document**: 프로젝트의 `product.md` 파일. 프로덕트의 이름, 미션, 원칙을 마크다운 형식으로 포함한다
- **Product Form Field**: UI 폼의 각 입력 필드. 텍스트 필드(name, mission)와 리스트 필드(principles)로 구분된다

## Markdown Format Definition

저장되는 `product.md`의 형식:

```
# product
{product name}

## mission
{mission statement}

## principles
- {principle 1}
- {principle 2}
- ...
```

이 형식은 `source/product.md` 예시와 동일하다.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Product 메뉴 선택 후 폼이 1초 이내에 표시된다
- **SC-002**: 필드 수정 후 자동 저장이 디바운스 + 쓰기 시간 포함 1초 이내에 완료된다
- **SC-003**: 저장된 `product.md`를 다시 열었을 때 모든 필드가 저장 시점과 동일하게 표시된다 (라운드트립 무손실)
- **SC-004**: `source/product.md` 예시 형식의 파일을 올바르게 파싱하여 표시한다
- **SC-005**: Product Name 변경 시 폴더 rename이 1초 이내에 완료된다

## Assumptions

- `product.md`는 프로젝트 루트 디렉토리에 위치한다 (프로젝트 생성 시 템플릿에 포함)
- 마크다운 파싱은 `##` 레벨 헤딩 기준으로 섹션을 구분한다
- `# product` 다음 줄의 텍스트가 프로덕트 이름이다
- 폼 UI는 기존 프로젝트 상세 뷰의 우측 콘텐츠 영역(Product 메뉴의 TBD 플레이스홀더를 대체)에 표시한다
- 저장은 디바운스 기반 자동 저장이며, 별도 Save 버튼은 없다
- Product Name 변경 시 폴더 rename은 디바운스 저장 시점에 이전 이름과 비교하여 다르면 수행한다
- 폴더 rename은 워크스페이스 내 같은 레벨에서 수행된다 (부모 디렉토리 동일)
- rename 후 WorkspaceProvider의 프로젝트 경로를 업데이트해야 한다

## Clarifications

### Session 2026-03-30

- Q: 미저장 변경사항이 있을 때 다른 메뉴로 이동하면? -> A: 디바운스 기반 자동 저장. 미저장 상태 자체가 발생하지 않음.
- Q: Problem/Vision 필드가 필요한가? -> A: 제거. Mission에 문제+해법이 내포됨. Vision은 하위 계층에 대한 구속력이 약해 product 레이어 자격 미달.
- Q: Product Name과 폴더명 관계? -> A: Product Name 변경 시 프로젝트 폴더를 rename. 양방향 동기화.
