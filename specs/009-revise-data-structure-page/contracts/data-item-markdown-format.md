# Contract: 데이터 항목 마크다운 형식

**Version**: 2.0.0 | **Date**: 2026-04-07
**Supersedes**: 007-entity-page `contracts/entity-markdown-format.md` v1.0.0

## Overview

데이터 항목은 프로젝트의 `data/` 디렉토리 내 개별 마크다운 파일로 저장된다.

## File Location

```
{project_path}/data/{item_name}.md
```

## Format Specification

```markdown
# {item_name}

## 속성

| 속성명 | 속성 정보 |
|--------|----------|
| {attribute_name} | {attribute_info} |
```

### Rules

1. **H1 헤딩** (`# `): 정확히 1개, 데이터 항목 이름
2. **H2 속성 섹션** (`## 속성`): 마크다운 테이블 형식
3. **테이블 헤더**: `속성명 | 속성 정보` (고정, 2칸)
4. **테이블 구분선**: `|--------|----------|`
5. **데이터 행**: 파이프(`|`)로 구분된 2개 셀
6. **속성 정보**: 자연어 자유 텍스트. 개발 타입(int, float 등) 사용 금지

### Unknown Sections

`## 속성` 외의 `## ` 섹션은 파싱하지 않고 원본 그대로 보존한다.

## Examples

### Minimal (새 데이터 항목 생성 직후)

```markdown
# 회원

## 속성

| 속성명 | 속성 정보 |
|--------|----------|
```

### With Attributes

```markdown
# 회원

## 속성

| 속성명 | 속성 정보 |
|--------|----------|
| 이름 | 회원의 실명 |
| 이메일 | 로그인에 사용되는 이메일 주소 |
| 가입일 | 회원이 가입한 날짜 |
| 등급 | 일반, 실버, 골드, VIP 중 하나 |
| 보유 쿠폰 | 현재 사용 가능한 쿠폰 목록 |
```

## Changes from v1.0.0

| Aspect | v1.0.0 (007) | v2.0.0 (009) |
|--------|-------------|-------------|
| Directory | `entities/` | `data/` |
| Section heading | `## columns` | `## 속성` |
| Table columns | 5 (name, type, isList, required, description) | 2 (속성명, 속성 정보) |
| Data types | int, string, float, bool, datetime, text | 자연어 자유 텍스트 |
| Local types | `## type: {name}` | 제거 |
| Local enums | `## enum: {name}` | 제거 |
