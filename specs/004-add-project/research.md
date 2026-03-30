# Research: 프로젝트 추가 (Add Project)

**Date**: 2026-03-30 | **Branch**: `004-add-project`

## Findings

기술적 미지(NEEDS CLARIFICATION) 없음. 모든 기술 스택이 기존 코드베이스에서 확립되어 있음.

### 1. 폴더/파일 생성 패턴 (dart:io)

- **Decision**: `Directory.create(recursive: true)` + `File.create()`으로 직접 생성
- **Rationale**: Flutter desktop은 dart:io를 완전히 지원하며, 기존 `WorkspaceService`가 이미 `Directory`/`File` API를 사용 중. 추가 패키지 불필요
- **Alternatives considered**: 없음 (dart:io가 유일한 선택지)

### 2. 프로젝트명 유효성 검증

- **Decision**: 서비스 레이어에서 검증 메서드를 분리하여 구현
- **Rationale**: 다이얼로그에서 확인 전 검증하고, 오류 메시지를 반환. `RegExp`로 금지 문자 체크, `toLowerCase()` 비교로 대소문자 무시 중복 검사
- **Alternatives considered**: Form validator 위젯 사용 → 서비스 레이어 검증이 더 테스트하기 쉬움

### 3. 롤백 전략

- **Decision**: try-catch에서 실패 시 `Directory.delete(recursive: true)`로 프로젝트 폴더 전체 삭제
- **Rationale**: 프로젝트 폴더는 새로 생성된 것이므로 전체 삭제가 안전. 부분 상태가 남지 않음
- **Alternatives considered**: 트랜잭션 패턴 → 과도한 복잡성, Constitution I 위반

### 4. 목록 갱신 전략

- **Decision**: 생성 후 `refreshProjects()` 호출 → 활성 프로젝트 설정
- **Rationale**: 기존 `WorkspaceProvider.refreshProjects()`가 디렉토리 재스캔 + 활성 상태 보존을 이미 처리. 새 프로젝트명으로 활성화만 추가하면 됨
- **Alternatives considered**: 프로젝트 리스트에 직접 추가 → 파일 시스템과 불일치 가능성

### 5. 템플릿 구조 정의

- **Decision**: 하드코딩된 상수 리스트로 폴더/파일 경로 정의
- **Rationale**: 템플릿이 고정적이고 변경 빈도가 낮음. 설정 파일이나 외부 데이터 소스 불필요
- **Alternatives considered**: JSON/YAML 템플릿 파일 → 현재 요구사항에 과도한 추상화
