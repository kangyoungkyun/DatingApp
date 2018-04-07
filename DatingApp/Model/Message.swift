//
//  Message.swift
//  DatingApp
//
//  Created by MacBookPro on 2018. 4. 5..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit
import Firebase
class Message: NSObject {
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    init(dic:[String:Any]) {
        self.fromId = dic["fromid"] as? String
        self.text = dic["text"] as? String
        self.toId = dic["toid"] as? String
        self.timestamp = dic["timestamp"] as? NSNumber
    }
    
    
    func chatPartnerId() -> String{
        //내가 만약 메시지를 보낸 사람이라면
        if fromId == Auth.auth().currentUser?.uid{
            //파트너아이디는 toid 로 지정:즉 사진은 상대방 사진으로 지정한다는 뜻
            return toId!
        }else{
            //내가 메시지를 보낸 사람이 아니라면, 파트너 아이디는 fromid로 지정
            return fromId!
        }
    }
    


}
