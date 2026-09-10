# 스토어 입력 문구

각 언어 폴더의 txt 파일을 동일한 App Store Connect 필드에 붙여 넣습니다. 앱 내부 언어는 현재 영어입니다. 한국어 스토어 설명은 이를 명시합니다.

- 이름/부제 30자, 홍보 문구 170자, 설명 4,000자.
- 키워드 100 UTF-8 바이트 이하. `scripts/validate.py`로 검사합니다.
- `whats-new.txt`는 릴리스 안내용입니다. 최초 등록에는 해당 입력란을 사용하지 않고, 업데이트 시 실제 변경사항으로 교체합니다.
- Category 제안: Productivity. 가격·판매 국가·개발자 법적 표시명은 계정 소유자가 정합니다.
- 유료/무료, AI, 위젯, 알림, iCloud 기능은 광고하지 않습니다.

근거: [버전 필드](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/), [앱 정보](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/).
