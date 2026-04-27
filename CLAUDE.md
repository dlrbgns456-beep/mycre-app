# 볏마루도감 (ByetMaru) - 프로젝트 가이드

## 프로젝트 개요
크레스티드 게코(도마뱀붙이) 사육자를 위한 올인원 PWA 앱.
개체 등록, 급이/탈피/체중 기록, AI 모프 판별, 커뮤니티 기능 제공.

- 런칭일: 2026년 4월 30일
- 앱 URL: https://byetmaru.com
- 대표: 이규훈 (hoon / dlrbgns456@gmail.com)

## 사업자 정보
- 상호: 리비틀 (L.Beetle)
- 사업자등록번호: 104-16-65460
- 소재지: 인천광역시 연수구 컨벤시아대로 81, 5층 509-J630호(송도동, 드림시티)
- 업태: 정보통신업, 도매 및 소매업
- 종목: 응용 소프트웨어 개발 및 공급업, 전자상거래 소매업, SNS마켓
- 결제: 토스페이먼츠 (포트원 아님)
- 사업용 계좌번호: 본 문서에 미기재 (별도 안전한 곳에 보관)

## 파일 구조
```
게코앱/                    ← Git 루트 (이 폴더)
├── index.html             ← 앱 전체 (HTML+CSS+JS 단일 파일, ~12500줄)
├── manifest.json          ← PWA 매니페스트
├── icon-192.png           ← 앱 아이콘
├── icon-512.png           ← 앱 아이콘
├── CLAUDE.md              ← 이 파일
└── .git/                  ← Git
```
- 앱은 **단일 HTML 파일**(index.html)로 구성. 별도 빌드 없음.
- CSS 변수: `--bg: #0e1a10; --ac: #5ddc6a; --tx: #ddf0de`
- localStorage 키: `mycre_` 접두사 (기존 사용자 데이터 보존 위해 변경하지 말 것)

## 배포 파이프라인
```
index.html 수정 → git add → git commit → git push origin master
                                              ↓
                                    GitHub (dlrbgns456-beep/mycre-app)
                                              ↓
                                    Netlify 자동 배포 → byetmaru.com
```
- GitHub repo: https://github.com/dlrbgns456-beep/mycre-app.git
- 브랜치: master
- Netlify: push하면 자동 배포됨
- 배포 명령어:
```bash
git add -A
git commit -m "설명"
git push origin master
```

## 백엔드
- Supabase 사용 (DB + Auth + Edge Functions)
- Supabase MCP 연결되어 있음 (execute_sql, list_tables 등 사용 가능)

## 브랜딩 변경 이력
- 기존 이름: 마이크레 (MyCre) / mycre-gecko.netlify.app
- 현재 이름: 볏마루도감 (ByetMaru) / byetmaru.com
- 이메일: egh0208@naver.com → dlrbgns456@gmail.com
- fix_branding.py 스크립트가 크롭테스트 폴더에 있음 (마이크레→볏마루도감 치환)
- localStorage 키의 mycre_ 접두사는 의도적으로 유지 (기존 사용자 데이터 깨짐 방지)

## 주의사항
- 한글 '볏' (U+BCCF) 문자가 일부 도구에서 깨질 수 있음. bash heredoc이나 Write tool 사용 시 주의.
- index.html 수정 시 반드시 git push까지 해야 byetmaru.com에 반영됨
- manifest.json의 background_color/theme_color가 아직 #0e1a10 (어두운 초록) → 필요시 #FFF9EF/#2E7D57로 변경 검토

## 관련 폴더
- `크롭테스트/`: 마스터가이드, 브랜딩 스크립트, 패키징 가이드 등 문서
- `byetmaru-capacitor-project/`: Android/iOS 네이티브 빌드용 Capacitor 프로젝트

## 외부 서비스 현황 (2026-04-27 업데이트)
- 통신판매업: 신고 완료 (제 2026-인천연수구-1224 호)
- 에스크로(구매안전서비스): 확인증 발급 완료 (토스페이먼츠, A08-260424-0001)
- 토스페이먼츠: 연동 준비 완료 (통판+에스크로 충족)
- Google Play 개발자: 본인인증 대기중
- 카카오 비즈앱: 반려됨 → 재심사 준비 중 (사업자 정보+통신판매업 푸터 추가 완료, 서비스 동선 스크린샷 필요)
- Apple Developer: 보류 (맥북 구매 예정)
- 인스타그램: @byetmaru (352 팔로워)
- 베타 오픈채팅: https://open.kakao.com/o/giz3xEqi
- 베타 테스터: 31명 응답 / 27명 고유
- Claude: Max 플랜 사용중
- Cowork MCP 연결: Supabase, Gmail, Google Drive, Google Calendar, Notion, Netlify, Canva, Figma, Gamma
- 서비스 운영맵: 크롭테스트/볏마루도감_서비스_운영맵.docx 참고

## 인증(OAuth) 연동 현황
- Supabase 프로젝트: fatjjjwfauujgrvcihwd (ap-northeast-2)
- OAuth Callback URI: https://fatjjjwfauujgrvcihwd.supabase.co/auth/v1/callback
- 카카오 개발자 (앱 ID: 1440509)
  - REST API 키: b6a33392bbb490581e1e99f46f57e6ec
  - 클라이언트 시크릿: 활성화 ON (값은 카카오 콘솔에서 확인)
  - 로그인 리다이렉트 URI: 위 Callback URI와 동일하게 설정 완료
  - Supabase Auth 카카오 제공자: 활성화 + 키 동기화 완료 (2026-04-27)
- 구글 로그인: Supabase Auth 구글 제공자 활성화 완료
- Supabase URL 구성: 사이트 URL = https://byetmaru.com, 리디렉션 URL 8개 등록
