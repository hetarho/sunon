# Research: Entity Page

**Feature**: 007-entity-page | **Date**: 2026-04-05

## 1. Markdown Table Parsing Strategy

**Decision**: 정규표현식 기반 직접 파싱 (ProductService parse() 패턴 확장)

**Rationale**: 기존 ProductService가 `## section` 기반 마크다운 파싱을 직접 구현하고 있으며, 마크다운 테이블은 파이프(`|`)로 구분된 단순 구조이므로 외부 라이브러리 없이 파싱 가능하다. Constitution I(Speed Over Stability)에 따라 외부 의존성 추가보다 직접 구현이 빠르다.

**Alternatives considered**:
- `markdown` 패키지: AST 기반 파싱 가능하나 테이블만 파싱하기에는 과도한 의존성
- `csv` 패키지: 파이프 구분자로 사용 가능하나 마크다운 헤더/구분선 처리 필요

## 2. Entity List ↔ Detail Navigation Pattern

**Decision**: EntityListPage 내부에서 선택된 엔티티명을 상태로 관리하여 리스트/상세를 전환

**Rationale**: ProjectDetailScreen이 sidebar index로 콘텐츠를 전환하는 패턴을 사용 중이며, Entity 내부 네비게이션도 동일 위젯 내에서 상태 기반 전환이 자연스럽다. Provider에 엔티티 네비게이션 상태를 추가하지 않아 복잡도를 최소화한다.

**Alternatives considered**:
- Navigator.push: 사이드바와의 상태 동기화가 복잡해짐
- Provider에 entity navigation state 추가: 과도한 상태 관리

## 3. Auto-Save Pattern Reuse

**Decision**: ProductPage의 500ms 디바운스 + dispose 시 강제 저장 패턴을 그대로 재사용

**Rationale**: 이미 검증된 패턴이며, 동일한 UX를 제공한다. Constitution III(Minimal Viable Iteration)에 따라 새 패턴 없이 기존 것을 재사용한다.

**Alternatives considered**:
- 명시적 Save 버튼: UX 일관성 깨짐, 사용자가 저장 잊을 위험
- 즉시 저장(디바운스 없음): 파일 I/O 과다

## 4. Entity File Initial Content

**Decision**: 새 엔티티 생성 시 엔티티명 헤딩과 빈 columns 섹션을 포함한 초기 마크다운 파일 생성

**Rationale**: 빈 파일 대신 구조가 있는 초기 파일을 생성하면 상세 페이지 진입 시 파싱 오류 없이 즉시 칼럼 추가가 가능하다.

**Alternatives considered**:
- 빈 파일 생성: 상세 페이지에서 파싱 시 예외 처리 필요
- 칼럼 없이 헤딩만: columns 섹션이 없으면 추가 로직 필요

## 5. Data Type Selection UI

**Decision**: 드롭다운(DropdownButton)으로 고정된 타입 목록에서 선택

**Rationale**: 지원 타입이 6개로 고정되어 있으므로 드롭다운이 가장 적합하다. 자유 입력 시 오타/불일치 위험이 있다.

**Alternatives considered**:
- 자유 텍스트 입력: 타입 오타 가능, 파싱 시 검증 필요
- Autocomplete: 6개 옵션에 과도한 UI 복잡도
