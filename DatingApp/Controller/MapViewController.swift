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


class MapViewController: UIViewController,CLLocationManagerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
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
    
    //호감, 비호감 버튼 객체, 컬렉션뷰 객체
    lazy var btnGood:UIButton = {
        let btn = UIButton()
        btn.setTitle("호감", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .yellow
        btn.addTarget(self, action: #selector(btnGoodHandler), for: .touchUpInside)
        return btn
    }()
    
    @objc func btnGoodHandler(){
        print("호감 눌렀다!")
    }
    
    lazy var btnNotGood:UIButton = {
        let btn = UIButton()
        btn.setTitle("글쎄 좀..", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(btnNotGoodHandler), for: .touchUpInside)
        return btn
    }()
    
    @objc func btnNotGoodHandler(){
        print("싫어요ㅜㅜㅜㅡㅜㅡㅜㅡㅜㅡㅜ")
    }
    

    let myCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let myCollectoinView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        myCollectoinView.showsHorizontalScrollIndicator = false
        myCollectoinView.translatesAutoresizingMaskIntoConstraints = false
        myCollectoinView.backgroundColor = UIColor.darkGray
        myCollectoinView.allowsMultipleSelection = false
        

        
        return myCollectoinView
    }()
    //
    
   @objc func handleSwipeLeft(from recognizer: UIGestureRecognizer?) {
        print("왼쪽으로 스와이프")
    }
    
    //컬랙션 뷰 셀 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nearbyUserSet.count
    }
    
    //컬랙션 뷰 셀 구성 - 이미지 넣기
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //self.nearbyUserProfileUrl.removeAll()
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? PictureCell
        cell?.backgroundColor = .green
        
        print("nearbyUserProfileUrl.count \(nearbyUserProfileUrl.count)")
        
        if nearbyUserProfileUrl.count > 0{
            cell?.imageView.loadImageUsingCacheWithUrlString(nearbyUserProfileUrl[indexPath.row])
            let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
            swipeUpGestureRecognizer.direction = .left
            cell?.addGestureRecognizer(swipeUpGestureRecognizer)
        }else if nearbyUserProfileUrl.count == 0{
             cell?.imageView.image = UIImage(named: "kkk.jpg")
        }

        return cell!
    }
    
    //컬렉션뷰 셀 사이즈 조정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = myCollectionView.frame.width
        let height: CGFloat = myCollectionView.frame.height
        return CGSize(width: width, height: height)
    }

    //진입점 - 초기화
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "뒤로", style: .plain, target:self , action: #selector(handleBack))

        
        //컬렉션 뷰 셀 등록
        myCollectionView.register(PictureCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
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
        
        view.addSubview(btnGood)
        view.addSubview(btnNotGood)
        view.addSubview(myCollectionView)
        
        setupCollectionViewAndBtn()
        
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
                    self.myCollectionView.reloadData()
                }, withCancel: nil)
                
                //3. 좋아요 버튼 or 싫어요 버튼 누르면 다시 for 문 돌아감
                //4. for 문이 끝나면 없습니다...표시..
            }
            
            //# 중요!!!!!!
            //* 유저 uid를 가지고 users에 있는 uid 의 profile url을 가져와서 imageView에 하나씩 뿌려주기
            // 좋아요 or 싫어요 버튼 누르면 배열에 다음 요소의 데이터를 image view에 넣어서 뿌려주기...
            
            let alert = UIAlertController(title: "알림 ", message:"당신 3km 주변에 \(self.nearbyUserSet.count)사람 정도 있네요", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style:  UIAlertActionStyle.default, handler: { (action) in
                //나와 3km 이내 있는 사람 전부 삭제
                self.nearbyUserSet.removeAll()
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
    
    //컬랙션뷰 레이아웃 및 버튼 제약조건
    func setupCollectionViewAndBtn(){
        myCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive=true
        myCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive=true
        myCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive=true
        myCollectionView.bottomAnchor.constraint(equalTo: btnGood.topAnchor, constant: 0).isActive=true
        
        btnGood.leftAnchor.constraint(equalTo: view.leftAnchor).isActive=true
        btnGood.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        btnGood.heightAnchor.constraint(equalToConstant: 35).isActive = true
        btnGood.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: 0).isActive=true
        
        btnNotGood.rightAnchor.constraint(equalTo: view.rightAnchor).isActive=true
        btnNotGood.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        btnNotGood.heightAnchor.constraint(equalToConstant: 35).isActive = true
        btnNotGood.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: 0).isActive=true
    }
    
}
