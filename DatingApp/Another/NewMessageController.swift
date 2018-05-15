//
//  NewMessageController.swift
//  DatingApp
//
//  Created by MacBookPro on 2018. 4. 4..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit
import Firebase
class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    
    var users = [User]()
    
    //진입점
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }
    
    //유저 가져오기
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //firebase의 키 값과 User 데이터 모델의 변수 값이 같아야 함
                let user = User(dic: dictionary)
                user.id = snapshot.key //user 식별자도 함께 넣어준다.
                self.users.append(user)
                
                //그냥 쓰면 백그라운드 쓰레드라서 충돌남 dispatch_async 사용해야함
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            
        }, withCancel: nil)
    }
    
    //배열 개수 만큼 테이블의 행 지정
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    //테이블 구성
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? UserCell
        
        let user = users[indexPath.row]
        cell?.textLabel?.text = user.name
        cell?.detailTextLabel?.text = user.email
        //이미지 캐치 확인 함수 호출
        if let profileImageUrl = user.profileImageUrl {
            cell?.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    //유저 행을 클릭했을 때
    var messagesController : MessageController?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            print("유저 목록 닫기")
            let user = self.users[indexPath.row]
            //messagecontroller에 있는 showchatcontroller 함수를 사용해야 함
            self.messagesController?.showChatControllerForUser(user: user)
        }
    }
    
    
    
    //닫기 함수
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}

