# 볏마루도감 - iOS App Store 심사 제출 가이드

## 1단계: 맥북에서 프로젝트 준비

```bash
# 1. GitHub에서 클론 (맥북 터미널에서)
cd ~/Desktop
git clone https://github.com/dlrbgns456-beep/mycre-app.git byetmaru-capacitor

# 2. Capacitor 프로젝트 폴더로 이동
# ⚠️ Capacitor 프로젝트는 별도 폴더! Git repo의 index.html과는 다름
# 윈도우에서 byetmaru-capacitor-project 폴더를 맥북으로 복사하세요
# (AirDrop, USB, Google Drive 등)

# 3. 의존성 설치
cd byetmaru-capacitor-project
npm install

# 4. 웹 에셋 동기화
npx cap sync ios

# 5. Xcode에서 열기
npx cap open ios
```

## 2단계: Xcode 설정

### Signing & Capabilities
1. Xcode에서 **App** 타겟 선택
2. **Signing & Capabilities** 탭
3. **Team**: 방금 가입한 Apple Developer 계정 선택
4. **Bundle Identifier**: `com.lbeetle.byetmaru` (이미 설정됨)
5. **Automatically manage signing** 체크
6. Provisioning Profile 자동 생성됨

### General 설정 확인
- **Display Name**: 볏마루도감
- **Bundle Identifier**: com.lbeetle.byetmaru
- **Version**: 1.0.0
- **Build**: 1
- **Deployment Target**: iOS 16.0 (권장)
- **Device Orientation**: Portrait만 체크 (세로 전용이면)

### Info.plist 추가 항목 (필요시)
앱에서 카메라/사진 접근한다면:
- `NSCameraUsageDescription`: "게코 사진을 촬영하기 위해 카메라 접근이 필요합니다"
- `NSPhotoLibraryUsageDescription`: "게코 사진을 업로드하기 위해 사진 접근이 필요합니다"

## 3단계: 빌드 & 아카이브

```
1. Xcode 상단바 → 디바이스를 "Any iOS Device (arm64)" 선택
2. Product → Archive (⌘ + Shift + B 아님! Product > Archive)
3. 빌드 성공하면 Organizer 창 열림
4. "Distribute App" 클릭
5. "App Store Connect" 선택 → Next
6. "Upload" 선택 → Next
7. 옵션 기본값 유지 → Next → Upload
```

## 4단계: App Store Connect 설정

### 기본 정보
- **앱 이름**: 볏마루도감
- **부제**: 크레스티드 게코 올인원 사육 도우미
- **번들 ID**: com.lbeetle.byetmaru
- **SKU**: byetmaru-app-001
- **기본 언어**: 한국어

### 카테고리
- **주 카테고리**: 라이프스타일
- **보조 카테고리**: 참고 (Reference)

### 앱 설명 (한국어)
```
크레스티드 게코 사육의 모든 것, 볏마루도감!

🦎 개체 등록 & 관리
나만의 게코 프로필을 등록하고 모프, 성별, 해칭일, 구매 정보까지 한눈에 관리하세요.

📊 성장 기록 (체중·급이·탈피)
체중 변화를 그래프로 추적하고, 급이 및 탈피 기록을 간편하게 남기세요.

🤖 AI 모프 판별
사진 한 장으로 게코의 모프를 AI가 분석해드립니다.

👥 사육자 커뮤니티
다른 사육자들과 정보를 공유하고, 자랑하고, 질문하세요.

📋 환경부 신고 PDF
사육 개체 현황을 환경부 신고 양식에 맞춰 PDF로 출력합니다.

볏마루도감은 크레스티드 게코 사육자를 위해 만들어진 전문 앱입니다.
초보 사육자부터 브리더까지, 사육의 모든 과정을 함께합니다.
```

### 키워드 (100자 제한, 쉼표 구분)
```
크레스티드게코,게코,도마뱀,파충류,사육,모프,브리딩,탈피,급이,체중,커뮤니티
```

### 지원 URL
```
https://byetmaru.com
```

### 개인정보 처리방침 URL
```
https://byetmaru.com (앱 내 개인정보처리방침 페이지)
```
⚠️ Apple은 별도 URL을 요구합니다. byetmaru.com에 /privacy 경로를 만들거나, 
앱 내 개인정보처리방침이 웹에서도 접근 가능해야 합니다.

### 연락처
- **이름**: 이규훈
- **이메일**: dlrbgns456@gmail.com

### 앱 심사 정보
- **로그인 필요 여부**: 예 (카카오/구글 소셜 로그인)
- **데모 계정**: 심사용 계정 제공 필요 → 이메일 로그인 또는 테스트 계정 준비
- **심사 메모**: 
```
이 앱은 크레스티드 게코(파충류) 사육자를 위한 관리 도구입니다.
주요 기능: 개체 등록, 성장 기록(체중/급이/탈피), AI 모프 판별, 커뮤니티.
웹앱(byetmaru.com)을 Capacitor로 감싼 하이브리드 앱입니다.
소셜 로그인(카카오/구글)으로 이용 가능합니다.
```

### 스크린샷
- **iPhone 6.7" (필수)**: `appstore_screenshots/` 폴더에 4장 준비됨 (1290x2796)
  - ios_01_main.png: 메인 화면
  - ios_02_ai.png: AI 모프 판별
  - ios_03_growth.png: 성장 기록
  - ios_04_community.png: 커뮤니티

### 앱 개인정보 보호
Apple Privacy Nutrition Labels 작성 필요:
- **수집하는 데이터**: 이메일 주소, 이름, 사진, 사용 데이터
- **데이터 용도**: 앱 기능, 계정 관리
- **제3자 공유**: 없음 (Supabase 자체 호스팅)
- **데이터 추적**: 없음

### 수출 규정 (Export Compliance)
- 앱이 암호화를 사용하나요? → **예** (HTTPS 통신)
- 면제 가능한 표준 암호화? → **예** (표준 HTTPS/TLS만 사용)

## 5단계: 심사 제출

1. App Store Connect에서 빌드 선택
2. 모든 메타데이터 입력 확인
3. **"심사를 위해 제출"** 클릭
4. 보통 24~48시간 내 심사 결과

## ⚠️ 주의사항

### 흔한 리젝 사유 & 대비
1. **웹앱 래퍼 리젝 (4.2)**: Capacitor 앱이 단순 웹뷰로 판단될 수 있음
   - 대응: 카메라, 푸시 알림 등 네이티브 기능 활용 강조
   - 심사 메모에 네이티브 기능 명시
2. **개인정보 처리방침 누락**: 반드시 접근 가능한 URL 필요
3. **심사용 로그인**: 소셜 로그인만 있으면 테스트 계정 제공 필요
4. **스크린샷 불일치**: 실제 앱 화면과 다르면 리젝

### 심사용 계정 준비 (중요!)
Apple 심사팀이 로그인할 수 있도록:
- 이메일+비밀번호 로그인 기능 추가 (Supabase Auth에 이미 있을 수 있음)
- 또는 별도 테스트 계정 만들어서 심사 정보에 기재
