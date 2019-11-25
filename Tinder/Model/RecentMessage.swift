//
//  RecentMessage.swift
//  Tinder
//
//  Created by nag on 25.11.2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import Foundation
import Firebase

struct RecentMessage {
    let text: String
    let uid: String
    let name: String
    let profileImageUrl: String
    
    let timestamp: Timestamp
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
}
