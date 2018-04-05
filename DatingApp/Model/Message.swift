//
//  Message.swift
//  DatingApp
//
//  Created by MacBookPro on 2018. 4. 5..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit

class Message: NSObject {
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    init(dic:[String:Any]) {
        self.fromId = dic["fromId"] as? String
        self.text = dic["text"] as? String
        self.toId = dic["toId"] as? String
        self.timestamp = dic["timestamp"] as? NSNumber
    }

}
