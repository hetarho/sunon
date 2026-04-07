# Quickstart: Policy 페이지

## Prerequisites
- Flutter SDK (stable channel)
- 기존 sunon 앱이 빌드/실행 가능한 상태

## New Files
1. `app/lib/models/policy_document.dart` — PolicyDocument, PolicySummary
2. `app/lib/services/policy_service.dart` — CRUD, parse, serialize
3. `app/lib/screens/policy_list_page.dart` — 목록 페이지
4. `app/lib/screens/policy_detail_page.dart` — 상세/편집 페이지

## Modified Files
1. `app/lib/screens/project_detail_screen.dart` — case 2 연결

## Run
```bash
cd app && flutter run -d macos
```

## Verify
1. 프로젝트 진입 → 사이드바 "Policies" 클릭
2. "Policy 추가" → 이름 입력 → 상세 페이지 이동 확인
3. 제목 필드, 본문 에디터 입력 → 자동 저장 확인
4. 뒤로가기 → 목록에 항목 표시 확인
5. 삭제 → 확인 → 목록에서 제거 확인
