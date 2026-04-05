# Quickstart: 008-global-context-panel

## 한줄 요약
프로젝트 상세 뷰 우측에 컨텍스트 패널 추가. 엔티티 편집 중 product 정보를 패널에서 바로 조회/편집 가능.

## 변경 파일 (2개)

1. **`app/lib/screens/project_detail_screen.dart`** — 핵심 변경
   - `_isPanelOpen` state 추가
   - AppBar에 토글 버튼 추가 (actions)
   - body Row에 패널 영역 조건부 추가
   - `_layerReferences` 상수 (계층별 참조 규칙)
   - `_buildContextPanel()` 메서드 (참조 계층에 따른 위젯 반환)

2. **`app/lib/providers/workspace_provider.dart`** — 소규모 변경
   - `updateProjectPath()`에 `notifyListeners()` 추가

## 핵심 코드 패턴

```dart
// ProjectDetailScreen body Row
Row(
  children: [
    NavigationRail(...),
    const VerticalDivider(thickness: 1, width: 1),
    Expanded(child: _buildContent(projectPath)),
    if (_isPanelOpen) ...[
      const VerticalDivider(thickness: 1, width: 1),
      SizedBox(width: 320, child: _buildContextPanel(projectPath)),
    ],
  ],
)
```

## 테스트 시나리오
1. Entities 메뉴 → 토글 버튼 클릭 → 우측에 Product 편집 폼 표시
2. 패널에서 Mission 수정 → Product 메뉴로 이동 → 수정 내용 반영 확인
3. Product 메뉴 → 토글 버튼 비활성화 확인
4. 패널 열린 상태에서 메뉴 전환 → 패널 상태 유지
