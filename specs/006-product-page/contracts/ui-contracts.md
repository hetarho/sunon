# UI Contracts: Product 페이지 (Product Page)

**Date**: 2026-03-30 | **Branch**: `006-product-page`

## ProductPage Widget

### 입력 (Props)

| Prop | Type | Description |
|------|------|-------------|
| projectPath | String | 현재 활성 프로젝트의 절대 경로 |

### 레이아웃

```text
┌──────────────────────────────────────────────┐
│  Product Name                                │
│  ┌──────────────────────────────────────────┐│
│  │ [TextField: 한 줄, 폴더명과 동기화]      ││
│  └──────────────────────────────────────────┘│
│                                              │
│  Mission                                     │
│  ┌──────────────────────────────────────────┐│
│  │ [TextField: 여러 줄, 자동 확장]          ││
│  └──────────────────────────────────────────┘│
│                                              │
│  Principles                                  │
│  ┌──────────────────────────────────────────┐│
│  │ [TextField] [삭제 X]                     ││
│  │ [TextField] [삭제 X]                     ││
│  │ [+ 원칙 추가]                            ││
│  └──────────────────────────────────────────┘│
└──────────────────────────────────────────────┘
```

### 동작

| 이벤트 | 동작 |
|--------|------|
| 페이지 진입 | ProductService.load() → 폼 초기화. 파일 없으면 Name=폴더명 |
| 텍스트 수정 | 디바운스 타이머 리셋 |
| 디바운스 만료 | Name 변경 시 → renameProject() → save(). Name 동일 시 → save() |
| rename 실패 | SnackBar 오류, Name 필드를 이전 값으로 복원 |
| 저장 실패 | SnackBar 오류 |
| Principles +/X | 항목 추가/제거, 디바운스 트리거 |
| 페이지 이탈 | 대기 중 디바운스 즉시 실행 |

### Placeholder 힌트

| 필드 | Placeholder |
|------|-------------|
| Product Name | 프로덕트 이름을 입력하세요 |
| Mission | 프로덕트의 미션을 작성하세요 |
| Principle 항목 | 원칙을 입력하세요 |

## ProductService

| Method | Input | Output | Description |
|--------|-------|--------|-------------|
| load | String projectPath | Future\<ProductDocument\> | product.md 읽기 + 파싱. 없으면 빈 doc 반환 |
| save | String projectPath, ProductDocument doc | Future\<void\> | 직렬화 → product.md 쓰기 |
| parse | String markdown | ProductDocument | 마크다운 → ProductDocument |
| serialize | ProductDocument doc | String | ProductDocument → 마크다운 |

## WorkspaceService (확장)

| Method | Input | Output | Description |
|--------|-------|--------|-------------|
| renameProject | String oldPath, String newName | Future\<String\> | 폴더 rename, 새 경로 반환. 실패 시 예외 |
