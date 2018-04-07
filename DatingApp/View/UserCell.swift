//
//  UserCell.swift
//  DatingApp
//
//  Created by MacBookPro on 2018. 4. 5..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit
import Firebase
//테이블 뷰 셀 커스터 마이징
class UserCell: UITableViewCell {
    
    var message:Message?{
        didSet{
            //프로필이미지
            setupNameAndProfileImage()

            self.detailTextLabel?.text = message?.text
            //데이터 포멧 변경 해주기
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
            
        }
    }
    //프로필 이미지 함수
    private func setupNameAndProfileImage(){
//        let chatPartnerId: String?
//        
//        //내가 만약 메시지를 보낸 사람이라면
//        if message?.fromId == Auth.auth().currentUser?.uid{
//            //파트너아이디는 toid 로 지정:즉 사진은 상대방 사진으로 지정한다는 뜻
//            chatPartnerId = message?.toId
//        }else{
//            //내가 메시지를 보낸 사람이 아니라면, 파트너 아이디는 fromid로 지정
//            chatPartnerId = message?.fromId
//        }
        
        //ex) test4(나)가 test2에게 메시지를 보내면
        //test4 메시지창에는 test2의 사진이 뜨고
        //test2의 메시지 창에는 test4의 사진이 뜬다.
        //Message.swift에 chatPartnerId 함수 만들어 줬음
        if let id = message?.chatPartnerId(){
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snap) in
                if let dictionary = snap.value as? [String:AnyObject]{
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String{
                        self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                    }
                }
            })
        }
    }
    
    //cell에 들어갈 이미지 객체 생성
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    //시간 표시 라벨
    let timeLabel: UILabel = {
        
        let label = UILabel()
        //label.text = "hh:mm:ss"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        //시간 표시 라벨 크기 및 위치
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

