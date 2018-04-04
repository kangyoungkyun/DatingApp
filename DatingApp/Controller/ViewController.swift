//
//  ViewController.swift
//  DatingApp
//
//  Created by MacBookPro on 2018. 4. 3..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit
import Firebase
class ViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "로그아웃", style: .plain, target:self , action: #selector(handleLogout))
        //로그아웃 되었을 때 실행
        if Auth.auth().currentUser?.uid == nil{
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
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

