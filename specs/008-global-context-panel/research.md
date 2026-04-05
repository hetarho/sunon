# Research: 008-global-context-panel

**Date**: 2026-04-05

## R1: 패널에서 기존 컴포넌트 재사용 전략

### Decision
`ProductPage` 위젯을 패널에 직접 임베드하여 재사용한다. 별도의 공유 위젯 추출 없이 기존 StatefulWidget 그대로 사용.

### Rationale
- `ProductPage`는 자체적으로 파일 로드, 디바운스 저장, 폴더 rename 등 모든 로직을 캡슐화하고 있다.
- 패널에 표시될 때와 메인 콘텐츠에 표시될 때 동시에 존재하지 않는다 (Product 페이지에서는 패널 비활성화).
- Constitution: "3줄 중복이 섣부른 추상화보다 낫다" — 추출할 이유가 없다.

### Alternatives Considered
- **ProductForm 추출**: ProductPage에서 폼 부분만 별도 위젯으로 분리. 불필요한 추상화 레이어 추가. 현재 사용처가 2개가 아닌 1개이므로 YAGNI 위반.
- **Service 레벨 공유만**: UI는 새로 만들고 ProductService만 재사용. 동일한 폼을 두 번 구현하게 됨. 유지보수 부담.

## R2: 패널 레이아웃 전략 (오버레이 vs 레이아웃 분할)

### Decision
Row 기반 레이아웃 분할. 패널이 열리면 Expanded content 영역 옆에 고정 너비 Container가 추가된다.

### Rationale
- 현재 `ProjectDetailScreen.body`가 이미 `Row` 기반 (NavigationRail + VerticalDivider + Expanded).
- 여기에 `VerticalDivider + SizedBox(width: panelWidth)` 를 조건부로 추가하는 것이 자연스럽다.
- Overlay/Drawer는 메인 콘텐츠를 가리므로 "동시 편집" 요건과 충돌.

### Alternatives Considered
- **endDrawer**: Flutter Scaffold의 내장 endDrawer. 오버레이 방식이라 메인 콘텐츠를 가린다. 동시 편집 불가.
- **Stack + Positioned**: 커스텀 오버레이. 레이아웃 분할이 아닌 겹침. 스펙 FR-002 "메인 콘텐츠 영역이 줄어들어야" 위반.

## R3: 패널 상태 관리

### Decision
`ProjectDetailScreen`의 setState로 `_isPanelOpen` 불린값 관리. Provider나 별도 상태 관리 불필요.

### Rationale
- 패널 상태는 ProjectDetailScreen 하위에서만 사용된다.
- 패널의 열림/닫힘은 앱 재시작 시 초기화 (영구 저장 없음).
- 현재 `_selectedIndex`도 동일하게 setState로 관리 중.
- Constitution: "불필요한 추상화, 유틸리티, 헬퍼를 만들지 않는다".

### Alternatives Considered
- **Provider에 패널 상태 추가**: WorkspaceProvider에 isPanelOpen 추가. 과도한 전역화. 다른 화면에서 패널 상태 접근 필요 없음.

## R4: 계층별 참조 규칙 구현

### Decision
`ProjectDetailScreen` 내에 인라인 Map으로 구현. 별도 모델/서비스 불필요.

### Rationale
- 규칙이 단순 (메뉴 인덱스 → 참조 가능 인덱스 리스트).
- 현재 메뉴가 6개, 구현된 페이지가 2개 (Product, Entities). 나머지는 플레이스홀더.
- 초기 구현에서 실제 동작하는 경우는 entities → product 하나뿐.

```
// 메뉴 인덱스: 0=Product, 1=Entities, 2=Policies, 3=UserStories, 4=Elements, 5=Specs
const _layerReferences = {
  0: <int>[],           // Product: 참조 없음
  1: [0],               // Entities: Product
  2: [0, 1],            // Policies: Product, Entities
  3: [0, 1, 2],         // UserStories: Product, Entities, Policies
  4: [0, 1, 2],         // Elements: Product, Entities, Policies
  5: [0, 1, 2, 3, 4],   // Specs: 전부
};
```

### Alternatives Considered
- **LayerReferenceRule 클래스**: 별도 모델로 분리. 현재 사용처 1개, 로직 5줄. 과도한 추상화.
- **Constitution Document Architecture에서 동적 로딩**: constitution.md 파일을 파싱하여 규칙 추출. 규칙이 거의 변경되지 않으며 과도한 복잡성.

## R5: 패널 너비

### Decision
고정 너비 320px. 최소 너비 제한 없음 (고정이므로 불필요). 패널이 열릴 때 창 전체가 너무 좁으면 (예: 800px 미만) 패널 열기 불가 처리는 초기 범위 밖.

### Rationale
- Desktop 앱이므로 화면이 충분히 넓다 (macOS).
- 320px는 ProductPage 폼이 사용 가능한 최소 너비.
- Constitution: "완성도 80%에서 다음으로 넘어간다" — 리사이즈는 향후.

### Alternatives Considered
- **드래그 리사이즈**: GestureDetector + 드래그. 초기 범위 밖 (spec Assumptions).
- **비율 기반**: 화면의 30%. 화면 크기에 따라 폼이 깨질 수 있음. 고정이 더 안전.

## R6: 패널에서 Product Name 변경 시 경로 업데이트

### Decision
기존 ProductPage의 rename 로직을 그대로 사용. `WorkspaceProvider.updateProjectPath()`가 호출되면, Entities 메인 콘텐츠의 `projectPath`도 갱신 필요.

### Rationale
- ProductPage는 rename 시 `widget.projectPath` (원래 경로)를 기준으로 Provider를 업데이트한다.
- ProjectDetailScreen은 `activeProject.path`를 watch하므로, Provider 업데이트 후 rebuild 시 새 경로가 전파된다.
- 단, 현재 `updateProjectPath()`는 `notifyListeners()`를 호출하지 않는다 ("Silent" 주석). 패널에서 rename 시에는 EntityListPage도 갱신되어야 하므로 notifyListeners()가 필요할 수 있다.

### Risk
- 패널의 ProductPage에서 rename 시 EntityListPage의 `projectPath`가 stale해질 수 있다. ProjectDetailScreen이 rebuild되면 해결되지만, `updateProjectPath()`가 silent이므로 rebuild가 트리거되지 않음.
- **해결**: 패널용 ProductPage에서 rename 후 ProjectDetailScreen이 rebuild되도록, `updateProjectPath()`에 조건부 notifyListeners() 추가하거나, 패널에서 rename 시 별도 콜백으로 처리.

### Decision for Risk
- `updateProjectPath()`에 notifyListeners() 추가. 현재 "Silent" 이유는 "avoid rebuilding ProductPage mid-edit"인데, 패널의 ProductPage는 패널 내부에 있으므로 rebuild가 문제되지 않는다. 메인 영역의 ProductPage는 패널에서 rename 시 존재하지 않으므로 (Product 페이지에서 패널 비활성화) 안전하다.
