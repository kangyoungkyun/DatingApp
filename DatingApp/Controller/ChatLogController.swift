//
//  ChatLogController.swift
//  DatingApp
//
//  Created by MacBookPro on 2018. 4. 5..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController,UITextFieldDelegate,UICollectionViewDelegateFlowLayout {

    //newMessagesController -> messagesController -> chatLog 순으로 user 정보를 넘겨줌
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessage()
        }
    }
    
    var messages = [Message]()
    func observeMessage(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        //user-messages에서 내가 쓰고, 내가 받은 메시지들의 id를 가져온다.
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded) { (snapshot) in
            
            //그 내용을 가져온다.
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                //nil값 검사
                guard let dictionary = snapshot.value as? [String:AnyObject] else {
                    return
                }
                //모두 메시지 dto에 넣어준다.
                let message = Message(dic: dictionary)
                //message.setValuesForKeys(dictionary)
                //파트너 아이디와 내가 클릭한 사람의 아이디가 같다면 그 아이디에 해당하는 내용만 가져와라
                if message.chatPartnerId() == self.user?.id{
                    self.messages.append(message)
                    //백그라운드 쓰레드
                    DispatchQueue.main.async(execute: {
                        self.collectionView?.reloadData()
                    })
                    
                }
                
            })
        }
    }
    
    
    //채팅창 택스트 필드
    lazy var inputTextField:UITextField = {
      let textField = UITextField()
        textField.placeholder = "메시지를 입력하세요."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    //진입점
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        setupInputComponents()
    
    }
    
    let cellId = "cellId"
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    
    func setupInputComponents(){
        //채팅입력창 묶을 콘테이너 박스
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        //콘테이너 박스 위치 크기 조정
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //보내기 버튼
        let sendButton = UIButton(type:.system)
        sendButton.setTitle("보내기", for: UIControlState())
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //보내기 버튼 크기 위치 조정
        sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        //택스트 필드 위치 크기 조정
        inputTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        //구분선 객체
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    //보내기 버튼 함수
    @objc func handleSend(){
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let toId = user?.id!
        let fromId = Auth.auth().currentUser?.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        
        let values = ["text" : inputTextField.text! , "toid" : toId, "fromid":fromId, "timestamp":timestamp] as [String: Any]
        //childRef.updateChildValues(values)
        //메시지 내용을 넣고
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error)
                return
            }
            //내아이디가 들어간다.
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId!)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId:1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId!)
            recipientUserMessagesRef.updateChildValues([messageId:1])
            
        }
        
        
    }
    
    //엔터키 눌렀을 때 메시지 보내기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}


















