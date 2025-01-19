![Header](https://github.com/user-attachments/assets/ec0a5a88-88ed-4033-8d6c-7e2d43314691)

## 다운로드
[![AppStore](https://img.shields.io/badge/App_Store-0D96F6?style=for-the-badge&logo=app-store&logoColor=white)](https://apps.apple.com/kr/app/%EB%B9%84%EB%88%84-%EC%86%90%EC%89%AC%EC%9A%B4-%EB%B9%84%EB%94%94%EC%98%A4-%EB%B3%91%ED%95%A9/id6738731574)

<br/>

## 개요
흩어진 순간을 하나의 추억으로!

"비누"는 간단한 비디오 편집 앱으로, 비디오를 쉽게 병합하는 것에 초점을 두고 개발했습니다.

**개발 기간: 2024.09.18 ~ 2024.11.28**

<br/>

## 사용 기술
**디자인 패턴은 MVVM을 사용했습니다.**

| 이름 | 목적 |
| --- | --- |
| AVFoundation | 비디오 편집, 재생, 내보내기 작업을 수행합니다. |
| Swift Concurrency | 복잡한 비동기 시퀀스 작업을 처리합니다. |
| RxSwift | UIKit 환경에서 반응형 프로그래밍과 추적이 쉬운 데이터 흐름을 구현합니다. |
| RxDataSources | RxCocoa로 TableView 바인딩 시 애니메이션을 적용합니다. |
| SnapKit | AutoLayout 제약조건 코드의 가독성을 개선합니다. |

<br/>

## 코드 컨벤션

- 더 이상 상속되지 않는 클래스는 final 키워드를 사용합니다.
- 강제 언래핑은 사용하지 않습니다. 단, 별도의 nil 체크 로직이 존재할 경우에는 주석과 함께 제한적으로 사용이 가능합니다.
- 5단어 이상의 이름은 지양합니다.
- 이하의 약어만 허용합니다.
  > ViewController → VC
  > 
  > ViewModel → VM
  > 
  > TableView → TV
  > 
  > CollectionView → CV
- 메서드 이름은 동사 원형을 사용합니다.

<br/>

## 문제 해결
[🔗 문제 해결 사례](https://axiomatic-mambo-9a8.notion.site/180b946392fe80d393f9ee1fa940e86b?pvs=4)

<br/>

## 지원
[🔗 사용 설명서](https://axiomatic-mambo-9a8.notion.site/14bb946392fe801daad3c77314e35d6d?pvs=4)

[✉️ jjingeo1230@gmail.com](mailto:jjingeo1230@gmail.com)
