# Research: 프로젝트 상세 페이지 (Project Detail Page)

**Date**: 2026-03-30 | **Branch**: `005-project-detail-page`

## Findings

기술적 미지 없음. 순수 UI 내비게이션 기능으로 모든 기술이 확립됨.

### 1. 화면 전환 패턴

- **Decision**: Provider 상태 기반 뷰 전환 (Navigator 대신)
- **Rationale**: 현재 앱은 `WorkspaceProvider`의 상태에 따라 화면을 전환하는 패턴을 사용 중 (`isLoading`, `hasWorkspace`). 동일한 패턴으로 "프로젝트 상세 뷰 진입 여부"를 상태로 관리하면 일관성 유지. Navigator.push는 새 창/라우트에 적합하지만, 같은 워크스페이스 컨텍스트 내 전환에는 상태 기반이 더 자연스러움
- **Alternatives considered**: Navigator.push/pop → Provider 패턴과 불일치, 상태 공유가 복잡해짐

### 2. 사이드바 레이아웃

- **Decision**: `Row` 위젯으로 좌측 `NavigationRail` (또는 커스텀 `ListView`) + 우측 `Expanded` 콘텐츠 영역
- **Rationale**: Flutter Material의 `NavigationRail`이 데스크톱 사이드바에 적합. 6개 고정 메뉴에 맞고, 선택 상태 관리가 내장됨
- **Alternatives considered**: `Drawer` → 데스크톱에서 항상 열려있는 사이드바에 부적합. 커스텀 `Column` → NavigationRail이 더 간결

### 3. 메뉴 선택 상태 관리

- **Decision**: `project_detail_screen.dart` 내 `StatefulWidget`의 로컬 상태로 관리 (selectedIndex)
- **Rationale**: 메뉴 선택 상태는 화면 로컬이며 다른 화면과 공유할 필요 없음. Provider에 올릴 필요 없음
- **Alternatives considered**: Provider에 추가 → Constitution III 위반 (불필요한 상태 공유)
