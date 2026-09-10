# 최종 스토어 이미지

현재 등록용은 [editorial 폴더](editorial) 안의 언어별 4장입니다. [미디어 안내](../creative/README.md)를 참고하세요. 아래 iphone-6.9 원본은 이전 개발 기록이며 새 스토어 등록에 사용하지 않습니다.

# 스토어용 실제 화면 캡처

`iphone-6.9/`의 5개 PNG는 iPhone 17 Pro Max / iOS 26.5 시뮬레이터에서 실제 앱을 실행하고 XCTest로 캡처했습니다. 1320×2868, 알파 없음. 가상 예문을 직접 입력하고 두 Step을 실제로 완료한 데이터입니다. 합성 UI·생성한 화면·변형한 개인정보는 없습니다.

추천 등록 순서:

1. **Store-02-Home.png** — 하나의 Next Step과 Vision이 함께 보이는 핵심 화면.
2. **Store-03-Next-Step.png** — 한 Step에 집중하고 완료하는 화면.
3. **Store-04-Reflection.png** — “What did you learn?” 선택적 회고.
4. **Store-05-Journey.png** — 완료한 Step과 Reflection의 월별 기록.
5. **Store-01-Welcome.png** — 제품의 짧은 시작 화면. 필요 시 생략 가능.

한국어 스토어에도 같은 실제 영어 UI 화면을 사용할 수 있습니다. 설명에서 앱의 영어 UI를 명시했습니다. 향후 외부 캡션을 추가할 때 사용할 문구:

| 화면 | English | 한국어 |
|---|---|---|
| Home | One clear next step. | 지금, 하나의 다음 걸음. |
| Step | Give one step your attention. | 한 걸음에 집중하세요. |
| Reflection | Take what you learned with you. | 배운 점을 다음으로 이어가세요. |
| Journey | See the journey you’re building. | 쌓여가는 여정을 돌아보세요. |

테스트 소스: NextUITests/CoreLoopUITests.swift의 testReflectionJourneyAndScreenshots. 원본 첨부파일과 생성 시각은 evidence/screenshots-final/manifest.json에 있습니다. 현재 캡처는 Debug의 별도 테스트 저장소를 사용하며 프로덕션과 같은 화면을 렌더링합니다. 최종 서명한 출시 빌드와 화면 일치 여부는 제출 전에 대조해야 합니다.

스크린샷은 [Apple 6.9인치 사양](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)에 맞습니다. 배너는 assets에 별도 제공하며 스토어 screenshot 슬롯에 대신 넣지 않습니다. iPad는 현재 지원 기기군에 포함되지 않습니다. 앱 미리보기 동영상은 선택 사항이라 만들지 않았습니다.
