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
            print(message?.toId)
            if let toId = message?.toId{
                let ref = Database.database().reference().child("users").child(toId)
                ref.observeSingleEvent(of: .value, with: { (snap) in
                    if let dictionary = snap.value as? [String:AnyObject]{
                        self.textLabel?.text = dictionary["name"] as? String
                        print("이름 - \(self.textLabel?.text)")
                        if let profileImageUrl = dictionary["profileImageUrl"] as? String{
                            self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                        }
                    }
                })
            }
            self.detailTextLabel?.text = message?.text
             print("디테일 - \(self.detailTextLabel?.text)")
            //self.timeLabel.text = message?.timestamp
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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
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

