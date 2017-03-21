//
//  Messages.swift
//  ODDBITChat_Project
//
//
//  Created by I Wayan Surya Adi Yasa on 3/20/17.
//  Copyright © 2017 Imac 5K Surya Adi. All rights reserved.
//


import UIKit
import Firebase

class Messages: NSObject {
    
    var fromId : String?
    var text : String?
    var timestamp : NSNumber?
    var toId : String?
    
    func chatPartnerId() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
}
