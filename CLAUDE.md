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
│   ├── index.html             ← 앱 전체 (~13700줄)
│   ├── sw.js                  ← Service Worker (v22)
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
- Edge Functions: send-admin-notification, delete-user, send-push, misting-cron, hatching-cron, confirm-payment
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

## 📝 최근 주요 변경 (2026-05-31)
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
