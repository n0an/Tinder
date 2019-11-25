//
//  Message.swift
//  Tinder
//
//  Created by nag on 25.11.2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import Foundation
import Firebase

struct Message {
    let text: String
    let fromId: String
    let toId: String
    let timestamp: Timestamp
    
    let isFromCurrentLoggedUser: Bool
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.fromId = dictionary["fromId"] as? String ?? ""
        self.toId = dictionary["toId"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        
        self.isFromCurrentLoggedUser = Auth.auth().currentUser?.uid == self.fromId
    }
}
