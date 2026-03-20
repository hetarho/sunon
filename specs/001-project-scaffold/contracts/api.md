# API Contract: Project Scaffold

## GET /api/health

Health check 엔드포인트. 프론트엔드가 백엔드 연결 확인 및 메시지 수신에 사용.

**Request**: 없음

**Response** (200 OK):
```json
{
  "message": "hi sunon"
}
```

**Error**: N/A (scaffold 단계, 에러 핸들링 최소)
