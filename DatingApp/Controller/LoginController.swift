//
//  LoginController.swift
//  DatingApp
//
//  Created by MacBookPro on 2018. 4. 3..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit
import Firebase
class LoginController: UIViewController {

    //컨테이너 뷰
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    //로그인 버튼
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red:0.65, green:0.61, blue:0.56, alpha:1.0)
        button.setTitle("등록", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    //로그인 버튼 액션
    @objc func handleRegister(){
       //유효성 검사
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("값이 없거나 잘못된 형식")
            return
        }
        //파이어베이스 가입
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            //에러 발생
            if let error = error{
                print(error)
                return
            }
            //가입후 uid  넘겨준다. uid 가 nil이면 return
            guard let uid = user?.uid else {
                return
            }
            //유저가 저장될 firebase 위치
            let ref = Database.database().reference()
            let uesrReference = ref.child("users").child(uid)
            //딕셔너리 타입으로 값을 넣어준다.
            let values = ["name":name,"email":email]
            uesrReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if let err = err {
                    print(err)
                    return
                }
                
                print("가입 성공")
            })
            
        }
        
    }
    
    
    //이름 텍스트 필드
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "닉네임"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    //이름 구분선
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //이메일 텍스트 필드
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "이메일"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    //이메일 구분선
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    //패스워드 텍스트 필드
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "비밀번호"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    //프로필 이미지
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "main2")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    //진입점
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:0.97, green:0.93, blue:0.79, alpha:1.0)
        
           view.addSubview(inputsContainerView)
           view.addSubview(loginRegisterButton)
           view.addSubview(profileImageView)
        
        //입력 객체
        setupInputsContainerView()
        //로그인버튼 객체
        setupLoginRegisterButton()
        //이미지뷰 객체
        setupProfileImageView()
        
    }
    
    //컨테이너 뷰 제약조건 설정
    func setupInputsContainerView(){
        //컨테이너 뷰 제약조건
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo:view.widthAnchor,constant:-24).isActive = true
        inputsContainerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        //컨테이너 뷰 안에 뷰객체 넣기
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
    
        //뷰객체 제약조건 설정
        //이름
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: 0).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, constant: 0).isActive = true
        nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        //이름 구분선
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        //이메일
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 0).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, constant: 0).isActive = true
        emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        //이메일 구분선
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        //비밀번호
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 0).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, constant: 0).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        
    }
    
    //로그인버튼 제약 조건 설정
    func setupLoginRegisterButton(){
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    //로그인버튼 제약 조건 설정
    func setupProfileImageView(){
        
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -50).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 110).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 110).isActive = true
    }
    

}

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
}
}
