# Quickstart: 데이터 구조 페이지 개편

**Branch**: `009-revise-data-structure-page`

## 작업 요약

기존 entity 관련 코드 4개 파일을 수정하여 기획자 친화적 데이터 구조 페이지로 개편한다.

## 수정 파일 목록

1. **`app/lib/models/entity_document.dart`** — 모델 단순화
2. **`app/lib/services/entity_service.dart`** — 디렉토리/파싱/직렬화 변경
3. **`app/lib/screens/entity_list_page.dart`** — 리스트 UI 단순화
4. **`app/lib/screens/entity_detail_page.dart`** — 상세 페이지 단순화
5. **`app/lib/screens/project_detail_screen.dart`** — 사이드바 메뉴명 변경

## 핵심 변경사항

### Model (`entity_document.dart`)
- `EntityColumn` → `Attribute` (name, info 2필드)
- `LocalType`, `LocalEnum`, `supportedColumnTypes` 제거
- `EntityDocument` 필드: name, attributes, unknownSections

### Service (`entity_service.dart`)
- 디렉토리: `entities/` → `data/`
- 파싱: `## columns` (5칸) → `## 속성` (2칸)
- 직렬화: 2칸 테이블 출력
- `listTypes`, `createType`, `deleteType` 제거

### List Page (`entity_list_page.dart`)
- Types 섹션 전체 제거
- 용어: "엔티티" → "데이터 항목", "Add Entity" → "데이터 항목 추가"
- `DetailKind` enum 불필요 → 제거

### Detail Page (`entity_detail_page.dart`)
- 5칸 테이블 → 2칸 테이블 (속성명 | 속성 정보)
- 타입 드롭다운, isList/required 체크박스 제거
- Local Type / Enum 섹션 전체 제거
- `_LocalTypeCtrl`, `_LocalEnumCtrl` 클래스 제거

### Sidebar (`project_detail_screen.dart`)
- `_menuLabels[1]`: `'Entities'` → `'데이터 구조'`

## 실행 방법

```bash
cd app && flutter run -d macos
```

## 검증

- 사이드바에서 "데이터 구조" 클릭 → 데이터 항목 리스트 표시
- "데이터 항목 추가" → 이름 입력 → 생성 → `data/` 디렉토리에 md 파일 생성 확인
- 항목 클릭 → 2칸 표 형태로 속성 추가/편집/삭제 가능
- 자동 저장 후 md 파일 내용이 `## 속성` + 2칸 테이블 형식인지 확인
