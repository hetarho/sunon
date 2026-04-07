# Data Model: Policy 페이지

## Entities

### PolicyDocument

Policy 파일 하나의 전체 내용을 표현하는 모델.

| Field | Type | Description |
|-------|------|-------------|
| name | String | Policy 이름 (= `# ` 헤딩, = 파일명) |
| body | String | `# ` 헤딩 이후의 모든 내용 (자유 형식 마크다운) |

**Factory**:
- `PolicyDocument.empty()` → name: '', body: ''

**Constraints**:
- `name`은 비어있을 수 없음
- `name`은 파일 시스템 허용 문자만 가능 (영문, 숫자, 한글, 밑줄, 하이픈, 공백)

### PolicySummary

목록 표시용 요약 모델.

| Field | Type | Description |
|-------|------|-------------|
| name | String | Policy 이름 |
| filePath | String | 파일 절대 경로 |

## File Format

```markdown
# {name}

{body}
```

- 첫 번째 `# ` 라인 → `name`
- `# ` 라인 이후 빈 줄을 건너뛴 나머지 전체 → `body`
- 파일에 `# ` 헤딩이 없으면 파일명(확장자 제외)을 `name`으로 사용

## Relationships

- Policy는 다른 엔티티와 직접적인 관계 없음 (독립 파일)
- 프로젝트 경로 하위 `policies/` 디렉토리에 위치
- Spec 생성 시 모든 policy 파일이 컨텍스트로 사용됨 (읽기 전용 참조)

## State Transitions

없음. Policy는 stateless — 생성, 편집, 삭제만 존재.
