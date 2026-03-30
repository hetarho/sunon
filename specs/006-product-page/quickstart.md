# Quickstart: Product 페이지 (Product Page)

**Date**: 2026-03-30 | **Branch**: `006-product-page`

## Prerequisites

- Flutter SDK (stable channel, Dart ^3.11.1)
- macOS desktop development environment
- 워크스페이스에 프로젝트가 1개 이상 존재

## Setup

```bash
cd app
flutter pub get
```

## Run

```bash
cd app
flutter run -d macos
```

## Key Files

1. `app/lib/models/product_document.dart` — ProductDocument, RawSection 모델
2. `app/lib/services/product_service.dart` — product.md 파싱/직렬화/파일 I/O
3. `app/lib/services/workspace_service.dart` — renameProject() 폴더 rename
4. `app/lib/screens/product_page.dart` — Product 편집 폼 + 자동 저장 + rename
5. `app/lib/screens/project_detail_screen.dart` — Product 메뉴 → ProductPage 연결

## Verification Flow

```text
1. 앱 실행 -> 워크스페이스 열기
2. 프로젝트 탭 -> 상세 뷰 진입
3. Product 메뉴 -> 폼 표시 확인 (Name=폴더명, Mission, Principles)
4. Mission 수정 -> 디바운스 후 product.md 반영 확인
5. Product Name 수정 -> 디바운스 후 폴더명 변경 확인
6. Principles 추가/삭제 -> product.md 불릿 리스트 반영 확인
7. 뒤로가기 -> 프로젝트 목록에서 변경된 이름 확인
8. source/product.md 형식 파일로 호환 테스트
```
