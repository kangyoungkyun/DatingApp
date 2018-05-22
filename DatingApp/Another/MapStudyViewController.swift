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

class MapStudyViewController: UIViewController,CLLocationManagerDelegate {
    
    //지도 객체
    var myMap: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    let locationManager = CLLocationManager()   //지도 매니저 객체
    
    @objc func handleBack(){
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "뒤로", style: .plain, target:self , action: #selector(handleBack))
        
        view.addSubview(myMap)
        
        setMyMapLayout()
        
        //지오코딩 - 주소로 좌표 위치 알아내는 방법
        
        let addressString = "One Infinite Loop, Cupertino, CA 95014"
        CLGeocoder().geocodeAddressString(addressString) { (placemarks, error) in
            
            if error != nil{
                print("에러발생 \(error!.localizedDescription)")
            }else if placemarks!.count > 0{
                let placemark = placemarks![0]
                let location = placemark.location
                let coords = location!.coordinate
                
                print("placemark : \(placemark).  location : \(location)  , coords : \(coords) ")
                print("위도 : \(coords.latitude), 경도 : \(coords.longitude)")
                
                
                //                placemark : 1 Infinite Loop, 1 Infinite Loop, 쿠쿠\355\215퍼티쿠\355\215퍼티\353\205노, CA  95014, 미 합중국 @ <+37.33168330,-122.03010310> +/- 100.00m, region CLCircularRegion (identifier:'<+37.33169175,-122.03021900> radius 62.40', center:<+37.33169175,-122.03021900>, radius:62.40m)
                //
                //                location : Optional(<+37.33168330,-122.03010310> +/- 100.00m (speed -1.00 mps / course -1.00) @ 16/05/2018, 15:05:16 Korean Standard Time)
                //
                //                coords : CLLocationCoordinate2D(latitude: 37.331683300000002, longitude: -122.03010310000001)
                
                
            }
        }
        
        //역방향 지오코딩
        
        let geoCoder = CLGeocoder()
        //cllocatoin객체는 위도와 경로 좌표로 초기화
        let newLocation = CLLocation(latitude: 37.3316833, longitude: -122.0301031)
        
        //geoCoder에 reverseGeocodeLocation 메서드로 전달 된다.
        geoCoder.reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) in
            if error != nil {
                print("에러 발생 \(error!.localizedDescription)")
            }
            //값이 있으면 배열 값으로 반환
            if placemarks!.count > 0 {
                let placemark = placemarks![0]
                //딕셔너리 값으로 반환
                let addressDictionary = placemark.addressDictionary
                
                //key 값을 이용해서 주소 찾기
                let address = addressDictionary!["Street"]
                let city = addressDictionary!["City"]
                let state = addressDictionary!["State"]
                let zip = addressDictionary!["ZIP"]
                
                print("\(address!) \(city!) \(state!) \(zip!)")
            }
        })
        
        
        // mkplacemark 인스턴스 생성하기
        
        //mkmapitem 클래스를 이용해서 지도를 표시할 때 나타나는 각각의 위치는 mkplacemark 객체에 의해 표현되어야 한다.
        //mkplacemark 객체를 생성할 때 그 객체는 주소 속성 정보를 포함하고 있는 nsdictionary 객체와 함께 위치의 지리적 좌표로 초기화 되어야 한다.
        
        //매게 변수로 위도,경도가 들어간다.
        
        let coords = CLLocationCoordinate2DMake(51.5083, -0.1384)
        
        let address = [CNPostalAddressStreetKey: "181 Piccadilly, St. James's", CNPostalAddressCityKey: "London", CNPostalAddressPostalCodeKey: "W1A 1ER", CNPostalAddressISOCountryCodeKey: "GB"]
        
        //주소 딕셔너리에 nil 값을 전달하여 mkplacemark 객체를 초기화 할 수 있다. 그러나 그 결과로 지도가 나타날때 현재 위치는 표시되겠지만, 주소 대신에 unknown이라는 태그가 붙는다.
        //mkplacemark 객체를 생성할때 좌표는 필수 값이다.
        //위치 좌표가 아닌 텍스트 주소를 알고 있는 경우 mkplacemark 인스턴스를 생성하기 전에 좌표를 얻기 위하여 지오코딩이 사용되어야 한다.
        let place = MKPlacemark(coordinate: coords, addressDictionary: address)
        
        // mkmapitem으로 작업
        // mkplacemark 객체를 인자로 전달해서 초기화
        let mapItem = MKMapItem(placemark: place)
        
        mapItem.name = "empire state building"
        mapItem.phoneNumber = "1010234"
        mapItem.url = NSURL(string: "http://www.naver.com") as! URL
        mapItem.openInMaps(launchOptions: nil)
        
        
        //적절한 표시로 목적지를 가리키는 지도를 연다
        //mapItem.openInMaps(launchOptions: nil)
        
        
        
        //mapItemForCurrentLocation 메서드 호출을 통해 사용자 디바이스의 현재 위치를 표시 할 수도 있다.
        
        let mapItem2 = MKMapItem.forCurrentLocation()
        
        let mapItems = [mapItem, mapItem2]
        
        let options = [MKLaunchOptionsDirectionsModeKey:
            MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey: true] as [String : Any]
        
        MKMapItem.openMaps(with: mapItems, launchOptions: options)
        
        
        
        
        
        //        locationManager.delegate = self //locationManager의 델리게이트를 self로 설정
        //        locationManager.desiredAccuracy = kCLLocationAccuracyBest //정확도를 최고로 설정
        //        locationManager.requestWhenInUseAuthorization() //위치데이터를 추적하기 위해서 사용자에게 승인 요구
        //        locationManager.startUpdatingLocation()     // 위치 업데이트 시작
        //        myMap.showsUserLocation = true              // 위치 보기 값을 true로 설정
        
        
    }
    
    //위치가 변경될 때마다  이 메서드가 호출되며 가장 최근 위치 데이터를 배열의 마지막 객체에 포함하는 CLLocatoin 객체들의 배열이 인자로 전달된다.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 위치 데이터 업데이트 처리
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //에러 처리
    }
    
    //앱의 위치 추적 허가 상태가 변경되면 이 메서드를 호출해서 알려준다.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 사용자에 의해서, 더이상 앱이 위치 정보를 얻지 못하게 될 수 있다.
        // 현재의 상태를 체크하고 그에 맞는 처리를 실시한다.
    }
    
    
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        let location = locations[0]
    //        let center = location.coordinate
    //        let span = MKCoordinateSpanMake(0.05, 0.05)
    //        let region = MKCoordinateRegionMake(center, span)
    //        myMap.setRegion(region, animated: true)
    //        myMap.showsUserLocation = true
    //    }
    
    //    //위도와 경도, 영역 폭을 입력받아 지도에 표시
    //    func goLocation(latitud latitudeValue : CLLocationDegrees, longitude longitudeValue : CLLocationDegrees, delta span : Double) -> CLLocationCoordinate2D{
    //
    //        //위도와 경도값을 매겨변수로 함수 호출
    //        let pLocation = CLLocationCoordinate2DMake(latitudeValue, longitudeValue)
    //        //범위 값을 매개변수로
    //        let spanValue = MKCoordinateSpanMake(span, span)
    //        let pResion = MKCoordinateRegionMake(pLocation, spanValue)
    //
    //        myMap.setRegion(pResion, animated: true)
    //
    //        return pLocation
    //    }
    //
    //    //특정 위도와 경도에 핀설치하고 핀에 타이틀과 서브타이틀 문자열 표시하기(위도, 경도, 범위, 타이틀, 서브타이틀)
    //    func setAnnotation(latitude latitudeValue: CLLocationDegrees, longtitude longtitudeValue : CLLocationDegrees, delta span: Double, title strTitle : String, subtitle strSubtitle : String){
    //        //핀객체
    //        let annotation = MKPointAnnotation()
    //        annotation.coordinate = goLocation(latitud : latitudeValue, longitude : longtitudeValue, delta : span)
    //
    //        annotation.title = strTitle
    //        annotation.subtitle = strSubtitle
    //        myMap.addAnnotation(annotation)
    //    }
    //
    
    
    func setMyMapLayout(){
        myMap.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        myMap.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        myMap.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        myMap.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    
}


//func getTextAddress() -> String{
//    
//
//
// var address2 : String?
// 
// //역방향 지오코딩
// 
// let geoCoder = CLGeocoder()
// //cllocatoin객체는 위도와 경로 좌표로 초기화
// //let newLocation = CLLocation(latitude: 37.3316833, longitude: -122.0301031)
// 
// //geoCoder에 reverseGeocodeLocation 메서드로 전달 된다.
// geoCoder.reverseGeocodeLocation(anotherUserLocation, completionHandler: { (placemarks, error) in
// if error != nil {
// print("에러 발생 \(error!.localizedDescription)")
// }
// //값이 있으면 배열 값으로 반환
// if placemarks!.count > 0 {
// let placemark = placemarks![0]
// //딕셔너리 값으로 반환
// let addressDictionary = placemark.addressDictionary
// 
// //key 값을 이용해서 주소 찾기
// let address = addressDictionary!["Street"]
// let city = addressDictionary!["City"]
// let state = addressDictionary!["State"]
// let zip = addressDictionary!["ZIP"]
// 
// address2 = "\(address!) \(city!) \(state!)"
// 
// let alert = UIAlertController(title: "알림1 ", message:"교회가 있는곳은 \(address2)", preferredStyle: UIAlertControllerStyle.alert)
// alert.addAction(UIAlertAction(title: "ㅇㅇ", style: UIAlertActionStyle.default, handler: nil))
// self.present(alert, animated: true, completion: nil)
// 
// 
// print("\(address!) \(city!) \(state!)")
// }
// })
//    return "\(address!) \(city!) \(state!)"
//}


//나의 위치에서 2km 이내있는 사람 불러오기!
//        if(distance/1000 < 3){
//            print("지금 교회랑 가까워요")
//            let alert = UIAlertController(title: "알림 ", message:"지금 당신은 교회랑 가까워요\(distance/1000)km 정도?", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "ㅇㅇ", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//
//
//        }

//거리 구하기2
//신촌역 37.559768,126.94230800000003 , 광화문 37.57593689999999,126.97681569999997
//let coordinate0 = CLLocation(latitude: 37.559768, longitude: 126.94230800000003)
//let coordinate1 = CLLocation(latitude: 37.57593689999999, longitude: 126.97681569999997)
//let distanceInMeters = coordinate0.distance(from: coordinate1)
//print("distance : \(distanceInMeters/1000)km")


