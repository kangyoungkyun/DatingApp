
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //등록 버튼 액션
    func handleRegister(){
        
        if(picCheck){
            //유효성 검사
            guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text,let gender = genderSegmentControl.text, let age = ageTextField.text else {
                
                
                //유효성 검사 해주기
                print("값이 없거나 잘못된 형식")
                return
            }
            //파이어베이스 가입
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                //에러 발생
                if let error = error{
                    if let errCode = AuthErrorCode(rawValue: error._code) {
                        switch errCode {
                        case .invalidEmail:
                            let alert = UIAlertController(title: "경고 ", message:"이메일 형식이 아닌것 같음..", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "ㅇㅇ", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        case .wrongPassword :
                            let alert = UIAlertController(title: "경고 ", message:"비밀번호 확인 ㄱㄱ", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "ㅇㅇ", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        case .accountExistsWithDifferentCredential :
                            let alert = UIAlertController(title: "경고 ", message:"이메일을 확인좀..", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "ㅇㅇ", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        case .userNotFound :
                            let alert = UIAlertController(title: "경고 ", message:"존재하지 않는 이메일이여", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "ㅇㅇ", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        default:
                            let alert = UIAlertController(title: "경고 ", message:"빈칸없는지 다시바바ㅠㅠ", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "ㅇ", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    return
                }
                //가입후 uid  넘겨준다. uid 가 nil이면 return
                guard let uid = user?.uid else {
                    return
                }
                
                //유저 가입 성공후
                //유일한 스트링 값
                let imageName = NSUUID().uuidString
                //firebase 저장소 위치 가져오기
                let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
                //image 파일 변환
                
                //더 안전하게
                if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1){
                    
                    //업로드
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        if let error = error {
                            print(error)
                            return
                        }
                        //이미지가 저장된 url 가져온 후 users db에 삽입
                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                            
                            let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl,"gender":gender,"age":age]
                            //최종 저장 함수 호출(데이터 넘겨줌)
                            self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
                        }
                    })
                }
            }
        }else{
            
            let alert = UIAlertController(title: "경고 ", message:"맨위에 바바 사진넣어야됨...", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ㅇㅇ", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    //최종적으로 유저 저장
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        //최종 저장
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if let err = err {
                print(err)
                return
            }
            let user = User(dic:values)
            //등록 할때 메시지 컨트롤러에 있는 setupnavbar 함수 호출
            self.mainViewController?.setupNavBarWithUser(user: user)
            self.dismiss(animated: true, completion: nil)
        })
        
        picCheck = false
    }
    
    
    //프로필 이미지 클릭했을 때 실행되는 이벤트 함수
    @objc func handleSelectProfileImageView(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    
    //이미지 피커 선택 완료
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
            picCheck = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    //이미지 피커 취소
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
