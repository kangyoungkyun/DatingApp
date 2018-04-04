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
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dic = snapshot.value as? [String:AnyObject]{
                    self.navigationItem.title = dic["name"] as? String
                    
                }
            })
            Database.database().reference().removeAllObservers()
        }
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
        
        
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
    
    
}

