//
//  RegistrationViewModel.swift
//  Tinder
//
//  Created by nag on 18/02/2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewModel {
    
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    var bindableIsRegistering = Bindable<Bool>()
    
    var fullName: String? {
        didSet {
            checkFormValidity()
        }
    }
    var email: String? { didSet {checkFormValidity()} }
    var password: String? { didSet {checkFormValidity()} }
    
    fileprivate func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false
        bindableIsFormValid.value = isFormValid

    }
    
    func performRegistration(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        
        bindableIsRegistering.value = true

        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            
            if let err = err {

                completion(err)
                return
            }
            
            print("Registered", res?.user.uid ?? "")
            
            let filename = UUID().uuidString
            let ref = Storage.storage().reference(withPath: "/images/\(filename)")
            
            let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
            
            ref.putData(imageData, metadata: nil, completion: { (_, err) in
                if let err = err {
                    print("===== err ref.putData ======")
                    completion(err)
                    return
                }
                
                print("Finished uploading image to storage")
                
                ref.downloadURL(completion: { (url, err) in
                    
                    if let err = err {
                        print("===== err ref.downloadURL ======")

                        completion(err)
                        return
                    }
                    
                    print("Download url of our image is:", url?.absoluteString ?? "")
                    self.bindableIsRegistering.value = false
                    completion(nil)
                })
            })
        }
    }
}
