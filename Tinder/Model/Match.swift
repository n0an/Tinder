//
//  Match.swift
//  Tinder
//
//  Created by nag on 25.11.2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import Foundation

struct Match {
    let name: String
    let profileImageUrl: String
    let uid: String
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
