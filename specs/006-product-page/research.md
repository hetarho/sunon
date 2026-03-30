# Research: Product 페이지 (Product Page)

**Date**: 2026-03-30 | **Branch**: `006-product-page`

## Findings

### 1. Markdown 파싱/직렬화 전략

- **Decision**: 자체 파서 구현 (라이브러리 사용하지 않음)
- **Rationale**: `product.md` 포맷은 `# product` + `## section` 구조가 고정. 줄 단위 파싱으로 충분.
- **Alternatives considered**: `markdown` 패키지 → 과도함

### 2. 디바운스 자동 저장

- **Decision**: `dart:async`의 `Timer`를 사용한 디바운스 패턴
- **Rationale**: 내장 Timer로 충분. 필드 변경마다 타이머 리셋, 만료 시 save 호출.

### 3. 상태 관리 패턴

- **Decision**: `StatefulWidget` 로컬 상태 + Service 직접 호출
- **Rationale**: 폼 상태는 화면 로컬. Provider에 올릴 필요 없음. 단, 폴더 rename 후에는 WorkspaceProvider.renameProject()를 호출하여 프로젝트 경로를 업데이트해야 함.

### 4. 미인식 섹션 보존 전략

- **Decision**: 파싱 시 미인식 섹션을 `List<RawSection>`으로 수집, 직렬화 시 정규 섹션 뒤에 추가
- **Rationale**: FR-010 준수. 수동 추가 섹션 유실 방지.

### 5. 폴더 rename 전략

- **Decision**: `dart:io` Directory.rename()을 사용. WorkspaceService에 renameProject() 추가.
- **Rationale**: 같은 파일 시스템 내 rename은 원자적 작업. rename 후 WorkspaceProvider의 프로젝트 path를 업데이트하고 product.md도 새 경로에서 저장.
- **Alternatives considered**: 복사 후 삭제 → 불필요하게 복잡. 심볼릭 링크 → 과도.
- **Validation**: 빈 문자열, 사용 불가 문자, 이름 충돌을 기존 WorkspaceService.validateProjectName()으로 검증.

### 6. Product 필드 구성 결정

- **Decision**: Name + Mission + Principles (3개)
- **Rationale**: Clean Architecture 의존성 규칙을 기획에 적용. Product 레이어는 하위(entities, policies, user stories...)보다 덜 바뀌고, 변경 시 하위에 영향을 주지만 하위 변경에는 영향받지 않는 필드만 포함. Problem은 Mission에 내포, Vision은 하위 구속력 부족으로 제외.
