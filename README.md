# source

sunon의 제품 명세 문서 디렉토리.
AI agent가 읽고 일관된 결과물을 만들 수 있도록 구조화된 문서 체계.

## 계층 구조

의존성은 안쪽(상위)에서 바깥쪽(하위)으로만 허용된다.
안쪽 계층을 수정하면 바깥 계층에 영향을 줄 수 있지만, 바깥 계층을 수정해도 안쪽은 안전하다.

```
product        ← 핵심 가치 (최상위, 의존 없음)
  ↓
entities       ← 도메인 최소 단위
  ↓
policies       ← 의사결정 기준
  ↓
userstories    ← 사용자 시나리오
elements       ← UI 구성 요소
  ↓
specs          ← 개발 작업 단위
```

## 각 계층

### product (product.md)
제품의 핵심 가치. 모든 문서는 이 가치에 위배되어서는 안 된다.
- 참조 가능: 없음
- 형식: 단일 md 파일

### entities (entities/)
프로덕트에서 사용되는 도메인 최소 단위.
- 참조 가능: product
- 형식: entity별 md 파일 (예: `entities/user.md`)

### policies (policies/)
ux, data, validation, formatting, system으로 나뉘는 의사결정 기준.
- 참조 가능: product, entities
- 형식: 카테고리별 디렉토리 내 md 파일 (예: `policies/validation/email.md`)

### userstories (userstories/)
유저가 얻을 수 있는 가치를 기준으로 작성된 시나리오. 추상화된 Gherkin 문법.
- 참조 가능: product, entities, policies
- 형식: story별 md 파일

### elements (elements/)
프로덕트를 구성하는 UI 요소 명세.
- 참조 가능: product, entities, policies
- 형식: element별 md 파일

### specs (specs/)
여러 userstory를 묶은 개발 작업 단위. 실제 데이터 기반의 구체적인 Gherkin으로 작성되어 e2e 테스트가 바로 가능한 수준.
- 참조 가능: 전부 (최하위 계층)
- 형식: spec별 md 파일

## 의존성 규칙

```
✅ spec → userstory, element, entity, policy 참조 가능
✅ userstory → entity, policy 참조 가능
✅ policy → entity 참조 가능
❌ entity → policy 참조 (안쪽이 바깥을 참조)
❌ policy → userstory 참조 (안쪽이 바깥을 참조)
```
