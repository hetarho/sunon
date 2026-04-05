# UI Contract: Global Context Panel

**Date**: 2026-04-05

## 레이아웃 구조

### 패널 닫힘 (기본 상태)

```
┌─ AppBar ──────────────────────────────────────────┐
│ [←]  ProjectName                       [📋 toggle] │
├───┬───────────────────────────────────────────────┤
│ N │                                               │
│ a │                                               │
│ v │         메인 콘텐츠 (Expanded)                 │
│ R │                                               │
│ a │                                               │
│ i │                                               │
│ l │                                               │
└───┴───────────────────────────────────────────────┘
```

### 패널 열림

```
┌─ AppBar ──────────────────────────────────────────┐
│ [←]  ProjectName                       [📋 toggle] │
├───┬──────────────────────┬─┬──────────────────────┤
│ N │                      │ │                      │
│ a │                      │ │   Context Panel      │
│ v │   메인 콘텐츠        │D│   (width: 320px)     │
│ R │   (Expanded)         │i│                      │
│ a │                      │v│   [Product 편집 폼]  │
│ i │                      │ │                      │
│ l │                      │ │                      │
└───┴──────────────────────┴─┴──────────────────────┘
```

## AppBar 토글 버튼

### 상태별 동작

| 현재 페이지 | 토글 버튼 상태 | 클릭 시 동작 |
|------------|--------------|-------------|
| Product (index 0) | 비활성화 (greyed out) | 없음 |
| Entities (index 1) | 활성화 | 패널 열기/닫기 |
| Policies (index 2) | 활성화 | 패널 열기/닫기 |
| User Stories (index 3) | 활성화 | 패널 열기/닫기 |
| Elements (index 4) | 활성화 | 패널 열기/닫기 |
| Specs (index 5) | 활성화 | 패널 열기/닫기 |

### 아이콘

- 패널 닫힘: `Icons.vertical_split` (또는 적절한 패널 아이콘)
- 패널 열림: 동일 아이콘 (토글 상태는 색상/채움으로 구분)
- 비활성화: 동일 아이콘, opacity 낮춤

## 패널 콘텐츠 매핑

| 현재 메뉴 인덱스 | 패널에 표시할 위젯 |
|-----------------|-------------------|
| 0 (Product) | 없음 (패널 비활성화) |
| 1 (Entities) | `ProductPage(projectPath: ...)` |
| 2 (Policies) | `ProductPage` + (향후 Entity 목록) |
| 3 (User Stories) | `ProductPage` + (향후 Entities + Policies) |
| 4 (Elements) | `ProductPage` + (향후 Entities + Policies) |
| 5 (Specs) | (향후 전체) |

**초기 구현**: index 1 (Entities) → ProductPage만 구현. 나머지는 패널에 "향후 지원" 플레이스홀더.

## 패널 내부 구조 (향후 다중 섹션 시)

```
┌─ Context Panel ─────────┐
│ ▼ Product               │  ← 섹션 헤더 (접기/펼치기)
│   [Product 편집 폼]     │
│                         │
│ ▶ Entities (접힌 상태)  │  ← 향후 policies 페이지 등에서
│                         │
└─────────────────────────┘
```

초기 구현에서는 섹션이 1개(Product)뿐이므로 접기/펼치기 UI 없이 바로 ProductPage를 렌더링.

## 패널 크기

| 속성 | 값 |
|------|-----|
| 너비 | 320px 고정 |
| 높이 | 메인 콘텐츠와 동일 (body 전체) |
| 구분선 | VerticalDivider(thickness: 1, width: 1) |
