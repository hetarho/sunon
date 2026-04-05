# Data Model: 008-global-context-panel

**Date**: 2026-04-05

## 개요

이 기능은 새로운 데이터 엔티티를 추가하지 않는다. 기존 `ProductDocument` 모델과 `ProductService`를 그대로 재사용한다.

패널 자체의 상태는 UI 레벨에서만 존재하며 (persisted 아님), `ProjectDetailScreen`의 로컬 State로 관리한다.

## UI State (비영구)

### ProjectDetailScreen State 확장

| 필드 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `_selectedIndex` | `int` | `0` | (기존) 좌측 사이드바 메뉴 선택 인덱스 |
| `_isPanelOpen` | `bool` | `false` | (신규) 우측 컨텍스트 패널 열림/닫힘 |

### Layer Reference Rule (인라인 상수)

| 메뉴 인덱스 | 계층 | 참조 가능 인덱스 |
|-------------|------|-----------------|
| 0 | Product | [] (없음) |
| 1 | Entities | [0] (Product) |
| 2 | Policies | [0, 1] |
| 3 | User Stories | [0, 1, 2] |
| 4 | Elements | [0, 1, 2] |
| 5 | Specs | [0, 1, 2, 3, 4] |

## 기존 모델 재사용

### ProductDocument (변경 없음)

```
ProductDocument
├── name: String
├── mission: String
├── principles: List<String>
└── unknownSections: List<RawSection>
```

- 패널의 ProductPage 인스턴스가 동일한 `ProductService.load()` / `ProductService.save()`를 사용
- 파일 경로: `{projectPath}/product.md`

## 엔티티 관계

```
ProjectDetailScreen
├── 관리: _isPanelOpen (패널 상태)
├── 관리: _selectedIndex (메뉴 선택)
├── 참조: layerReferences (계층 규칙)
│
├── 메인 콘텐츠 (Expanded)
│   ├── case 0: ProductPage(projectPath)
│   ├── case 1: EntityListPage(projectPath)
│   └── case 2-5: Placeholder
│
└── 컨텍스트 패널 (조건부)
    └── 참조 가능 계층의 페이지 위젯
        └── 현재: ProductPage(projectPath) (entities 페이지일 때)
```

## 변경 영향

| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| `project_detail_screen.dart` | 수정 | 패널 상태, AppBar 토글 버튼, Row 레이아웃 확장 |
| `workspace_provider.dart` | 수정 | `updateProjectPath()`에 `notifyListeners()` 추가 |
| 신규 파일 | 없음 | 새 모델/서비스 없음 |
