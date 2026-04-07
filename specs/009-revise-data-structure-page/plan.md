# Implementation Plan: 데이터 구조 페이지 개편

**Branch**: `009-revise-data-structure-page` | **Date**: 2026-04-07 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/009-revise-data-structure-page/spec.md`

## Summary

기존 007-entity-page의 개발자 중심 데이터 모델링 UI를 기획자 친화적 데이터 구조 정리 도구로 전면 개편한다. `int`/`float`/`bool` 등 개발 타입, `isList`/`required` 체크박스, Local Type/Enum을 모두 제거하고, "속성명 | 속성 정보" 2칸 자연어 표 형태로 단순화한다. 디렉토리명을 `entities/` → `data/`로 변경하며, 마이그레이션은 하지 않는다.

## Technical Context

**Language/Version**: Dart ^3.11.1 (Flutter stable)
**Primary Dependencies**: flutter, provider 6.x, dart:io, dart:async (Timer)
**Storage**: 로컬 파일 시스템 (`{project_path}/data/{item_name}.md`)
**Testing**: flutter_test (위젯 테스트) — 핵심 경로만
**Target Platform**: macOS Desktop (Flutter desktop)
**Project Type**: desktop-app
**Performance Goals**: 1초 이내 목록 표시, 자동 저장 500ms 디바운스
**Constraints**: 오프라인 전용, 로컬 파일 시스템 의존
**Scale/Scope**: 단일 사용자, 프로젝트당 수십~수백 개 데이터 항목

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Speed Over Stability | PASS | 기존 코드를 리팩터링하여 빠르게 개편. 마이그레이션 생략으로 복잡도 최소화 |
| II. Spec-Driven Development | PASS | spec.md가 single source of truth |
| III. Minimal Viable Iteration | PASS | 기존 파일 4개(model, service, list, detail) 수정으로 완결. 새 파일 생성 없음 |
| IV. Platform Agnostic Authoring | PASS | markdown 기반 저장 형식 유지. 더 단순한 2칸 표 형태 |

## Project Structure

### Documentation (this feature)

```text
specs/009-revise-data-structure-page/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── data-item-markdown-format.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
app/lib/
├── models/
│   └── entity_document.dart    # → 모델 단순화 (DataItem + Attribute)
├── screens/
│   ├── entity_list_page.dart   # → 데이터 항목 리스트 (용어/UI 변경)
│   ├── entity_detail_page.dart # → 2칸 표 형태 상세 페이지
│   └── project_detail_screen.dart # → 사이드바 메뉴명 변경
└── services/
    └── entity_service.dart     # → data/ 디렉토리, 2칸 파싱/직렬화
```

**Structure Decision**: 기존 파일 4개를 수정한다. 신규 파일 생성 없음. Constitution III (Minimal Viable Iteration) 준수.
