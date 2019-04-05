//
//  Firebase+User.swift
//  Tinder
//
//  Created by nag on 05/04/2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import Firebase

extension Firestore {
    func fetchCurrentUser(completion: @escaping (User?, Error?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                completion(nil, err)
                return
            }
            
            // fetched our user here
            guard let dictionary = snapshot?.data() else {
                let error = NSError(domain: "swipematch", code: 500, userInfo: [NSLocalizedDescriptionKey: "No user found in Firestore"])
                completion(nil, error)
                return
            }
            let user = User(dictionary: dictionary)
            completion(user, nil)
        }
    }
}

