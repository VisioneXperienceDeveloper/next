# Next · App Store 준비 패키지

VXDeveloper · `com.visionexperiencedeveloper.next` · 1.0.0 (1)

하나의 Vision → 하나의 Next Step → 완료 → 선택적 Reflection → 다음 Step. Journey는 완료한 걸음을 월별로 보여줍니다. 위젯·알림·AI·계정·동기화는 이번 출시 범위에 없습니다.

## 바로 사용할 자료

- [영어·한국어 스토어 문구](metadata/README.md)
- [App Store Connect 입력표](app-store-connect.md)
- [아이콘·홍보 배너](assets/README.md)
- [최종 App Store 스크린샷 8장·영상 2편](creative/README.md)
- [개인정보처리방침 EN](legal/privacy.en.md) / [한국어](legal/privacy.ko.md)
- [지원 FAQ EN](legal/support.en.md) / [한국어](legal/support.ko.md)
- [개인정보·연령·수출 규정 답변 근거](legal/compliance.md)
- [라이선스·콘텐츠 권리 기록](legal/rights-and-license.md)
- [심사 안내](review/review-guide.md) / [복사할 영문 메모](review/notes.en.txt)
- [TestFlight 설명과 테스트 지침](review/testflight.ko.md)
- [제출 절차](release-runbook.md) / [검증 결과](qa/verification.md)
- [남은 출시 조건](readiness.md) / [설정 파일](release-config.json)
- [공개 요구사항 근거](sources.md)

## 문서·이미지 미리보기

`index.html`에서 자료를 한 번에 살펴볼 수 있습니다. 웹사이트용 문서 HTML은 `web-preview/`에 있습니다. 최종 공개 URL은 app-store-connect.md에 기록했으며 4개 모두 정상 접근을 확인했습니다.

## 로컬 검증

```sh
python3 release/app-store/scripts/render-pages.py
python3 release/app-store/scripts/validate.py
python3 release/app-store/scripts/validate.py --submission
```

일반 검증은 작성 파일과 문구를 검사합니다. `--submission`은 미확정 출시 조건이 있으면 실패해야 정상입니다. 승인·실기기 테스트·서명 검증을 수행하지 않고 true로 바꾸지 마세요.

빌드 2 서명·업로드가 완료됐습니다. 실기기·TestFlight 검증은 아직 수행하지 않았습니다. 최신 원격 상태와 남은 절차는 readiness와 QA 문서가 기준입니다.
