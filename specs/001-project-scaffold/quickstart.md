# Quickstart: Project Scaffold

## Prerequisites

- Node.js 20+
- Flutter SDK 3.24+ (stable channel)
- npm

## Backend (Express)

```bash
cd backend
npm install
npm run dev
# → http://localhost:3000/api/health → {"message": "hi sunon"}
```

## Frontend (Vite + React)

```bash
cd frontend
npm install
npm run dev
# → http://localhost:5173 → 화면에 "hi sunon" 표시
```

## Flutter App

```bash
cd app
flutter pub get
flutter run
# → 앱 화면에 "hi sunon" 표시
```

## 전체 실행 (동시)

각 터미널에서 위 명령을 개별 실행. 프론트엔드는 백엔드가 실행 중일 때 API에서 메시지를 가져옴.
