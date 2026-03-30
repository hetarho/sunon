# Implementation Plan: 프로젝트 추가 (Add Project)

**Branch**: `004-add-project` | **Date**: 2026-03-30 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-add-project/spec.md`

## Summary

워크스페이스 홈 화면에 "프로젝트 추가" 버튼을 추가하고, 프로젝트명 입력 다이얼로그를 통해 새 프로젝트를 생성한다. 프로젝트 생성 시 워크스페이스 디렉토리에 프로젝트 폴더와 표준 템플릿 구조(product.md + 하위 폴더들)를 자동으로 만든다. 기존 `WorkspaceService`에 `createProject` 메서드를 추가하고, `WorkspaceProvider`에 생성+활성화 로직을 연결한다.

## Technical Context

**Language/Version**: Dart ^3.11.1 (Flutter stable)
**Primary Dependencies**: flutter, provider 6.x, file_picker 10.x, path 1.9.x, dart:io
**Storage**: 로컬 파일 시스템 (dart:io Directory/File)
**Testing**: flutter_test (widget test)
**Target Platform**: macOS desktop (APFS/HFS+ 파일 시스템, case-insensitive)
**Project Type**: desktop-app (Flutter)
**Performance Goals**: 프로젝트 생성 3초 이내, 목록 갱신 1초 이내
**Constraints**: macOS case-insensitive 파일 시스템, 프로젝트명 255자 제한
**Scale/Scope**: 단일 사용자, 워크스페이스당 수십~수백 프로젝트

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Speed Over Stability | PASS | 기존 서비스에 메서드 추가, 새 추상화 없음, 최소 변경 |
| II. Spec-Driven Development | PASS | spec.md 작성 완료, clarification 반영됨 |
| III. Minimal Viable Iteration | PASS | P1(생성) → P2(유효성) → P3(롤백) 순으로 독립 구현 가능 |
| IV. Platform Agnostic Authoring | PASS | 생성되는 문서는 모두 markdown, 폴더 구조는 OS 무관 |

**Post-Phase 1 Re-check**: PASS — 설계가 기존 패턴(Service → Provider → Screen)을 그대로 따르며 새 레이어 없음.

## Project Structure

### Documentation (this feature)

```text
specs/004-add-project/
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
│   └── workspace_provider.dart    # + addProject() 메서드 추가
├── screens/
│   └── workspace_home_screen.dart # + 추가 버튼 + 다이얼로그
├── services/
│   └── workspace_service.dart     # + createProject(), validateProjectName() 추가
└── widgets/                       # (변경 없음)
```

**Structure Decision**: 기존 `app/lib/` 구조를 그대로 유지. 새 파일 생성 없이 기존 파일에 메서드/위젯 추가.
