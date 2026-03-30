# Data Model: Product 페이지 (Product Page)

**Date**: 2026-03-30 | **Branch**: `006-product-page`

## Entities

### ProductDocument (신규)

| Field | Type | Description |
|-------|------|-------------|
| name | String | 프로덕트 이름 (`# product` 다음 줄, 폴더명과 동기화) |
| mission | String | 프로덕트 미션 (`## mission` 본문) |
| principles | List\<String\> | 핵심 원칙 목록 (`## principles`의 `- ` 항목들) |
| unknownSections | List\<RawSection\> | 미인식 섹션 원본 보존 (FR-010) |

### RawSection (신규, 보조)

| Field | Type | Description |
|-------|------|-------------|
| heading | String | 섹션 헤딩 (예: `## custom`) |
| body | String | 섹션 본문 (원본 텍스트 그대로) |

## State Transitions

```text
[Product 메뉴 선택] → (파일 읽기) → [폼 표시]
[폼 표시] → (필드 수정) → [디바운스 타이머 시작]
[디바운스 만료] → (이름 변경 감지?) → [폴더 rename] → [product.md 저장]
[디바운스 만료] → (이름 동일) → [product.md 저장]
[폴더 rename 실패] → [오류 표시, 이전 이름 복원]
```

## Markdown Format

```markdown
# product
{name}

## mission
{mission}

## principles
- {principle 1}
- {principle 2}
```

### 파싱 규칙

1. `# product` 다음 비빈 줄이 `name`
2. `## {key}` 줄로 섹션 분리
3. 알려진 키: `mission`, `principles`
4. `principles`: `- ` 접두사 줄만 수집
5. 그 외 `##` 섹션은 unknownSections에 보존

### 직렬화 규칙

1. canonical 순서: name → mission → principles
2. 빈 필드는 헤딩만 유지
3. 빈 Principle 항목 제외
4. 미인식 섹션은 정규 섹션 뒤에 추가
5. 파일 끝 개행 1개
