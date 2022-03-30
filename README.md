# TODAY_MEMO
 Xcode + UIKit based memo application for IOS

## 1. TODAY MEMO

 안드로이드 개발을 계속 하다보니, 분명 필요해서 만든 앱인데 애플 유저라서 직접 사용하지 못하는 문제가 여러번 있었다.<br>
이제 직접 사용가능한 앱을 만들어보고자 ios개발을 시작했다. 개발은 내가 만들어서 내가 무한으로 즐기는 것도 하나의 재미라고 생각하기 때문이다.<br>
일단 현재 아이폰 기본 메모장의 위젯이 마음에 안들어서 위젯으로 사용가능한 메모장 앱을 만들고 싶었다.<br><br>
launch screen 디자인은 직접 했다. 물론 디자인이라고 할 것도 없이 그냥 아이패드로 그림 그린 것이다.<br><br>
 
 <p align = "center">
<img src="https://user-images.githubusercontent.com/63590121/160765798-ae9098a5-4626-4908-891a-06fb19523417.png" width = "400" height="900">
</p>
 
## 2. 개발 과정

 
**사용한 Tools**
* xcode + swift
* UIkit
* Table View Controller / Navigation Controller
* Core Data
* UserDefaults
* Alamofire
 
 
일단 ios 개발이 처음이었기 때문에 UIkit framework에 대한 공부를 함께 진행하면서 프로젝트를 했다.<br>
책은 [꼼꼼한 재은씨의 swift] 시리즈를 다 정독했다. 시리즈 다 합쳐서 2000페이지가 넘는 양이다. 분량이 엄청난데 확실히 그만큼 자세하게 배울 수 있었다. 나는 속성 강의보다 이렇게 하나하나 다 배우는 게 잘 맞는 것 같다. 책에서 진행하는 프로젝트를 따라가면서도 많은 것을 배울 수 있었다. <br>
 
메인 뷰는 다음과 같다.<br>
전반적으로는 navigation controller를 기반으로 하고, 메모 목록은 table view controller를 사용했다.<br>
side bar는 github 라이브러리를 이용했는데, MVC 패턴 리팩토링 때는 직접 구현해서 적용해볼 생각이다.
 
 <p align="center">
  <img src="https://user-images.githubusercontent.com/63590121/160766443-719c4ff1-338e-4fe2-a171-5a094c5c4f2e.png" width="400" height="900">
 <img src="https://user-images.githubusercontent.com/63590121/160765903-cd3ccc5c-cca4-403f-87af-6320e75c3371.png" width = "400" height="900">
</p>

  
 로그인을 통해 서버에 메모를 백업하고, 다시 가져올 수 있는 형태이다. 기본적으로는 core data를 사용하였다.<br>
core data도 안드로이드에는 없는 부분이라 배우는 재미가 있었다.
로그인 부분은 서버 연동과 key chain access, touchID를 사용하였는데, 이부분은 안드로이드에서도 해보지 못한 부분이라 어려움이 있었다. 다행히 책에서 잘 가이드가 되어있어서 참고를 많이 할 수 있었다.
 
<p align = "center">
<img src="https://user-images.githubusercontent.com/63590121/160767314-7905d50c-2871-4d23-bbdf-af8afb4b6263.png" width = "400" height="900">
</p>
 
 
## 3. retrospect

아무래도 가장 아쉬운 점은 오류 처리를 제대로 하지 못한 부분이다.<br>
 optional type을 대부분 forced unwrapping으로 해제하여서 nil값이 나오는 경우에 대한 에러 처리가 확실히 부족하게 되었다. (그래서 예상치 못한 유저의 동작에는 앱이 abort된다) 무조건 if let 이나 ?? 를 통해서 optional 처리를 해줘야 했는데 아쉽다.<br>
또한 side bar에 많은 기능을 넣지 못해서 아쉽다. 지금은 계정 관리 항목만 구현되어있고, 나머지는 더 구현해야 한다. 이건 백엔드를 제대로 구축하고 다시 해야할 것 같다.<br>
마지막으로 원래 만들고자 했던 위젯 기능을 추가하지 못했다. 3월 안에 이 프로젝트를 끝내야 했기 때문인데, 이는 사실 시간을 갖고 더 구현하면 되는 문제이다.<br>
 
ios 개발은 안드로이드와 비슷하면서 다른 점이 많아서 배우는 즐거움이 있었다. 앱 life cycle이나 delegate pattern(안드로이드에서는 listener 개념과 비슷한 듯하다.) 등은 비슷한 부분이 많았지만, ios만의 장점이 잘 드러나는 부분도 있었다.<br>
예를 들면 table view에서의 reuse mechanism이라던지, ARC 메모리 관리 기법, optional 처리, storyboard를 통한 action method 연결 등등 이러한 부분들은 ios 만이 가진 장점을 구현하게 해주는 요소 중 하나라고 생각한다.<br>
 
4월에는 이 프로젝트 리팩토링과 함께 새로운 주제로 프로젝트를 진행하고, 그걸 실제로 app store에 출시해 볼 계획이다.<br>
그때까지 파이팅해야지
