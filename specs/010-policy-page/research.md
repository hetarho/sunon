# Research: Policy 페이지

## Decision 1: 마크다운 파싱 전략

**Decision**: Entity 패턴과 동일하게 단순 문자열 파싱. `# ` 헤딩만 분리하고 나머지는 통째로 본문.

**Rationale**: Policy는 구조화된 섹션(속성 테이블 등)이 없으므로 Entity보다 파싱이 단순하다. 첫 `# ` 라인을 제목으로, 나머지 전체를 본문 텍스트로 취급하면 된다.

**Alternatives considered**:
- markdown 파서 라이브러리 사용 → 과잉. 자유 형식이므로 AST 파싱 불필요
- YAML frontmatter 사용 → 기획자에게 불필요한 복잡성 추가

## Decision 2: 본문 에디터 위젯

**Decision**: Flutter `TextField`(multiline) 사용. `maxLines: null`, `expands: true`.

**Rationale**: Product 페이지가 이미 multiline TextField로 자동 저장 패턴을 구현 중. 동일한 패턴 재사용. 마크다운 프리뷰나 리치 에디터는 스펙에서 명시적으로 제외됨.

**Alternatives considered**:
- CodeEditor 위젯 (구문 하이라이팅) → 기획자에게 불필요, 의존성 추가
- 마크다운 실시간 프리뷰 → 스펙에서 제외 결정

## Decision 3: 파일명 리네임 전략

**Decision**: 제목 변경 시 디바운스 저장과 동일 타이밍에 파일 리네임. 기존 파일 삭제 후 새 파일 생성.

**Rationale**: Entity의 이름 변경은 없었지만(목록에서만 삭제/생성), Policy는 상세 페이지에서 제목 변경 → 파일명 변경이 필요. `dart:io`의 `File.rename()`으로 원자적 리네임 가능.

**Alternatives considered**:
- 리네임 없이 내부 ID 사용 → 마크다운 파일 기반이므로 파일명=이름이 자연스러움
- 별도 리네임 버튼 → 자동 저장 패턴과 일관성 저하

## Decision 4: RawSection 재사용

**Decision**: Policy는 `RawSection` (unknown section 보존)을 사용하지 않음.

**Rationale**: Entity는 `## 속성` 외의 사용자 정의 섹션을 보존해야 했지만, Policy는 `# 제목` 이후 전체가 자유 형식 본문이므로 별도 섹션 파싱/보존이 불필요. 본문 전체를 하나의 문자열로 관리.

**Alternatives considered**:
- RawSection 유지 → 불필요한 복잡성. 본문 자체가 "raw" 전체
