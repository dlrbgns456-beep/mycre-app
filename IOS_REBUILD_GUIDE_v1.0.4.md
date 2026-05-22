# iOS 재빌드 가이드 — v1.0.4 (2026-05-22)

## 변경 사항 요약
- `@capacitor/browser` 플러그인 추가 (Google OAuth 403 disallowed_useragent 수정)
- `signInWithGoogle()` → Chrome Custom Tabs / SFSafariViewController로 열리도록 변경
- `appUrlOpen` 딥링크 리스너 추가 (OAuth 콜백 처리)
- XSS 취약점 수정, AI 스캔 서버 검증, 에러 핸들링, 이미지 lazy loading 등

## 사전 조건
- macOS + Xcode 최신 버전
- Node.js 설치됨
- Apple Developer 계정 로그인 상태
- Git 접근 가능

---

## 1단계: 최신 코드 받기

```bash
cd ~/Desktop/게코앱
# 또는 mycre-app 클론 위치로 이동

git pull origin master
```

> 만약 로컬에 게코앱 폴더가 없다면:
> ```bash
> cd ~/Desktop
> git clone https://github.com/dlrbgns456-beep/mycre-app.git 게코앱
> cd 게코앱
> ```

---

## 2단계: 의존성 설치

```bash
npm install
```

`@capacitor/browser`가 package.json에 이미 포함되어 있으므로 자동 설치됨.

설치 확인:
```bash
ls node_modules/@capacitor/browser
```

---

## 3단계: Capacitor iOS 동기화

```bash
npx cap sync ios
```

이 명령어가:
- www/index.html을 iOS 프로젝트에 복사
- @capacitor/browser 네이티브 플러그인을 iOS에 추가
- 기타 플러그인 동기화

---

## 4단계: Xcode에서 버전 업데이트

```bash
npx cap open ios
```

Xcode 열리면:

1. 좌측 파일 트리에서 **App** 프로젝트 선택
2. **TARGETS → App** 선택
3. **General** 탭에서:
   - **Version**: `1.0.4` (MARKETING_VERSION)
   - **Build**: 이전 제출보다 높은 숫자 (기존이 몇이었는지 확인 후 +1)
   
> ⚠️ 이전 App Store 제출 때의 Build 번호보다 반드시 높아야 합니다.
> Xcode → Window → Organizer → 볏마루도감 → 이전 빌드 번호 확인

**또는 커맨드라인으로 변경:**
```bash
cd ios/App
# Version을 1.0.4로
sed -i '' 's/MARKETING_VERSION = .*/MARKETING_VERSION = 1.0.4;/' App.xcodeproj/project.pbxproj

# Build 번호를 5로 (이전보다 높게 조정)
sed -i '' 's/CURRENT_PROJECT_VERSION = .*/CURRENT_PROJECT_VERSION = 5;/' App.xcodeproj/project.pbxproj
cd ../..
```

---

## 5단계: 서명 확인

Xcode에서:
1. **Signing & Capabilities** 탭
2. **Team**: 본인 Apple Developer 계정 선택
3. **Bundle Identifier**: `com.lbeetle.byetmaru` 확인
4. **Automatically manage signing** 체크

---

## 6단계: 빌드 및 아카이브

1. Xcode 상단 디바이스 → **Any iOS Device (arm64)** 선택
2. **Product → Archive** (⌘ + Shift + Archive 없음, 메뉴에서 선택)
3. 빌드 완료까지 대기 (2~5분)

### 빌드 에러 발생 시:
```bash
# Pod 관련 에러
cd ios/App
pod install
cd ../..

# 클린 빌드
# Xcode에서 Product → Clean Build Folder (⌘ + Shift + K)
```

---

## 7단계: App Store에 업로드

1. Archive 완료되면 **Organizer** 창이 자동으로 열림
2. 최신 아카이브 선택 → **Distribute App** 클릭
3. **App Store Connect** 선택 → **Next**
4. **Upload** 선택 → **Next**
5. 옵션 확인 후 **Upload** 클릭
6. 업로드 완료까지 대기

---

## 8단계: App Store Connect에서 제출

1. https://appstoreconnect.apple.com 접속
2. **볏마루도감** 앱 선택
3. 새 버전 1.0.4 생성 (또는 기존 버전에 새 빌드 선택)
4. 업로드된 빌드 선택
5. **변경 내용(What's New)**:
   ```
   - Google 로그인 안정성 개선
   - 보안 및 성능 개선
   - 버그 수정
   ```
6. **심사를 위해 제출** 클릭

---

## 심사용 테스트 계정 (기존과 동일)
- 이메일: test@byetmaru.com
- 비밀번호: TestUser2026!

---

## 체크리스트

- [ ] `git pull origin master` 완료
- [ ] `npm install` 완료 (@capacitor/browser 포함)
- [ ] `npx cap sync ios` 완료
- [ ] Xcode 버전 1.0.4 / 빌드번호 업데이트
- [ ] 서명 설정 확인
- [ ] Archive 성공
- [ ] App Store Connect 업로드 완료
- [ ] 심사 제출 완료

---

## 참고
- Bundle ID: `com.lbeetle.byetmaru`
- GitHub: https://github.com/dlrbgns456-beep/mycre-app.git
- 브랜치: master
- Android는 v1.0.4 (versionCode 5)로 Google Play 비공개 테스트 제출 완료 (2026-05-22)
