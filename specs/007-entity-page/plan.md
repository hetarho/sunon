# Implementation Plan: Entity Page

**Branch**: `007-entity-page` | **Date**: 2026-04-05 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/007-entity-page/spec.md`

## Summary

프로젝트의 `entities/` 디렉토리에 저장된 마크다운 파일을 기반으로 엔티티(데이터 모델)를 관리하는 페이지를 구현한다. 엔티티 리스트 조회, 생성(모달), 삭제(확인 다이얼로그), 상세 페이지(칼럼 CRUD + 자동 저장)를 포함한다. 기존 ProductPage/ProductService 패턴을 따라 마크다운 파싱/직렬화 + 500ms 디바운스 자동 저장 방식으로 구현한다.

## Technical Context

**Language/Version**: Dart ^3.11.1 (Flutter stable)
**Primary Dependencies**: flutter, provider 6.x, dart:io, dart:async (Timer)
**Storage**: 로컬 파일 시스템 (`{project_path}/entities/{entity_name}.md`)
**Testing**: flutter_test (핵심 경로만 — Constitution I)
**Target Platform**: macOS Desktop
**Project Type**: desktop-app (Flutter)
**Performance Goals**: 엔티티 리스트 로딩 < 1초, 자동 저장 디바운스 500ms
**Constraints**: 오프라인 전용, 로컬 파일 시스템 의존
**Scale/Scope**: 프로젝트당 수십 개 엔티티, 엔티티당 수십 개 칼럼

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Speed Over Stability | PASS | 핵심 기능 구현에 집중. 과도한 에러 핸들링 없이 기존 패턴 재사용 |
| II. Spec-Driven Development | PASS | spec.md 완성 후 plan 진행. entities 계층 구조 준수 |
| III. Minimal Viable Iteration | PASS | User Story 단위로 구현. 불필요한 추상화 없음 |
| IV. Platform Agnostic Authoring | PASS | 마크다운 테이블 형식으로 저장. 특정 에디터 비종속 |

## Project Structure

### Documentation (this feature)

```text
specs/007-entity-page/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (via /speckit.tasks)
```

### Source Code (repository root)

```text
app/lib/
├── models/
│   ├── entity_document.dart      # NEW: EntityDocument, EntityColumn models
│   ├── product_document.dart
│   ├── project.dart
│   └── workspace.dart
├── providers/
│   └── workspace_provider.dart
├── screens/
│   ├── entity_detail_page.dart   # NEW: Column CRUD + auto-save
│   ├── entity_list_page.dart     # NEW: Entity list + add/delete
│   ├── product_page.dart
│   ├── project_detail_screen.dart  # MODIFIED: Wire entity pages to sidebar index 1
│   ├── workspace_home_screen.dart
│   └── workspace_selection_screen.dart
├── services/
│   ├── entity_service.dart       # NEW: MD parse/serialize + CRUD
│   ├── persistence_service.dart
│   ├── product_service.dart
│   └── workspace_service.dart
└── widgets/
```

**Structure Decision**: 기존 Flutter 프로젝트 구조를 유지하며 models/screens/services에 엔티티 관련 파일을 추가한다. ProductPage/ProductService 패턴과 동일한 구조를 따른다.
