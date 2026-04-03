# 📍 SEENEAR (시니어)
> **"복지관 인증 시니어를 위한 AI 기반 하이퍼로컬 소일거리 매칭 플랫폼"**

**SEENEAR**는 일자리가 필요한 시니어(**요청자**)와 일상 속 도움이 필요한 지역 주민(**공고 등록자**)을 정밀하게 연결하는 **상생형 커뮤니티 케어 서비스**입니다. 1인 가구의 안전을 지키고, 시니어에게는 자신의 경험을 활용한 가치 있는 소일거리를 제공합니다.

---

## 🌟 서비스 철학: "경험을 가치로, 연결을 안전으로"
* **Active Senior:** 시니어의 풍부한 지역사회 경험을 '안심 에스코트' 및 '생활 보조'라는 전문적 소일거리로 전환합니다.
* **Welfare-Linked:** 익명의 구직자가 아닌, 지역 복지관을 통해 신뢰가 검증된 시니어 파트너(요청자)만을 매칭합니다.
* **Invisible Care:** 실시간 감시 대신, 지오펜싱 기술을 활용한 '비동기적 안전 관리'를 통해 서로의 프라이버시를 보호합니다.

---

## 👥 사용자별 핵심 여정 (User Journey)

### 1. 🙋‍♂️ 요청자 (Requester): "소일거리가 필요한 시니어"
* **AI 맞춤 일감 큐레이션:** **SentenceTransformer**가 내 역량 태그와 공고의 유사도를 분석하여, 나에게 가장 적합한 소일거리를 추천 점수순으로 제안합니다.
* **음성 기반 인터페이스 (STT/TTS):** 복잡한 타이핑 없이 음성으로 일감을 검색하고, 매칭 제안을 목소리로 확인하여 수락할 수 있습니다.
* **Leaflet 기반 활동 지도:** 내 활동 반경 내에 있는 일감들의 위치를 지도로 확인하고 효율적인 동선을 계획합니다.

### 2. 🏠 공고 등록자 (Owner): "도움이 필요한 지역 주민"
* **AI 자동 태깅 서비스:** **Gemini 1.5 Flash**가 등록된 요청 내용을 분석하여 일감 카테고리를 자동 분류, 최적의 시니어를 더 빨리 찾도록 돕습니다.
* **실시간 안심 모니터링:** 내가 요청한 업무를 수행 중인 시니어의 위치를 **Leaflet Map**과 **지오펜싱** 기술로 확인하여 안심하고 서비스를 이용합니다.

---

## ✨ 3대 핵심 기술 (Core Technology)

### 1. 🏷️ AI 기반 정밀 태그 추출 (Tagging)
* **Gemini 1.5 Flash**를 활용하여 비정형 구인 공고에서 핵심 키워드([#밤길동행], [#반찬보조], [#이동도움])를 추출하고 시니어의 역량과 매칭합니다.

### 2. 🔍 벡터 유사도 기반 시맨틱 추천 (Matching)
* **SentenceTransformer**로 텍스트의 의미를 벡터화하고, **pgvector**를 통해 시니어의 프로필과 일감 사이의 '의미적 유사도'를 계산하여 최적의 파트너를 큐레이션합니다.


### 3. 🗺️ Leaflet & PostGIS 기반 위치 서비스 (Spatial)
* **Leaflet Map**을 통한 직관적인 위치 시각화와 **PostGIS** 공간 연산을 활용한 실시간 지오펜싱(Geofencing)으로 안전한 서비스 수행을 보장합니다.


---

## 🏗 기술 스택 (Tech Stack)

| 분류 | 기술 스택 |
| :--- | :--- |
| **Backend** | **FastAPI**, **Uvicorn**, **Docker** |
| **Database** | **AWS RDS (PostgreSQL)**, **pgvector**, **PostGIS** |
| **AI Core** | **Gemini 1.5 Flash**, **SentenceTransformer** |
| **Frontend** | **Flutter**, **Leaflet Map** |
| **Infra** | **AWS (EC2, S3, RDS)** |

---

## 👥 SEENEAR 팀 정보 (Team SEENEAR)

| 역할 | 성함 | 주요 업무 |
| :--- | :--- | :--- |
| **Backend / Infra** | **손수민** | **요청자(시니어) 맞춤형 일감 추천 API** 개발 및 AWS/Docker 아키텍처 설계 |
| **Project Manager** | **홍지욱** | 소일거리 창출 비즈니스 모델 및 지역 복지관 파트너십 기획 |
| **UI/UX Design** | **최수현** | 시니어(요청자) 중심의 직관적 구직 인터페이스 및 지도 디자인 |
| **Frontend** | **최웅철** | Flutter 앱 개발, 사용자 역할별 API 연동 및 상태 관리 |
| **Frontend** | **김현수** | Leaflet 기반 위치 시각화 및 지오펜싱 이상 감지 로직 구현 |
| **AI Engineer** | **송동현** | 시니어 역량-일감 간 벡터 임베딩 및 유사도 알고리즘 최적화 |
| **AI Engineer** | **황정빈** | 비정형 텍스트 내 AI 태그 자동 추출 및 매칭 스코어링 시스템 개발 |

---

## 🚀 실행 가이드 (Quick Start)

### Backend (Docker)
```bash
docker-compose up --build -d
```

### Frontend (Flutter)
```bash
flutter pub get
flutter run --dart-define=BASE_URL=http://[YOUR_SERVER_IP]:8000/api
```
