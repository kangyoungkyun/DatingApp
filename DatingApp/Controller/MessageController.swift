//
//  ViewController.swift
//  DatingApp
//
//  Created by MacBookPro on 2018. 4. 3..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}
import UIKit
import Firebase
class MessageController: UITableViewController {
    
    let cellId = "cellId"
    var messagesController: MessageController?
    var ref: DatabaseReference!
    
    //진입점
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "로그아웃", style: .plain, target:self , action: #selector(handleLogout))
        
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        //로그인or로그아웃 체크
        checkIfUserIsLoggedIn()
        
        //메시지 기록 가져오기
        //observeMessages()
        
        //유저별 메시지 기록 가져오기
        observeUserMessage()
        
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    //유저별 메시지 기록 가져오기
    func observeUserMessage(){
        //내가 로그인한 아이디
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded) { (snapshot) in
            
            let messageId = snapshot.key
            let messagesReference = Database.database().reference().child("messages").child(messageId)
            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot) //Snap (-L9SalCeOBfqY6VvGo71) 1 - 메시지 아이디가 나온다.
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    let message = Message(dic: dictionary)
                    
                    if let toId = message.toId {
                        self.messagesDictionary[toId] = message
                        
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            
                            return message1.timestamp?.intValue > message2.timestamp?.intValue
                        })
                    }
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
                
            })
        }
    }
    
    

    //메시지 기록 가져오기
    func observeMessages() {
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let message = Message(dic: dictionary)
                
                //self.messages.append(message)
                //let message = Message(dictionary: dictionary)
                //                self.messages.append(message)
                
                if let toId = message.toId {
                    self.messagesDictionary[toId] = message
                    
                    self.messages = Array(self.messagesDictionary.values)
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        
                        return message1.timestamp?.intValue > message2.timestamp?.intValue
                    })
                }
                
                
                
                //this will crash because of background thread, so lets call this on dispatch_async main thread
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            
        }, withCancel: nil)
    }
    //테이블 행
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    //테이블 구성
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
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
        let titleView = MyUIView()
        
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
        //containerView.isUserInteractionEnabled = true
    }
    
    //이름 클릭
    func showChatControllerForUser(user : User){
        print(" message controller에서 user 정보를 chatlogVC 넘겨줌~~~")
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    
    
    //새로운 메시지 쓰기
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        //newMessageContrller에 있는 messageController는 나 자신이야
        //newMessageController에서 messagecontroller에 있는 showchatcontroller 함수를 사용해야 하기 때문에
        newMessageController.messagesController = self
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

