# 볏마루도감 (ByetMaru) - 프로젝트 가이드

## 프로젝트 개요
크레스티드 게코(도마뱀붙이) 사육자를 위한 올인원 PWA + 네이티브 앱.
개체 등록, 급이/탈피/체중 기록, AI 모프 판별, 커뮤니티 기능 제공.

- 앱 URL: https://byetmaru.com
- 대표: 이규훈 (hoon / dlrbgns456@gmail.com)
- 현재 상태: 안드로이드 비공개 테스트 진행 / iOS App Store 통과
- 정식 출시 예정: 2026년 5월 말~6월 초

## 사업자 정보
- 상호: 리비틀 (L.Beetle)
- 사업자등록번호: 104-16-65460
- 통신판매업: 제 2026-인천연수구-1224 호
- 에스크로: 토스페이먼츠 A08-260424-0001
- 소재지: 인천광역시 연수구 컨벤시아대로 81, 5층 509-J630호(송도동, 드림시티)
- 결제: 토스페이먼츠 (테스트 모드, 라이브 심사 대기)
- 사업용 계좌번호: 본 문서에 미기재

## 🚨 중요 — 단일 저장소 구조 (2026-05-22 통합 완료)
**이제 mycre-app 하나만 사용**. byetmaru-capacitor는 아카이브 예정.

```
게코앱/  (= dlrbgns456-beep/mycre-app)
├── www/                       ← 웹 코드 (Netlify가 여기서 배포)
│   ├── index.html             ← 앱 전체 (~16500줄, 2026-06-05 기준)
│   ├── sw.js                  ← Service Worker (v23, 2026-06-05)
│   ├── refund.html            ← 환불정책 (2026-06-05 신설)
│   ├── manifest.json
│   ├── privacy.html, support.html
│   ├── icon-*.png/svg
│   └── .well-known/assetlinks.json  ← 안드로이드 딥링크 검증용
├── android/                   ← Capacitor 안드로이드 빌드
├── ios/                       ← Capacitor iOS 빌드
├── assets/                    ← 아이콘 소스
├── appstore_screenshots/      ← App Store 스크린샷
├── capacitor.config.json      ← webDir: "www", server.url: byetmaru.com
├── byetmaru-keystore.jks      ← gitignore (로컬만)
├── netlify.toml               ← publish = "www"
├── .npmrc                     ← legacy-peer-deps=true (v7/v8 혼용 우회)
├── package.json               ← Capacitor 의존성
├── APP_STORE_GUIDE.md
├── CLAUDE.md
└── supabase_migration_*.sql
```

### 작업 분기 규칙
- **웹 작업 (95%)**: `www/index.html`, `www/sw.js` 수정 → git push → Netlify 자동 배포 → byetmaru.com 즉시 반영 → 모든 플랫폼(웹·안드·iOS) 자동 적용
- **네이티브 작업 (5%)**: `android/`, `ios/`, `capacitor.config.json` 수정 → AAB/IPA 재빌드 + 스토어 업로드

## 배포 파이프라인
```
www/index.html 수정 → git add → git commit → git push origin master
                                              ↓
                                    GitHub (dlrbgns456-beep/mycre-app)
                                              ↓
                                    Netlify 자동 배포 → byetmaru.com
                                              ↓
                          Capacitor 앱(server.url 설정)이 byetmaru.com 로드
                                              ↓
                                    웹/안드/iOS 모두 동기 갱신
```

## 백엔드
- Supabase 프로젝트: fatjjjwfauujgrvcihwd (ap-northeast-2)
- Supabase MCP 연결됨 (execute_sql, list_tables, apply_migration, deploy_edge_function 등)
- Edge Functions: send-admin-notification, delete-user, send-push, misting-cron, hatching-cron, confirm-payment, **morph-vision** (Gemini Vision API, 2026-06-05 신설)
- **Supabase ↔ GitHub Integration 활성** (2026-05-31~): `supabase/migrations/` 폴더에 새 .sql 푸시 시 master 브랜치에서 자동 적용
  - 기존 마이그레이션 백업: `_legacy/migrations_archive/` (로컬, gitignore)

## 🤖 AI 백엔드
- **Google Gemini API** — AI 모프 판별(유료 기능)에 사용
- 발급/사용량 관리: Google AI Studio (https://aistudio.google.com)
- 매일 무료 3회 / 추가 사용은 크레딧 결제 (5/15/30회 팩)

## 🖼️ 콘텐츠 자동화
- **HTML/CSS to Image API (HCTI)** — SNS 마케팅 이미지 자동 생성
- 대시보드: https://htmlcsstoimage.com/

## 외부 서비스 현황 (2026-06-03 갱신)
- 통신판매업: 신고 완료 (제2026-인천연수구-1224호)
- 에스크로: 토스페이먼츠 확인증 발급 완료
- 토스페이먼츠: 테스트 모드 연동 완료 (test_ck_yZqmkKeP8g9KW4EgwmyYVbQRxB9l), **라이브 심사 회신 발송 대기**
- Google Play: **비공개 테스트 재실시 (5/22~), v1.0.4 (versionCode 5) — 6/5 종료 예정**
- Apple App Store: **iOS 심사 통과 ✅ — 정식 출시 시점 결정 대기**
- 카카오 비즈앱: 승인 완료
- 인스타그램: @byetmaru
- 스레드: @byetmaru
- 베타 오픈채팅: https://open.kakao.com/o/giz3xEqi
- 베타 테스터: 51명 가입 / 45명 비공개 테스터
- 베타테스터 혜택: AI 판별 무제한 (is_beta_tester=true, 가입일 4/30 이전 25명 자동 부여)
- Claude: Max 플랜 사용중

## 🔐 인증(OAuth) 연동 현황
- OAuth Callback URI: https://fatjjjwfauujgrvcihwd.supabase.co/auth/v1/callback
- **카카오**: REST API 키 b6a33392bbb490581e1e99f46f57e6ec (앱 ID 1440509) — Kakao Developers 콘솔에서 관리
- **구글**: Supabase Auth 활성화 — Google Cloud Console "My First Project"에서 OAuth client ID 발급
- **Apple**: Service ID com.lbeetle.byetmaru.web (Team ID: L4GHAHN9TS, Key ID: X36UQ96KB2)
- **NAVER**: NAVER Developers 등록만 한 상태, 구현 예정 (signInWithNaver 함수 + Supabase Custom OAuth Provider 활성화)

### ⭐ 안드로이드 OAuth — Chrome Custom Tabs + Deep Link 방식 (해결됨 2026-05-22)
이전: WebView OAuth → 구글 "disallowed_useragent" 차단
해결:
1. `@capacitor/browser` 플러그인 — Chrome Custom Tabs 사용 (Google 차단 우회)
2. `@capacitor/app` 플러그인 — 딥링크 콜백 수신
3. AndroidManifest.xml deep link intent-filter (autoVerify=true)
4. `www/.well-known/assetlinks.json` — 도메인 소유권 증명 (SHA-256 2개 등록)
5. `signInWithGoogle()` 함수가 Capacitor 네이티브에서 Browser.open() 사용

코드 위치: `www/index.html` line ~10325 (signInWithGoogle 함수)

### iOS는 다름
- 소셜 로그인 버튼 모두 숨김 (Apple 4.8.0 정책)
- 이메일/비번 로그인만 노출
- AI 크레딧 결제도 차단 (Apple 3.1.1 IAP 정책)
- 다음 빌드 시 Sign in with Apple 정식 연동 예정

## 📱 빌드 정보

### 안드로이드 (v1.0.4 / versionCode 5)
- 빌드 폴더: 게코앱/android (한글 경로 Gradle 에러 시 C:\byetmaru-android 로 복사)
- 키스토어: byetmaru-keystore.jks (gitignore — 로컬만)
  - 비밀번호: byetmaru2026 / alias: byetmaru
  - 또는 android/app/byetmaru-release.jks 사용 가능
- 빌드 절차:
  ```bash
  cd 게코앱
  git pull
  npm install            # @capacitor/app, @capacitor/browser 등 설치
  npx cap sync android   # 네이티브에 동기화
  # Android Studio 에서 Build → Generate Signed Bundle (AAB)
  ```
- AAB 위치: android/app/release/app-release.aab
- SHA-256 인증서:
  - 앱 서명 키 (Play): `1C:08:07:72:02:41:BC:BC:53:A5:3A:D7:B1:73:DC:20:BC:59:24:C8:08:C7:CB:22:66:6F:5D:F4:1B:F9:3D:01`
  - 업로드 키: `E0:26:84:B5:62:EF:87:46:E4:71:34:6C:7C:17:68:49:62:5E:E8:31:72:47:F3:FE:4A:87:07:26:FB:07:8D:A6`

### iOS
- Bundle ID: com.lbeetle.byetmaru
- App Store: 심사 통과 ✅
- 심사용 계정: test@byetmaru.com / TestUser2026!
- 빌드 가이드: APP_STORE_GUIDE.md

## ⚙️ 기술 스택 주의사항
- Capacitor 패키지가 v7 core + v8 일부 플러그인 혼용 (legacy-peer-deps로 우회 중)
- 장기 과제: v7 또는 v8 한쪽으로 정렬 권장 (v1.1)
- `webDir`: www
- `server.url`: https://byetmaru.com (앱이 웹사이트 직접 로드)
- 한글 '볏' (U+BCCF) 일부 도구에서 깨질 수 있음
- localStorage 키 `mycre_` 접두사 유지 (기존 사용자 데이터 호환)

## 🎯 진행 중 / 남은 일
- [진행 중] 안드로이드 비공개 테스트 14일 재진행 (5/22 시작, **6/5 종료 예정**)
- [진행 중] 베타 테스터 피드백 수집
- [대기] iOS 정식 출시 시점 결정 (이미 심사 통과됨)
- [대기] 토스페이먼츠 회신 메일 발송 (라이브 심사용)
- [대기] 카카오 로그인도 CCT 방식 확인 (구글 됐으니 거의 확실히 OK)
- [신규] **NAVER 로그인 추가** — Supabase Custom OAuth + signInWithNaver()
- [v1.1] 위젯 (분무 카운트다운), 네이티브 푸시 알림, Capacitor 버전 정렬
- [v1.1] iOS Sign in with Apple, Apple IAP

## 📝 최근 주요 변경 (2026-06-05) — 대규모 기능 추가

### 🐛 버그/UX 수정
- Notification ReferenceError 가드 (옵셔널 체이닝 → typeof 가드)
- Capacitor Browser 플러그인 가드 + 폴백
- iOS 약관 "보기" 버튼 + 하단 약관 링크 클릭 안 됨 (label 분리)
- 자동 로그인 Optimistic Auth (localStorage 토큰 1분+ 유효 시 즉시 진입, 6초→3초 단축)
- SW v23 (캐시 강제 갱신)

### 🤖 AI 모프 추천 (큰 변화)
- **개체 등록 폼에 ✨ AI 모프 추천 통합** — 별도 스캔 페이지에서 진입점 추가
- **Gemini Edge Function** `morph-vision` (v16 deploy 완료, gemini-2.5-flash + gemini-2.0-flash fallback, 503 재시도 2회, timeout 12초)
- **모프 룰 v4** 보정 (제보 22건 기반, 바이컬러 8회 과예측·트익할 5회 누락 등 해결)
- 기존 룰 베이스 '빠른 추천' 버튼 제거 — Gemini만 노출
- ⚠️ **Gemini 키 충전 완료** (`...Kmow` byetmaru 프로젝트, Tier 1 선불), 시점에 따라 503 과부하 발생 가능

### 📋 UI/UX 대규모 개편
- **빈 상태(empty state) 통합 디자인** (그라데이션 박스 + 일러스트 + 액션 + 힌트)
  - `_renderEmptyState({icon, title, sub, actionText, actionFn, hint})`
- **개체 검색/필터 확장**: 🎛️ 시트 (모프·연령·정렬), 활성 필터 칩, 결과 카운트
- **체중 SVG 라인 차트** + 통계 카드 (현재/변화/평균·최고) + 기간 토글
- **탈피 주기 SVG 점·라인 차트** + 평균선 + 통계 카드
- **사진 갤러리** (개체 사진 + 갤러리 + 커뮤니티 연결 글 사진 자동 통합)
- **라이트박스** (풀스크린 + 좌우 스와이프 + ESC)
- **사육 기록 빠른 추가** ⚡ — 최근 체중/급여/탈피 1탭 복제
- **개체 카드 길게 누르기 메뉴** (편집/기록/갤러리/카드공유/공유/삭제)
- **개체 통계 페이지** (더보기 탭, 모프 분포 TOP 8/평균 체중·연령/기록 횟수)
- **사육장 업그레이드 카드** 클릭 → 해당 개체 시트에 바로 표시
- **모프 드롭다운 닫기 버튼** (sticky X, iOS WKWebView 흡수 문제 해결)
- **알림 설정 UI 일반화** (Capacitor 안내 + 탈피 알림 상태별 동적)

### 💬 커뮤니티 인스타/스레드 스타일
- **카드 디자인 개편**: 가로 → 세로 풀폭 (헤더 → 사진 → 액션바 → 본문)
- **인스타 액션바** (❤️ 💬 📤) + "좋아요 N개" 강조
- **사진 풀스크린** 탭 → 라이트박스
- **⋯ 빠른 메뉴** (본인: 수정/공유/삭제, 타인: 공유/신고/차단, 관리자: 🛡 즉시 삭제)
- **무한 스크롤** (IntersectionObserver, 50개 단위, "END OF FEED" 표시)
- **📸 스토리** (24시간 자동 만료, 그라데이션 링, 풀스크린 뷰어, 5초 자동 진행)
- **게시글 수정 기능** (본인 글 ✏️ 수정 버튼, edit 모드 재사용)

### 🛡 모더레이션
- 관리자 즉시 삭제 (게시글/댓글 RLS 정책 추가)
- 본인 인증 일반화 — 휴대폰 본인인증 일반/사업자 모두 가능 (운영팀 수동 검토 흐름)

### 💳 비즈/수익화
- 환불정책 페이지 신설 (`www/refund.html`) — 토스 라이브 심사 대응
- 푸터 전화번호 추가
- AI 사용 일일 한도 + 비용 추적 (베타무제한 / PRO무제한 / 일일3회 / 크레딧)
- AI 사용 로그 DB 기록 (`ai_usage_logs` 테이블, 토큰/비용 자동 계산)

### 🗄 DB 신설 테이블/컬럼
- `ai_usage_logs` — AI 사용 추적
- `gecko_photos` — 개체별 갤러리 사진
- `stories` — 인스타 스토리 (24h 자동 만료)
- `profiles.phone_number, phone_verified_at` 컬럼 추가
- `morph-vision` Edge Function (Gemini Vision API 호출)

### ⏰ pg_cron 자동화 작업 (2026-06-05 등록)
| 이름 | 스케줄 | 동작 |
|---|---|---|
| `delete-expired-stories` | 매일 KST 04:00 | 24h+ 스토리 DELETE |
| `cleanup-old-debug-logs` | 일요일 KST 04:00 | 30일+ debug_logs DELETE |
| `cleanup-old-admin-notifications` | 일요일 KST 04:30 | 90일+ admin_notifications DELETE |
| `misting-alarm-cron` | 매 5분 | (기존) 분무 알림 |
| `hatching-alarm-cron` | 매일 KST 08:00 | (기존) 부화 알림 |

확인: `SELECT jobname, schedule, active FROM cron.job ORDER BY jobid;`

### 🚧 미해결 / 다음 작업 (다음 대화에서 이어할 것)
- [확인 필요] Gemini 키 503 과부하 — 시간 따라 자연 해결, 안 되면 모델 우선순위 변경 (`gemini-1.5-flash` primary로)
- [v1.1 빌드 필요] 네이티브 푸시 알림 (`@capacitor/push-notifications`)
- [v1.1 빌드 필요] AdMob 광고 통합
- [v1.1 빌드 필요] iOS Sign in with Apple
- [라이브 심사 후] 토스 결제 → PRO 평생 라이센스 (29,900원 추천)
- [라이브 심사 후] 거래 수수료 (분양 1건당 3-5%)
- [선택] Storage 정리 Edge Function (story_*.jpg 파일은 stories DELETE 후 남음)
- [선택] 댓글 인라인 (Phase B — 카드 안에 미리보기 + 입력창)
- [선택] 개체 등록 시 여러 장 사진 입력
- [선택] 사업자 인증 검토 1건 (`rnjssmd010@gmail.com` 4280603527) — 거래 활성화 시점

## 📝 이전 주요 변경 (2026-05-31)
- **Supabase ↔ GitHub Integration 활성화** — `supabase/migrations/`에 푸시 시 자동 적용
- **단일 통합 폴더**: ~/Desktop/볏마루도감 (mycre-app 코드 + docs/keys/business/records 통합, 윈도우/맥 워크플로우 분리)
- mycre-beta Netlify 프로젝트 정리 (사용 안 함)

## 📝 이전 주요 변경 (2026-05-22)
- 단일 저장소 통합: byetmaru-capacitor → mycre-app 흡수
- 안드로이드 구글 OAuth 완전 해결 (CCT + Deep Link + assetlinks.json)
- Netlify peer dep 충돌 해결 (.npmrc + netlify.toml)
- v1.0.4 빌드 + Play Console 업로드

## 💡 새 채팅에서 작업 시작 시
1. `git pull` 로 최신 코드 받기
2. 웹 작업이면 → www/index.html 수정 → git push
3. 네이티브 작업이면 → android/ or ios/ 수정 → 빌드 필요 알림
4. 이 CLAUDE.md 가 최신 상태 — 여기서 컨텍스트 파악 가능

### 새 대화 시작 멘트 예시
```
볏마루도감 작업 이어서 할게.

CLAUDE.md 먼저 읽고 컨텍스트 파악해줘.
특히 '최근 주요 변경 (2026-06-05)' 섹션에 어제까지 진행한 거 다 정리돼 있어.

오늘 할 일: [여기에 작업 적기]
```

또는 컨텍스트만 확인하려면:
```
git log --oneline -30  # 최근 커밋 30개
```

### 어제(2026-06-05) 작업 빠른 참조용 커밋
- `12b0dfb` 스토리 (24h 만료)
- `3983ab7` 무한 스크롤
- `1209854` 관리자 즉시 삭제
- `1a68417` 인스타/스레드 카드 디자인
- `41d5cad` 본인인증 일반화
- `988617f` 갤러리 사진 추가 + Gemini v16
- `9199710` AI 사용 한도 + DB 로그
- `45a7df0` AI 모프 추천 통합 (Gemini)
- `f2c5fb7` 체중 SVG 차트
- `750fa55` 개체 검색/필터 확장
- `6dccd8a` 빈 상태 디자인 통합
- `e5b763f` Optimistic Auth
- `f74e358` Notification + Browser 가드
