//
//  ViewController.swift
//  DatingApp
//
//  Created by MacBookPro on 2018. 4. 3..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit
import Firebase
class MessageController: UITableViewController {
     var messagesController: MessageController?
    var ref: DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "로그아웃", style: .plain, target:self , action: #selector(handleLogout))
        
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        //로그인or로그아웃 체크
        checkIfUserIsLoggedIn()

    }
    
    //로그인or로그아웃 체크 함수
    func checkIfUserIsLoggedIn(){
        //로그아웃 되었을 때 실행
        if Auth.auth().currentUser?.uid == nil{
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }else{
            
            //로그인 되었으면 네비게이션 타이틀의 제목을 유저 이름으로 지정해준다.
             fetchUserAndSetupNavBarTitle()
            

        }
    }
    
    func fetchUserAndSetupNavBarTitle(){
        //로그인 되었으면 네비게이션 타이틀의 제목을 유저 이름으로 지정해준다.
        guard let uid = Auth.auth().currentUser?.uid else{
            //uid가
            return
        }
        
        ref = Database.database().reference()
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print("타이틀 바 표시 함수 호출 성공-")
            print(snapshot)
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                let user = User(dic: dictionary)
                self.setupNavBarWithUser(user: user)
                
            }
        }, withCancel: nil)
       
    }
    
    //네비게이션 타이틀 바 변경해주기
    func setupNavBarWithUser(user: User){
        print("사진있는 타이틀!")
        let titleView = UIView()
        
        titleView.frame = CGRect(x:0, y:0, width: 100, height: 50)
        //titleView.backgroundColor = UIColor.blue
        
        //이미지와 라벨을 담을 뷰 객체
        let containerView = UIView()
        //containerView.frame = CGRect(x:45, y:5,width:200 ,height:50)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(containerView)
        
        //이미지 객체
        let profileImageView = UIImageView()
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        if let profileImageUrl = user.profileImageUrl{
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        containerView.addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        let nameLable = UILabel()
        containerView.addSubview(nameLable)
        
        nameLable.text = user.name
        nameLable.translatesAutoresizingMaskIntoConstraints = false
        nameLable.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLable.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLable.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLable.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        //nameLable.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        self.navigationItem.titleView = titleView
    
        //titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        
    }
    
    //새로운 메시지 쓰기
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    
    //로그아웃 액션
    @objc func handleLogout(){
        
        do{
            try Auth.auth().signOut()
        } catch let logError{
            print(logError)
        }
        
         messagesController?.fetchUserAndSetupNavBarTitle()
        
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }
    
    
    
}

