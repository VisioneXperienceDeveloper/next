# App Store 개인정보·콘텐츠·암호화 답변 근거

작성: 2026-09-10. 아래는 현재 소스의 기술적 검토이며 계정 소유자의 App Store Connect 선언을 대신하지 않습니다.

| 항목 | 현재 구현과 제안 | 제출 전 확인 |
|---|---|---|
| App Privacy | 앱에 기록한 내용은 로컬 SwiftData 저장. 서버/분석/광고 SDK 없음. 앱의 데이터 수집 없음이 예상 답변 | 배포 바이너리와 이메일 문의의 선택적 제공 예외 조건까지 검토 후 확정 |
| Tracking | 추적 없음, ATT 요청 없음 | 포함 SDK가 변경되지 않았는지 확인 |
| 계정 | 생성/로그인 없음 | 로그인 요구 없음 |
| 사용자 콘텐츠 | 개인 기기에서 작성하는 비공개 문장. 공개 공유·피드·채팅 없음 | 설문에서 공개 UGC와 개인 입력을 구분하여 실제 정의에 따라 답변 |
| 연령 | 성인 소재/도박/광고/웹 탐색/건강 조언을 제공하지 않음 | 최신 전체 설문 입력 후 Apple이 산출한 등급 확인. 4+ 임의 확정 금지 |
| Kids | 아동 대상 앱으로 설계하지 않음 | Kids Category 선택하지 않음 |
| 암호화 | 앱 자체 암호화 구현·외부 암호화 라이브러리 없음. OS 기능 사용 | OS-only 예외 해당 여부 검토 후 수출 규정 질문 응답; 계정에서 확정 |
| 권리 | 자체 코드, 생성한 브랜드 이미지, 자체 테스트의 가상 예문 | 상표 Next 이름 사용/등록 가능 여부와 생성 이미지 최종 권리 검토 |
| EU DSA | 판매자의 사업자 여부는 개발자가 판단 | trader/non-trader 상태와 공개 연락처 정확히 입력 |
| 접근성 표시 | Dynamic Type/semantic labels/Reduce Motion 구현 | 모든 일반 작업의 VoiceOver·더 큰 텍스트·대비를 실기기로 검증한 기능만 선언 |

PrivacyInfo.xcprivacy는 추적 false, 수집 데이터 없음, 앱이 직접 사용하는 선언 대상 API 없음으로 구성되어 있습니다. 이 파일과 App Store의 개인정보 응답은 별개입니다. Archive의 Privacy Report에서 종속성과 Required Reason API를 다시 확인합니다. 현재 외부 패키지 의존성은 없습니다.

근거: [App Privacy](https://developer.apple.com/app-store/app-privacy-details/), [Age rating](https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating/), [암호화](https://developer.apple.com/help/app-store-connect/reference/export-compliance-documentation-for-encryption/), [EU DSA](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements/), [접근성 표시](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/manage-accessibility-nutrition-labels/).
