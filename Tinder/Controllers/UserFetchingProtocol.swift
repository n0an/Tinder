//
//  UserFetchingProtocol.swift
//  Tinder
//
//  Created by nag on 28/03/2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import Foundation
import Firebase
import JGProgressHUD

protocol UserFetchingProtocol: UIViewController {
    var user: User? { get set }
    
    func fetchCurrentUser()
    
    func didFetchedUser()
    
}

extension UserFetchingProtocol {
    func fetchCurrentUser() {
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            hud.dismiss()
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
