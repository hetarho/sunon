# Implementation Plan: Global Context Panel

**Branch**: `008-global-context-panel` | **Date**: 2026-04-05 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/008-global-context-panel/spec.md`

## Summary

프로젝트 상세 뷰(ProjectDetailScreen)의 우측에 전역 컨텍스트 패널을 추가한다. 문서 계층의 의존성 규칙에 따라 현재 페이지에서 참조 가능한 상위 계층의 정보를 패널에서 편집할 수 있다. 초기 구현은 Entities 페이지에서 Product 편집 폼을 패널에 표시하는 것에 집중한다. 기존 ProductPage 위젯을 직접 재사용하며 새 모델/서비스 없이 ProjectDetailScreen의 레이아웃만 확장한다.

## Technical Context

**Language/Version**: Dart ^3.11.1 (Flutter stable)
**Primary Dependencies**: flutter, provider 6.x, dart:io
**Storage**: 로컬 파일 시스템 (`{project_path}/product.md`) — 기존 ProductService 재사용
**Testing**: 수동 테스트 (데스크톱 앱 실행)
**Target Platform**: macOS desktop
**Project Type**: desktop-app (Flutter)
**Performance Goals**: 패널 토글 후 500ms 이내 콘텐츠 표시
**Constraints**: 패널 고정 너비 320px, 동시 편집 시 독립 저장
**Scale/Scope**: 변경 파일 2개, 신규 파일 0개

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Speed Over Stability | PASS | 기존 ProductPage 직접 재사용, 새 추상화 없음. 변경 파일 2개로 최소화. |
| II. Spec-Driven Development | PASS | spec.md 작성 완료, 의존성 규칙은 constitution Document Architecture를 그대로 반영. |
| III. Minimal Viable Iteration | PASS | Entities → Product 참조만 초기 구현. 나머지 계층은 플레이스홀더. 접기/펼치기(P3)는 섹션이 1개일 때 불필요하므로 생략 가능. |
| IV. Platform Agnostic Authoring | PASS | 패널 기능은 UI 레이어만 변경. 마크다운 문서 형식에 영향 없음. |

**Development Philosophy 체크:**
- 불필요한 추상화 없음 (LayerReferenceRule 클래스 X, 인라인 Map 사용)
- 3줄 중복이 섣부른 추상화보다 낫다 → ProductPage 직접 임베드
- 완성도 80%에서 다음으로 넘어간다 → 접기/펼치기, 리사이즈 향후

**Post-Design Re-check**: PASS — 연구 결과 새로운 위반 사항 없음.

## Project Structure

### Documentation (this feature)

```text
specs/008-global-context-panel/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output - 기술 결정 6건
├── data-model.md        # Phase 1 output - UI state 모델
├── quickstart.md        # Phase 1 output - 빠른 참조
├── contracts/
│   └── ui-contract.md   # Phase 1 output - 레이아웃/상태 계약
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
app/lib/
├── screens/
│   └── project_detail_screen.dart  ← 핵심 변경 (패널 레이아웃 + 토글)
├── providers/
│   └── workspace_provider.dart     ← 소규모 변경 (notifyListeners 추가)
├── screens/
│   └── product_page.dart           ← 변경 없음 (패널에 직접 재사용)
├── services/
│   └── product_service.dart        ← 변경 없음
└── models/
    └── product_document.dart       ← 변경 없음
```

**Structure Decision**: 기존 Flutter 앱 구조 유지. 신규 파일 없음. ProjectDetailScreen 레이아웃 확장만으로 구현.

## Complexity Tracking

해당 없음. Constitution Check에 위반 사항 없음.
