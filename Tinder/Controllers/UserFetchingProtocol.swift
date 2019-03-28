//
//  UserFetchingProtocol.swift
//  Tinder
//
//  Created by nag on 28/03/2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import Foundation
import Firebase

protocol UserFetchingProtocol: AnyObject {
    var user: User? { get set }
    
    func fetchCurrentUser()
    
    func didFetchedUser()
    
}

extension UserFetchingProtocol {
    func fetchCurrentUser() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            guard let dict = snapshot?.data() else { return }
            self.user = User(dictionary: dict)
            
            self.didFetchedUser()
        }
    }
}
