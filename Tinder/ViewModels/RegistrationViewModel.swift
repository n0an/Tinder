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
    
    func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false && bindableImage.value != nil
        bindableIsFormValid.value = isFormValid
    }
    
    fileprivate func saveImageToFirebase(completion: @escaping (Error?) -> ()) {
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
                
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
                
                
            })
        })
    }
    
    fileprivate func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) -> ()) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData: [String: Any] = [
            "fullName": fullName ?? "",
            "uid": uid,
            "imageUrl1": imageUrl,
            "age": 18,
            "minSeekingAge": SettingsController.defaultMinSeekingAge,
            "maxSeekingAge": SettingsController.defaultMaxSeekingAge
        ]
        
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            if let err = err {
                completion(err)
                return
            }
            
            print("saved to firestore")
            completion(nil)
        }
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
            
            self.saveImageToFirebase(completion: completion)
            
            
        }
    }
}
