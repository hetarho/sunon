# Quickstart: Entity Page

**Feature**: 007-entity-page | **Date**: 2026-04-05

## Prerequisites

- Flutter SDK ^3.11.1 (stable)
- macOS development environment
- Existing sunon workspace with at least one project

## Development

```bash
cd app
flutter run -d macos
```

## Testing the Feature

1. 앱 실행 후 워크스페이스 열기
2. 프로젝트 클릭하여 상세 페이지 진입
3. 사이드바에서 "Entities" 메뉴 클릭
4. "Add Entity" 버튼으로 엔티티 생성
5. 엔티티 클릭하여 상세 페이지 진입
6. "Add Column" 버튼으로 칼럼 추가
7. 칼럼 name, type, required, description 편집
8. 자동 저장 확인: `{project}/entities/{entity}.md` 파일 확인

## File Locations

| Component | Path |
|-----------|------|
| Model | `app/lib/models/entity_document.dart` |
| Service | `app/lib/services/entity_service.dart` |
| List Page | `app/lib/screens/entity_list_page.dart` |
| Detail Page | `app/lib/screens/entity_detail_page.dart` |
| Sidebar Integration | `app/lib/screens/project_detail_screen.dart` |

## Markdown Format

생성되는 엔티티 파일 예시 (`entities/user.md`):

```markdown
# user

## columns

| name | type | required | description |
|------|------|----------|-------------|
| id | int | true | 고유 식별자 |
| email | string | true | 이메일 주소 |
| created_at | datetime | false | 생성 일시 |
```
