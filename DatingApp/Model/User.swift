//
//  User.swift
//  DatingApp
//
//  Created by MacBookPro on 2018. 4. 4..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var name : String?
    var email : String?
    var profileImageUrl: String?
    init(dic:[String:Any]){
        self.name = dic["name"] as? String ?? ""
        self.email = dic["email"] as? String ?? ""
         self.profileImageUrl = dic["profileImageUrl"] as? String
        
    }
    
}
