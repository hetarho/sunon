# Research: Project Scaffold

## Tech Stack Decisions

### Backend: Express 5.1.0

- **Decision**: Express 5.1.0 (ESM, TypeScript)
- **Rationale**: 사용자 지정 스택. Express 5는 ESM import 지원, async 에러 핸들링 내장. `import express from 'express'` 방식 사용.
- **Alternatives considered**: Fastify (더 빠르지만 사용자 지정 아님), Hono (경량이지만 사용자 지정 아님)

### Frontend: Vite 8.x + React 19.x

- **Decision**: `npm create vite@latest -- --template react-ts`로 scaffold
- **Rationale**: 사용자 지정 스택. Vite 8은 최신 안정 버전. React 19와 함께 TypeScript 템플릿 사용.
- **Alternatives considered**: Next.js (SSR 불필요), CRA (deprecated)

### Mobile/Desktop: Flutter 3.41.4 stable (Dart 3.11.1)

- **Decision**: `flutter create app`으로 scaffold, Dart 언어
- **Rationale**: 사용자 지정 스택. Flutter 3.41.4 stable (로컬 설치 버전). 웹 빌드도 지원 (Wasm).
- **Alternatives considered**: React Native (사용자 지정 아님)

### Project Structure

- **Decision**: 모노레포 도구 없이 3개 독립 디렉토리 (backend/, frontend/, app/)
- **Rationale**: Constitution "Speed Over Stability" — 도구 설정 오버헤드 최소화. 각 프로젝트가 독립 실행 가능.
- **Alternatives considered**: Turborepo (추후 필요 시 도입), nx (과도한 설정)

### BE-FE 연결

- **Decision**: 프론트엔드가 백엔드 `/api/health` 엔드포인트를 호출하여 "hi sunon" 메시지를 받아 표시
- **Rationale**: 최소한의 연결 확인. CORS 설정 포함.
- **Alternatives considered**: 프론트엔드 단독 표시 (BE 연결 확인 불가)
