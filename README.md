
## 🧴 MANLIVEYOUNG

Flutter를 이용해 개발한 남자화장품 추천 앱입니다.

|                      <img src="https://avatars.githubusercontent.com/u/81014501?v=4" width=150px>                       |
| :---------------------------------------------------------------------------------------------------------------------: |
|                                        [노현](https://github.com/YesHyeon)                                        |
|                                 [shgus1224@naver.com](mailto:shgus1224@naver.com)                                 |
| Flutter 화면 개발<br/>서버 및 DB구축 <br/> UI/UX 디자인<br/> |

<img width="700" alt="image" src="https://github.com/YesHyeon/flutter-hwahae-app/assets/81014501/748067bb-2eec-4d09-b0e4-07f1f297d4b9">


# 기술스택 👨🏻‍💻

- Flutter
- Dart
- Javascript
- Node.js
- Firebase Firestore

# 데이터 수집 및 분석 📉
<img width="550" alt="image" src="https://github.com/YesHyeon/flutter-hwahae-app/assets/81014501/fa2597b4-f19d-4938-af1b-593fdae3fac6">

앱 내 더미데이터 활용 목적 수집 (name, category, review, user_type)

화장품 수 : 카테고리별 10개. 총 60개. / 화장품당 리뷰 수 : 100개 / 총 데이터셋 size : 6000개



# Firebase 구축 🎇

- User (id, password, nickname, usertype), Review (CosmeticName, SkinType, Star)
- Cosmetic (Name, Image, Type, Star, Review, Comment), UserFeedback(Nickname, Like)
  
1) 유저의 정보와 화장품의 데이터를 저장하기 위해 Firebase의 Firestore Database 저장소를 생성

2) 중복 유저를 방지하고, 보안을 강화하기 위해 Firebase의 Authentication을 이용

3) 컬렉션은 User, Cosmetic, Review, UserFeedback을 생성



# Flutter 앱개발 💻

<img width="550" alt="image" src="https://github.com/YesHyeon/flutter-hwahae-app/assets/81014501/d7787349-d3e2-4698-9b3c-18b34a9445fb">

1) 전체적인 페이지를 먼저 개발한 뒤, Firebase 저장소와 연동하여 DB에 있는 내용을 적용
2) 데이터 형식은 JSON 형식을 유지하여, Rest API 기반으로 백엔드 서버와 소통하기 용이하도록 관리
3) 동적으로 적용되어야 하는 데이터는 setState로 관리해 실시간으로 데이터를 업데이트
4) 비동기처리를 통한 Firebase와의 연동
5) Github 저장소를 통해 기능별로 commit을 등록해 관리하고, 협업 진행


# 시연영상

https://github.com/YesHyeon/flutter-hwahae-app/assets/81014501/73d64286-c742-42be-837b-1ddccd0d6357

# 클라이언트 실행방법
1. '기타/클라이언트 env 파일' 폴더에 있는 env 파일을 클라이언트 루트 폴더에 옮기기 (이름은 .env로 변경)
2. Android Studio 실행후 AVD 실행하기
3. 터미널 입력창에 아래와 같이 입력하기

```
flutter run
```


