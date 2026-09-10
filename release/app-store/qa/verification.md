# 검증 기록

## 최신 배포·미디어 검증 (2026-09-10 추가)

아래 이전 기록의 서명 실패·캡처 대기·URL 미확인 상태는 이 추가 기록으로 대체됩니다.

- Liquid Glass 적용 Release에서 실제 핵심 흐름을 실행·녹화하고 새 스크린샷을 캡처했습니다. [미디어 안내](../creative/README.md).
- EN/KO 스크린샷 8장과 영상 2편의 규격·디코딩·레이아웃/시각 검증 통과. [기술 결과](../evidence/media-verification.json).
- 빌드 1 배포 서명·업로드 성공. 이후 빌드 2는 About의 두 URL과 빌드 번호만 변경했습니다.
- 빌드 2 Archive/Export 성공, strict codesign 검증 및 1024 아이콘 3종 포함 확인. 실행 바이너리 안의 새 정책·지원 URL 확인, 예전 정책 URL 부재 확인. [빌드 2 검증](../evidence/build2-verification.json).
- 빌드 2 App Store Connect 업로드 성공 15:51:28 AEST. 실기기 테스트 통과를 뜻하지 않습니다.
- 공개된 EN/KO 정책·지원 페이지 4개를 브라우저에서 정상 확인했습니다. 지원 페이지 오류는 별도 웹사이트 작업의 배포 완료 후 해소됐습니다.
- 실기기·TestFlight·최소 iOS 17 QA 미실행. 기존 자동 테스트 수치는 각 기록 시점에만 해당합니다.


날짜: 2026-09-10 (Australia/Sydney). 도구 산출물 파일명의 날짜는 UTC입니다.

Release 구성도 iPhone 17 Pro Max에서 빌드·설치·실행했습니다. 배포 서명 Archive와는 구분합니다.

## 통과한 검사

| 실행 | 환경 | 결과 |
|---|---|---|
| FirstFlowTests + NextTests | iPhone 16e / iOS 18.4 | 20개 통과: 도메인·영속성 16, 첫 흐름 UI 4 |
| CoreLoopUITests 완료/회고/삭제 | iPhone 17 Pro Max / iOS 26.5 | 2개 통과 |
| 큰 글자 완료/회고/Journey | iPhone 16e / iOS 18.4, AX 최대 글자·Dark Mode | 1개 통과 |

합계 23개 서로 다른 테스트가 통과했습니다. 모델 생성, 단일 활성 Step 제한, 완료 시점, Reflection 자격/중복/공백, 새 Step, Journey 정렬/월 그룹, cascade 삭제, 디스크 container 재생성, 앱 종료·재실행, 편집 취소/저장, 완료 직후 중단, 삭제 취소/확인 등을 포함합니다.

처음 Journey 자동 대비 검사에서 보조 날짜 텍스트가 경계값으로 실패했습니다. 해당 보조 텍스트를 조정한 뒤 CoreLoopUITests를 다시 실행해 통과했습니다. Home/Journey의 contrast, hitRegion, sufficientElementDescription 검사를 수행했습니다. 전체 VoiceOver 사용성 검증을 자동 감사 통과로 대체하지 않았습니다.

큰 화면의 실제 Welcome, Home, Step, Reflection, Journey PNG를 육안 검토했습니다. 화면 내용/줄바꿈/주요 버튼과 각 이미지의 해상도 및 알파 유무를 확인했습니다. 작은 화면의 최대 글자 다크 모드 추가 캡처는 evidence/large-text-final에 보관합니다.

## 산출물 경로

XcodeBuildMCP workspace: `~/Library/Developer/XcodeBuildMCP/workspaces/role-you-are-a-senior-ios-2-0b13402349ff/`

- 20개 테스트: `result-bundles/test_sim_2026-09-09T14-34-41-365Z_pid34341_0f263f0b.xcresult`
- 전체 루프 2개: `result-bundles/test_sim_2026-09-09T14-30-00-151Z_pid34341_fe3dc70d.xcresult`
- 큰 글자 1개: `result-bundles/test_sim_2026-09-09T14-44-06-932Z_pid34341_2124622e.xcresult`

복사한 요약과 스크린샷 출처는 ../evidence/에 있습니다. 원본 xcresult는 위 도구 작업공간에 보관합니다.

## 미검증 또는 환경 제한

- iOS 17 최소 버전 실기기/런타임, 실제 haptic, 수동 VoiceOver, Reduce Motion 실기기 사용성, 전체 회전·키보드 조합.
- 서명한 업데이트 설치와 TestFlight, Organizer 배포 검증.
- 임의 disk-full/손상/실제 I/O 오류의 모든 복구 경로. read-only 거부 테스트는 그 전체를 증명하지 않음.
- 공개 Privacy/Support URL: 현재 환경 DNS 접근 실패. 공개 서버의 상태를 단정하지 않고 확인 대기.
- unsigned Archive 시도는 actool이 격리 환경의 CoreSimulator 서비스/런타임에 접근하지 못해 실패. 서명한 IPA 없음.
- HTML 문서는 생성/정적 검사를 수행했으나 브라우저의 로컬 파일 URL 정책이 미리보기를 막아 브라우저 시각 검증은 수행하지 못함.

출시 체크리스트는 checklist.csv를 참고합니다. 초기 단계 검증 이미지 docs/screenshots는 이전 개발 증거이며 최신 스토어 이미지와 구분합니다.

최대 접근성 글자 크기에서는 Journey의 날짜를 본문 위에 배치해 읽는 폭을 넓혔고 재검사를 통과했습니다. 미사용 편집 시트 경로와 중복된 StepEditor 편집 분기도 제거했습니다.

최종 캡처 재실행에서 XCTest가 사라진 키보드 Done 버튼을 다시 찾는 타이밍 실패가 한 번 발생했습니다. 입력 후 저장 버튼을 직접 사용하도록 불필요한 키보드 닫기 조작을 제거하고 같은 전체 루프를 재검사했습니다.

최종 UI 캡처 재검사 통과: `test_sim_2026-09-09T14-48-56-040Z_pid34341_5649627d.xcresult`. 최신 실제 화면은 evidence/screenshots-final에서 내보냈습니다.

최종 Release 빌드·설치·실행 성공: `build_run_sim_2026-09-09T14-50-46-283Z_pid34341_352f39fc.log`. 경고/컴파일 오류 없음. evidence/release-build-final.log에 사본 보관. Bundle ID와 1.0.0 (1), 최소 iOS 17.0을 빌드된 Info.plist에서도 확인했습니다.

## 키보드 동작 수정 (추가 검증)

Done 버튼을 제거하고 입력창 바깥 터치로 키보드를 닫도록 변경했습니다. iOS 26.5에서 6개 입력 흐름을 거치는 전용 UI 테스트 1개가 통과했고 Release 빌드·설치·실행도 성공했습니다. 자세한 결과는 소스의 docs/Verification.md 마지막 항목에 있습니다. 기존 스토어 스크린샷은 이 변경 전 캡처이며, Reflection 이미지에는 이전 Done 버튼이 남아 있으므로 제출 전 새 화면으로 교체해야 합니다.

## Liquid Glass 디자인 변경 — iOS 26 유지

iOS 27은 디자인 참고 방향이며 실제 실행 환경은 iOS 26.5 / Xcode 26.6입니다. 주요 버튼·완료 조작부·하단 액션 영역에 iOS 26용 네이티브 Liquid Glass를 적용했습니다. Release 컴파일은 성공했으며, 시뮬레이터 서비스 지연으로 변경 후 실행 검증과 새 스크린샷 촬영은 아직 완료되지 않았습니다. 이전 테스트 통과 수치는 이번 디자인 변경 전 결과입니다. 현재 스토어 스크린샷은 새 스타일 검증 후 교체해야 합니다.
