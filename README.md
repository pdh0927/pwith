## 프로젝트 정보



- **작업 기간** : 24.09 - 진행 **中**
- **인원** : 3명
- **내 역할(기여도)** : 기획(30%), 앱 개발(100%)
- **프로젝트 목적**
    - 플로깅 캠페인, 챌린지에서 앱을 사용한 기록
- **프로젝트 내용**
    - 진행한 플로깅 기록
    - 함께 진행하는 플로깅 챌린지
    - 다른 사람의 플로깅 기록 확인
- 대표 사용 기술 : `Pedometer`, `Geolocator`, `SharedPreferences`, `FirebaseAuth`, `Firebase Storage`

---

## Pwith

> 플로깅 함께하고 기록하자  

🏞️ 모두 함께 플로깅 공유  
🎯 함께 하는 챌린지  
⏱️ 추후엔 봉사시간 연계까지  

[시연 영상](https://youtube.com/shorts/owm_DOPDYm4)

---

## 주요 기능 및 트러블 슈팅



### 플로깅 진행 화면

<img src="https://firebasestorage.googleapis.com/v0/b/meat-dictionary.appspot.com/o/git-image%2FPwith%2F1.png?alt=media&token=e9a68e3e-a2b2-48b7-99bf-cee8c8005bf0" alt="플로깅 진행 화면" width="300"/>

- **기능 설명**
    - 걸음 수, 진행 시간, 정화한 거리를 기록하여 보여줌
    - 사용자가 수집한 아이템(쓰레기)을 기록하고, 사진 촬영 기능을 통해 챌린지 참여를 유도
    - 일시 정지 및 재개 기능을 제공해 유연한 활동 관리 가능
- **구현 기술**
    - `Pedometer`를 사용한 **걸음 수 추적**
    - `Geolocator`를 사용한 **이동 거리 추적**
    - `SharedPreferences`를 활용해 중단 시 데이터(걸음 수, 경과 시간 등)를 저장하고 복구
- **문제점**
    - 상태를 구분하고 이에 따라 데이터를 정확히 기록하고 업데이트하는 데 어려움을 느낌
    - 플로깅이 멈췄을 때 시간을 정확히 측정하지 않도록 관리
    - GPS 신호가 약하거나 갱신이 불규칙하여 이동 거리 측정 문제 발생
- **해결책**
    - `PloggingState`를 `enum`으로 정의하여 `playing`, `paused`, `finished` 상태를 명확히 구분
    - `SharedPreferences`에 현재 상태와 데이터를 저장하고, 앱 재시작 시 복원
    - GPS 위치 갱신 시 `minDistanceChange` 설정으로 불필요한 갱신 최소화

---

### 함께 공유하는 홈 화면

<img src="https://firebasestorage.googleapis.com/v0/b/meat-dictionary.appspot.com/o/git-image%2FPwith%2F2.png?alt=media&token=1fbf58e7-a8ee-40b6-93a1-e830ff060bce" alt="홈 화면" width="300"/>

- **기능 설명**
    - 사용자들이 최근 완료한 플로깅 결과를 공유하여 플로깅 활동 장려
    - 플로깅 활동을 통해 수집된 총 쓰레기 수와 정화된 거리 정보 제공
    - 유저들이 함께 진행하는 챌린지 표시
- **구현 기술**
    - `fold` 메서드를 사용해 플로깅 데이터의 합산 거리 계산

---

### 간편 로그인 구현

<img src="https://firebasestorage.googleapis.com/v0/b/meat-dictionary.appspot.com/o/git-image%2FPwith%2F3.png?alt=media&token=db70bb56-195f-4860-b485-6f728409bb1c" alt="간편 로그인" width="300"/>

- **기능 설명**
    - 카카오톡, 애플 간편 로그인 제공
    - 로그인하지 않은 경우, 사용 기능 제한 및 로그인 유도
- **구현 기술**
    - `FirebaseAuth`를 통한 간편 로그인 제공
    - 사용자의 로그인 상태를 확인하여 UI 상태 업데이트

---

### 내 플로깅 모아보기

<img src="https://firebasestorage.googleapis.com/v0/b/meat-dictionary.appspot.com/o/git-image%2FPwith%2F4.png?alt=media&token=ea2446a8-3c41-4169-993c-e064ad6504e7" alt="내 플로깅 모아보기" width="300"/>

- **기능 설명**
    - 내가 진행한 플로깅 기록을 모아서 표시
    - 선택 시 폴라로이드 형태로 기록 제공
- **구현 기술**
    - `Firebase Storage`에서 이미지 데이터를 네트워크로 불러와 표시
    - 데이터 사용량 감소를 위해 이미지 용량 최적화 후 저장
