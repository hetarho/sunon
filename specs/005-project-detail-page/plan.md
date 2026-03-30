# Implementation Plan: 프로젝트 상세 페이지 (Project Detail Page)

**Branch**: `005-project-detail-page` | **Date**: 2026-03-30 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/005-project-detail-page/spec.md`

## Summary

프로젝트 선택 시 프로젝트 상세 뷰로 전환한다. 좌측 사이드바에 sunon 문서 계층 순서(Product, Entities, Policies, User Stories, Elements, Specs)로 메뉴를 표시하고, 메뉴 클릭 시 우측에 TBD 플레이스홀더 페이지를 보여준다. 기존 `workspace_home_screen.dart`의 프로젝트 탭 동작을 변경하여 상세 화면으로 내비게이션하고, 새로운 `project_detail_screen.dart`를 추가한다.

## Technical Context

**Language/Version**: Dart ^3.11.1 (Flutter stable)
**Primary Dependencies**: flutter, provider 6.x, dart:io
**Storage**: N/A (UI 전환만, 파일 시스템 접근 없음)
**Testing**: flutter_test (widget test)
**Target Platform**: macOS desktop
**Project Type**: desktop-app (Flutter)
**Performance Goals**: 화면 전환 1초 이내, 메뉴 전환 200ms 이내
**Constraints**: 없음 (순수 UI 기능)
**Scale/Scope**: 사이드바 메뉴 6개 고정, TBD 플레이스홀더 페이지 6개

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Speed Over Stability | PASS | TBD 플레이스홀더로 최소 구현, 새 화면 1개 추가 |
| II. Spec-Driven Development | PASS | spec.md 작성 완료, 계층 구조 constitution과 일치 |
| III. Minimal Viable Iteration | PASS | P1(사이드바+TBD) → P2(뒤로가기) 독립 구현 가능 |
| IV. Platform Agnostic Authoring | PASS | 해당 없음 (UI 내비게이션 기능) |

**Post-Phase 1 Re-check**: PASS — 새 화면 1개 추가, 기존 패턴(Screen + Provider) 유지.

## Project Structure

### Documentation (this feature)

```text
specs/005-project-detail-page/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (by /speckit.tasks)
```

### Source Code (repository root)

```text
app/lib/
├── main.dart
├── models/
│   ├── workspace.dart
│   └── project.dart
├── providers/
│   └── workspace_provider.dart    # + navigateToProject(), navigateBack() 상태 관리
├── screens/
│   ├── workspace_home_screen.dart # 프로젝트 탭 시 상세 뷰 전환 연결
│   └── project_detail_screen.dart # 🆕 사이드바 + TBD 콘텐츠 영역
├── services/
│   └── workspace_service.dart     # (변경 없음)
└── widgets/                       # (변경 없음)
```

**Structure Decision**: 기존 `app/lib/` 구조 유지. 새 화면 `project_detail_screen.dart` 1개 추가. Provider에 내비게이션 상태 추가.
