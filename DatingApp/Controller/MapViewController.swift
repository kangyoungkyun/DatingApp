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

    //GeoFire 위치관련 데이터 베이스 변수 선언
    var geoFire:GeoFire?
    var geoFireRef:DatabaseReference?
    var firDataBaseRef:DatabaseReference!
    
    //지도 객체
    var myMap: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    //코어 로케이션 프레임워크의 주요 클래스는 CLLocatoinManager 와 CLLocatoin 이다
    //CLLocatoinManager 클래스의 인스턴스는 아래처럼 생성가능하다.
    let locationManager = CLLocationManager()   //지도 매니저 객체
    
    @objc func handleBack(){
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "뒤로", style: .plain, target:self , action: #selector(handleBack))
        
        view.addSubview(myMap)
        
        setMyMapLayout()

        locationManager.delegate = self //locationManager의 델리게이트를 self로 설정
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //정확도를 최고로 설정
        locationManager.requestWhenInUseAuthorization() //위치데이터를 추적하기 위해서 사용자에게 승인 요구
        locationManager.requestAlwaysAuthorization() //백그라운드에서도 사용하겠다 사용 요구
        locationManager.distanceFilter = 1000 // 1000미터 이상의 위치 변화가 생겼을 때 알림을 받는다.
        locationManager.startUpdatingLocation()     // 위치 업데이트 시작
        myMap.showsUserLocation = true              // 위치 보기 값을 true로 설정
        
        
        //위치 데이터 저장할 db 변수 초기화
        firDataBaseRef = Database.database().reference().child("location")
        geoFireRef = Database.database().reference().child("location")
        geoFire = GeoFire(firebaseRef: geoFireRef!)
    }

    //위치가 변경될 때마다  이 메서드가 호출되며 가장 최근 위치 데이터를 배열의 마지막 객체에 포함하는 CLLocatoin 객체들의 배열이 인자로 전달된다.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 위치 데이터 업데이트 처리
        let location = locations[0] //나의 위치
        let currentLatitude = location.coordinate.latitude //위도
        let currentLongtitude = location.coordinate.longitude //경도
        let verticalAccuracy = location.verticalAccuracy // 수평정확도
        let horizontalAccuracy = location.horizontalAccuracy //수직정확도
        let altitude = location.altitude // 고도

        //거리구하기 37.5578239,126.95218069999999
        let anotherUserLocation = CLLocation(latitude: 37.5578239, longitude: 126.95218069999999) //상대방 위치   -> CLLocation을 지오 로케이션을 이용해서 주소로 바꿀 수 있음!
        let distance = location.distance(from: anotherUserLocation)     // 2464.20431497264m  ->   2.464km
    
        
         print("위도: \(currentLatitude) 경도: \(currentLongtitude) 수평: \(verticalAccuracy) 수직: \(horizontalAccuracy) 고도: \(altitude) 거리: \(distance/1000)km" )
    
        
        var address2 : String?
        
        //역방향 지오코딩
        
        let geoCoder = CLGeocoder()
        //cllocatoin객체는 위도와 경로 좌표로 초기화
        //let newLocation = CLLocation(latitude: 37.3316833, longitude: -122.0301031)
        
        //geoCoder에 reverseGeocodeLocation 메서드로 전달 된다.
        geoCoder.reverseGeocodeLocation(anotherUserLocation, completionHandler: { (placemarks, error) in
            if error != nil {
                print("에러 발생 \(error!.localizedDescription)")
            }
            //값이 있으면 배열 값으로 반환
            if placemarks!.count > 0 {
                let placemark = placemarks![0]
                //딕셔너리 값으로 반환
                let addressDictionary = placemark.addressDictionary
                
                //key 값을 이용해서 주소 찾기
                var address = addressDictionary!["Street"]
                let city = addressDictionary!["City"]
                let state = addressDictionary!["State"]
                let zip = addressDictionary!["ZIP"]
                
                address2 = "\(address!) \(city!) \(state!)"
                
                let alert = UIAlertController(title: "알림1 ", message:"교회가 있는곳은 \(address2)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "ㅇㅇ", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                
                print("\(address!) \(city!) \(state!)")
            }
        })
        
        
        //나의 위치에서 2km 이내있는 사람 불러오기!
        if(distance/1000 < 2){
            print("지금 교회랑 가까워요")
            let alert = UIAlertController(title: "알림 ", message:"지금 당신은 교회랑 가까워요\(distance/1000)km 정도?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ㅇㅇ", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
        
        
        
        //거리 구하기2
        //신촌역 37.559768,126.94230800000003 , 광화문 37.57593689999999,126.97681569999997
        //let coordinate0 = CLLocation(latitude: 37.559768, longitude: 126.94230800000003)
        //let coordinate1 = CLLocation(latitude: 37.57593689999999, longitude: 126.97681569999997)
        //let distanceInMeters = coordinate0.distance(from: coordinate1)
        //print("distance : \(distanceInMeters/1000)km")
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
    
    
    func setMyMapLayout(){
        myMap.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        myMap.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        myMap.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        myMap.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }


}
