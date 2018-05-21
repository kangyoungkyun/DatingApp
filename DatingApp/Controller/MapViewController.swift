//
//  MapViewController.swift
//  DatingApp
//
//  Created by MacBookPro on 2018. 5. 15..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Contacts
import GeoFire
import Firebase

class MapViewController: UIViewController,CLLocationManagerDelegate {
    
    //가까이 있는 user key값 담기
    var nearbyUserSet = Set<String>()
    var nearbyUserProfileUrl = Array<String>()
    
    var didFindLocation : Bool?
    
    //1.GeoFire 위치관련 데이터 베이스 변수 선언
    var geoFire:GeoFire?
    var geoFireRef:DatabaseReference?
    var firDataBaseRef:DatabaseReference!
    
    //코어 로케이션 프레임워크의 주요 클래스는 CLLocatoinManager 와 CLLocatoin 이다
    //CLLocatoinManager 클래스의 인스턴스는 아래처럼 생성가능하다.
    let locationManager = CLLocationManager()   //지도 매니저 객체
    
    //뒤로가기
    @objc func handleBack(){
        dismiss(animated: true, completion: nil)
    }
    
    var picUiViewArray = [UIView]()
    
    var likeOrHateImageViewArray = [UIImageView]()
    
    var userViewCount : Int?
    
    //pen gesture 이벤트 처리
    @objc func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        //panGesture가 적용된 view
        let card = panGesture.view!
        //panGesture 가 적용된 point
        let point = panGesture.translation(in: view)
        
        //오른쪽으로 제스쳐 +, 왼쪽으로 제스쳐 - 가 됨
        let xFromCenter = card.center.x - view.center.x
        
        //uiview의 중심위치 구해주기
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        
        //왼쪽으로 스와이프 했을 때
        if (xFromCenter < 0) {
            self.likeOrHateImageViewArray[self.userViewCount!].image = UIImage(named: "bad.png")
        }else if(xFromCenter > 0){
             self.likeOrHateImageViewArray[self.userViewCount!].image = UIImage(named: "good.png")
        }
        // 알파값은 점점 진해지게 0 -> 1
        self.likeOrHateImageViewArray[self.userViewCount!].alpha = abs(xFromCenter) / view.center.x
        
        //panGesture가 끝이 났을때
        if panGesture.state == UIGestureRecognizerState.ended {
            
            if (card.center.x < 75) {
                //왼쪽으로 스와이프 했을 때
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 75)
                    card.alpha = 0
                    self.userViewCount = self.userViewCount! - 1
                })
                return
            }else if (card.center.x > (view.frame.width - 75)){
                //오른쪽으로 스와이프 했을 때
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                    card.alpha = 0
                    self.userViewCount = self.userViewCount! - 1
                })
                return
            }
            UIView.animate(withDuration: 1, animations: {
                print("팬제스쳐 끝")
                card.center = self.view.center
               self.likeOrHateImageViewArray[self.userViewCount!].alpha = 0
            })
        }
    }

    //진입점 - 초기화
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "뒤로", style: .plain, target:self , action: #selector(handleBack))

        locationManager.delegate = self                            //locationManager의 델리게이트를 self로 설정
        locationManager.desiredAccuracy = kCLLocationAccuracyBest    //정확도를 최고로 설정
        locationManager.requestWhenInUseAuthorization()             //위치데이터를 추적하기 위해서 사용자에게 승인 요구
        locationManager.requestAlwaysAuthorization()                //백그라운드에서도 사용하겠다 사용 요구
        locationManager.distanceFilter = 1000                      //1000미터 이상의 위치 변화가 생겼을 때 알림을 받는다.
        locationManager.startUpdatingLocation()                    // 위치 업데이트 시작
        
        //2.위치 데이터 저장할 db 위치지정 , 변수 초기화
        firDataBaseRef = Database.database().reference().child("location")
        geoFireRef = Database.database().reference().child("location")
        geoFire = GeoFire(firebaseRef: geoFireRef!)

    }

    //위치가 변경될 때마다  이 메서드가 호출되며 가장 최근 위치 데이터를 배열의 마지막 객체에 포함하는 CLLocatoin 객체들의 배열이 인자로 전달된다.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //viewDidLoad에서 위치 업데이트 시작, 이곳에서 종료 해주어야 여러번 호출되는 것을 막을 수 있다.
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        // 위치 데이터 업데이트 처리
        let location = locations[0] //나의 위치
        let currentLatitude = location.coordinate.latitude //위도
        let currentLongtitude = location.coordinate.longitude //경도
        let verticalAccuracy = location.verticalAccuracy // 수평정확도
        let horizontalAccuracy = location.horizontalAccuracy //수직정확도
        let altitude = location.altitude // 고도
        
        
        //거리구하기 37.5578239,126.95218069999999.//서울 시청 37.5662952,126.97794509999994 //신촌역37.559768,126.94230800000003  진주 : 35.1617059,128.11498189999998
        let anotherUserLocation = CLLocation(latitude: 37.5578239, longitude: 126.95218069999999) //상대방 위치   -> CLLocation을 지오 로케이션을 이용해서 주소로 바꿀 수 있음!
        let distance = location.distance(from: anotherUserLocation)     // 2464.20431497264m  ->   2.464km
        
        //3. 나의 현재 위치 데이터 삽입 - forKey 값을 uid로 변경
        //내가 로그인한 아이디
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        //4.나의 위치데이터 저장 및 업데이트
        geoFire?.setLocation(location, forKey: uid)
        
        print("위도: \(currentLatitude) 경도: \(currentLongtitude) 수평: \(verticalAccuracy) 수직: \(horizontalAccuracy) 고도: \(altitude) 거리: \(distance/1000)km" )
        
        
        //비동기 방식으로 나와 3km 이내 있는 사람을 호출한다.
        let myQuery = geoFire?.query(at: location, withRadius: 3)
        myQuery?.observe(.keyEntered, with: { (key:String!, location:CLLocation!) in
            print("3km 이내 유저 key:" , key, "with location :" , location)
            self.nearbyUserSet.insert(key)
            print("나와 3km이내 있는 사람 몇명? \(self.nearbyUserSet.count)")
            
        })
        
        //geoFire 데이터 불러오기가 모두 종료되었을때 실행되는 함수
        myQuery?.observeReady {
            
            //나 근처에 있는 사람 uid 가져 오기
            for uid in self.nearbyUserSet{
                //1. index 가지고 firebase 의 users의 uid에 해당하는 profile  url 가지고 와서 imageview에 뿌려주기
                let ref = Database.database().reference()
                
                ref.child("users").child(uid).child("profileImageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
                    print("nearbyUserProfileUrl.append 넣고 있음")
                    self.nearbyUserProfileUrl.append(snapshot.value as! String)

                }, withCancel: nil)
            }

            let alert = UIAlertController(title: "알림 ", message:"당신 3km 주변에 \(self.nearbyUserSet.count)사람 정도 있음", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style:  UIAlertActionStyle.default, handler: { (action) in
               
                print("ok 눌렀음!")
                
                self.userViewCount = self.nearbyUserProfileUrl.count - 1
                
                for i in 0..<self.nearbyUserProfileUrl.count{
                    
                    //뷰
                    let newView = UIView(frame: CGRect(x: self.view.frame.width / 2 - (250 / 2) , y: self.view.frame.height / 2 - (300 / 2), width: 250, height: 300))
                        newView.backgroundColor = .black
                    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))
                    newView.addGestureRecognizer(panGesture)
                    newView.contentMode = .scaleAspectFill
                    
                    self.view.addSubview(newView)
                    
                    //사진
                    let newUserImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
                    newUserImage.loadImageUsingCacheWithUrlString(self.nearbyUserProfileUrl[i])
                    newUserImage.layer.cornerRadius = 50
                    newUserImage.layer.masksToBounds = true
                    newView.addSubview(newUserImage)
                    
                    
                    //좋아요 싫어요 이미지
                    var likeOrHateImageView = UIImageView(frame:CGRect(x: 50, y: 50, width: 100, height: 100))
                    likeOrHateImageView.image = UIImage(named: "good.png")
                    likeOrHateImageView.alpha = 0
                    self.likeOrHateImageViewArray.append(likeOrHateImageView)
                    newUserImage.addSubview(likeOrHateImageView)
                    
                    }
                //나와 3km 이내 있는 사람 전부 삭제
               // self.nearbyUserSet.removeAll()
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치기반 기능 에러발생 : \(error.localizedDescription)")
    }
    
    //앱의 위치 추적 허가 상태가 변경되면 이 메서드를 호출해서 알려준다.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 사용자에 의해서, 더이상 앱이 위치 정보를 얻지 못하게 될 수 있다.
        // 현재의 상태를 체크하고 그에 맞는 처리를 실시한다.
        print("didChangeAuthorization: \(status.rawValue)")
    }
    
    
}
