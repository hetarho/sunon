# Implementation Plan: Policy 페이지

**Branch**: `010-policy-page` | **Date**: 2026-04-07 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/010-policy-page/spec.md`

## Summary

Policy 페이지는 기획자가 의사결정 기준을 자유 형식 마크다운으로 작성/관리하는 기능이다. 기존 Entity(데이터 항목) 페이지와 동일한 패턴(목록 → 상세 → 자동 저장)을 따르되, 속성 테이블 대신 자유 형식 텍스트 에디터를 사용한다. `policies/{name}.md` 플랫 구조.

## Technical Context

**Language/Version**: Dart ^3.11.1 (Flutter stable)
**Primary Dependencies**: flutter, provider 6.x, dart:io, dart:async (Timer)
**Storage**: 로컬 파일 시스템 (`{project_path}/policies/{name}.md`)
**Testing**: 핵심 경로만 (Constitution: 커버리지 목표 없음)
**Target Platform**: macOS Desktop (Flutter Desktop)
**Project Type**: desktop-app
**Performance Goals**: 목록 로딩 1초 이내, 자동 저장 500ms 디바운스
**Constraints**: 오프라인 전용, 로컬 파일시스템만 사용
**Scale/Scope**: 프로젝트당 수십 개 policy 예상

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Speed Over Stability | PASS | 기존 Entity 패턴 재사용, 새 추상화 없음 |
| II. Spec-Driven Development | PASS | spec.md 작성 완료, clarify 완료 |
| III. Minimal Viable Iteration | PASS | Entity 패턴 복제 + 최소 변경 (텍스트 에디터만 다름) |
| IV. Platform Agnostic Authoring | PASS | 마크다운 기반, # 제목 + 자유 형식 본문 |

위반 사항 없음.

## Project Structure

### Documentation (this feature)

```text
specs/010-policy-page/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
app/lib/
├── models/
│   └── policy_document.dart       # NEW: PolicyDocument, PolicySummary
├── services/
│   └── policy_service.dart        # NEW: CRUD + parse/serialize
├── screens/
│   ├── policy_list_page.dart      # NEW: 목록 + 추가/삭제
│   ├── policy_detail_page.dart    # NEW: 제목 필드 + 본문 에디터 + 자동 저장
│   └── project_detail_screen.dart # MODIFY: case 2 추가
```

**Structure Decision**: 기존 Entity 페이지와 동일한 구조. Model → Service → ListPage → DetailPage 패턴. Provider 불필요 (Entity도 미사용).
