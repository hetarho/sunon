# UI Contract: Policy 페이지

## Policy List Page (`PolicyListPage`)

### Props
- `projectPath`: String (required) — 프로젝트 루트 경로

### Layout
```
┌─────────────────────────────────┐
│ [+ Policy 추가]                 │
├─────────────────────────────────┤
│  정책 이름 A              [삭제] │
│  정책 이름 B              [삭제] │
│  정책 이름 C              [삭제] │
│  ...                           │
└─────────────────────────────────┘
```

### Behaviors
- 항목 클릭 → PolicyDetailPage로 전환 (inline, Navigator 미사용)
- 추가 → 이름 입력 AlertDialog → 생성 후 상세 페이지로 이동
- 삭제 → 확인 AlertDialog → 삭제 후 목록 갱신
- 빈 상태 → 안내 텍스트 + "Policy 추가" 버튼

## Policy Detail Page (`PolicyDetailPage`)

### Props
- `projectPath`: String (required)
- `policyFilePath`: String (required)
- `onBack`: VoidCallback (required)

### Layout
```
┌─────────────────────────────────┐
│ [←] 제목 텍스트 필드            │
├─────────────────────────────────┤
│                                 │
│  본문 텍스트 에디터              │
│  (multiline, 자유 형식)         │
│                                 │
│                                 │
└─────────────────────────────────┘
```

### Behaviors
- 제목 필드: 단일 라인 TextField, 변경 시 파일명 리네임 + 자동 저장
- 본문 에디터: 멀티라인 TextField (`maxLines: null`), 변경 시 자동 저장
- 자동 저장: 500ms 디바운스 (Entity/Product 패턴 동일)
- 뒤로가기: `onBack` 콜백 호출 → 목록으로 복귀
- 제목 중복 검사: 리네임 시 기존 policy와 이름 충돌 체크

## Policy Markdown Format Contract

### Parse (read)
```
Input:  "# 이메일 검증\n\n본문 내용..."
Output: PolicyDocument(name: "이메일 검증", body: "본문 내용...")
```

### Serialize (write)
```
Input:  PolicyDocument(name: "이메일 검증", body: "본문 내용...")
Output: "# 이메일 검증\n\n본문 내용..."
```

### Edge cases
- `# ` 없는 파일 → name = 파일명(확장자 제외), body = 파일 전체 내용
- 빈 파일 → name = 파일명, body = ''
- 본문에 `# ` 포함 → 첫 번째 `# ` 만 제목, 나머지는 본문의 일부
