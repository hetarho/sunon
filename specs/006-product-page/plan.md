# Implementation Plan: Product 페이지 (Product Page)

**Branch**: `006-product-page` | **Date**: 2026-03-30 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/006-product-page/spec.md`

## Summary

프로젝트 상세 뷰의 Product 메뉴에서 TBD 플레이스홀더를 실제 Product 편집 폼으로 교체한다. 프로젝트 폴더의 `product.md` 파일을 읽어 구조화된 폼(Name, Mission, Principles)으로 표시하고, 디바운스 기반 자동 저장으로 파일에 동기화한다. Product Name 변경 시 프로젝트 폴더도 rename한다.

## Technical Context

**Language/Version**: Dart ^3.11.1 (Flutter stable)
**Primary Dependencies**: flutter, provider 6.x, dart:io, dart:async (Timer)
**Storage**: 로컬 파일 시스템 (`{project_path}/product.md`)
**Testing**: flutter_test (widget test)
**Target Platform**: macOS desktop
**Project Type**: desktop-app (Flutter)
**Performance Goals**: 폼 표시 <1초, 자동 저장 <1초, 폴더 rename <1초
**Constraints**: 없음
**Scale/Scope**: 폼 필드 3개 (name, mission, principles), 프로젝트당 파일 1개

## Constitution Check

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Speed Over Stability | PASS | 자체 마크다운 파서, Timer 디바운스, 최소 필드 구성 |
| II. Spec-Driven Development | PASS | spec.md 완료, product는 문서 계층 최상위 |
| III. Minimal Viable Iteration | PASS | P1(조회+편집+자동저장+rename) → P2(포맷 호환+목록 관리) |
| IV. Platform Agnostic Authoring | PASS | 표준 마크다운, source/product.md 예시와 동일 포맷 |

## Project Structure

### Source Code (repository root)

```text
app/lib/
├── main.dart                           # (변경 없음)
├── models/
│   ├── workspace.dart                  # (변경 없음)
│   ├── project.dart                    # (변경 없음)
│   └── product_document.dart           # ✏️ problem/vision 제거
├── providers/
│   └── workspace_provider.dart         # ✏️ + renameProject() 메서드
├── screens/
│   ├── project_detail_screen.dart      # ✏️ Product 메뉴 → ProductPage 연결
│   └── product_page.dart               # ✏️ problem/vision 필드 제거, rename 로직 추가
└── services/
    ├── workspace_service.dart          # ✏️ + renameProject() 메서드
    └── product_service.dart            # ✏️ problem/vision 파싱/직렬화 제거
```
