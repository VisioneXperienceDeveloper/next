# Next 1.0.0 출시 절차

## 1. 소유자 입력 확정

release-config.json에 Team ID, 실제 Bundle ID 등록 상태, App Store ID/SKU, 심사 담당자 성명·전화, 가격·국가, EU trader 상태를 기록합니다. 비밀번호, 인증서, API private key는 이 폴더에 저장하지 않습니다.

## 2. 공개 문서 게시

legal의 영문·한국어 문서를 검토해 시행일을 정합니다. 웹사이트의 실제 호스팅·접속 로그 정책이 별도 문서와 일치하도록 확인합니다. render-pages.py로 HTML을 생성한 뒤 다음 URL의 본문으로 게시합니다.

- 개인정보: https://www.visionexperiencedeveloper.com/en/policies/next
- 지원: https://www.visionexperiencedeveloper.com/en/supports/next

web-preview HTML은 로컬 검토용 링크를 사용합니다. 기존 사이트에 이식할 때 언어 전환·상호 링크를 실제 사이트 경로로 바꾸고 개인정보 초안/시행일 문장을 공개본으로 갱신합니다. 새 페이지를 익명 브라우저에서 열어 로그인 없이 HTTPS 200과 연락처 표시를 확인합니다. 2026-09-10 소유자가 지정한 EN/KO 공개 URL 4개를 정상 확인했습니다.

## 3. Xcode 빌드와 서명

Next.xcodeproj → Next target → Signing & Capabilities에서 사용자의 Developer Team을 선택합니다. Bundle ID가 com.visionexperiencedeveloper.next인지 확인합니다. iPhone용 1.0.0 (1), iOS 17 이상입니다. 이미 같은 build를 업로드했다면 build 번호를 증가시킵니다.

Xcode 26 이상과 iOS 26 SDK 이상으로 Archive합니다. 최소 실행 버전 iOS 17과 빌드 SDK 버전은 서로 다른 설정입니다. [현재 Apple 업로드 요구사항](https://developer.apple.com/news/upcoming-requirements/)

```sh
xcodebuild -project Next.xcodeproj -scheme Next -configuration Release   -destination 'generic/platform=iOS'   -archivePath build/Next.xcarchive archive
```

이 명령은 적절한 인증서/프로파일 및 Team 설정 후 실행합니다. 임의 Team ID로 서명하지 않습니다. Organizer에서 Privacy Report, entitlements, 버전/아이콘을 검토하고 Validate App을 수행합니다. ExportOptions.plist의 teamID를 확정한 뒤 필요하면 내보냅니다.

## 4. 실기기·TestFlight

QA 체크리스트를 서명한 동일 빌드에서 수행합니다. 신규 설치 전체 루프, 앱 강제 종료 후 보존, 회고 생략, 업데이트 설치 보존, 오프라인, 키보드, VoiceOver, 큰 글자, 다크 모드, 삭제 확인을 검증합니다. iOS 17 최소 환경과 최신 OS를 포함합니다. 시뮬레이터 테스트만으로 이 단계를 완료 처리하지 않습니다.

## 5. 스토어 입력·검토

metadata의 문구, screenshots의 실제 화면, Review Notes를 입력합니다. 최종 업로드 빌드와 캡처 UI가 동일한지 대조합니다. 개인정보·연령·권리·암호화 응답을 확정하고 required fields 누락을 확인합니다.

```sh
python3 release/app-store/scripts/validate.py --submission
```

## 6. 심사와 출시

등록 내용과 빌드를 마지막으로 검토한 후 제출합니다. 승인되면 지원 페이지와 설치 링크를 확인하고 지정한 방식으로 출시합니다. 2026-09-10 빌드 2 업로드까지 완료했습니다. 심사 제출·공개 상태는 readiness.md에서 확인합니다.

## 출시 후 문제 대응

개인 콘텐츠가 포함되지 않은 재현 순서·OS·앱 버전으로 문제를 분류합니다. 데이터 보존 문제라면 신규 배포를 멈추고 재현과 복구 가능성을 먼저 확인합니다. 로컬 기록을 초기화하도록 일반 사용자에게 무조건 안내하지 않습니다. 앱 업데이트는 store를 삭제하지 않고 진행해야 합니다.
