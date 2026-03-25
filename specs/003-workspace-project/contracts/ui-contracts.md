# UI Contracts: 003-workspace-project

## Screens

### WorkspaceSelectionScreen

- **When shown**: 첫 실행, 저장된 경로 무효, 새 창 열기
- **Actions**: "Open Workspace" 버튼 → OS 디렉토리 선택 대화상자
- **Output**: 선택된 디렉토리 경로 → WorkspaceHomeScreen으로 전환

### WorkspaceHomeScreen

- **When shown**: workspace가 열린 상태
- **Displays**:
  - Workspace 이름 (상단)
  - 프로젝트 목록 (알파벳 순, 스크롤 가능)
  - 빈 상태 메시지 (프로젝트 없을 때)
- **Actions**:
  - 프로젝트 클릭 → 활성 프로젝트 표시
  - "Open Workspace" → 디렉토리 선택 → workspace 교체
  - "New Window" → 새 창 (WorkspaceSelectionScreen)
- **Auto-refresh**: 창 포커스 획득 시 프로젝트 목록 갱신
