//
//  User.swift
//  Tinder
//
//  Created by nag on 27/12/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

struct User: ProducesCardViewModel {
    
    // MARK: - PROPERTIES
    var uid: String?
    var name: String?
    var age: Int?
    var profession: String?
    
    var imageUrl1: String?
    var imageUrl2: String?
    var imageUrl3: String?

    var minSeekingAge: Int?
    var maxSeekingAge: Int?
    
    // MARK: - INIT
    init(dictionary: [String: Any]) {
        
        let name = dictionary["fullName"] as? String ?? ""
        self.name = name
        
        self.age = dictionary["age"] as? Int
        self.profession = dictionary["profession"] as? String
        
        self.imageUrl1 = dictionary["imageUrl1"] as? String
        self.imageUrl2 = dictionary["imageUrl2"] as? String
        self.imageUrl3 = dictionary["imageUrl3"] as? String

        self.uid = dictionary["uid"] as? String ?? ""
        
        self.minSeekingAge = dictionary["minSeekingAge"] as? Int
        self.maxSeekingAge = dictionary["maxSeekingAge"] as? Int
    }
    
    // MARK: - HELPER METHODS
    func toCardViewModel() -> CardViewModel {
        
        let ageString = age != nil ? "\(age!)" : #"N\A"#
        let professionString = profession != nil ? profession! : "Not available"
        
        let attributedText = NSMutableAttributedString(string: name ?? "", attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])
        attributedText.append(NSAttributedString(string: "  \(ageString)", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))
        attributedText.append(NSAttributedString(string: "\n\(professionString)", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
        
        var imageUrls = [String]()
        
        if let url = imageUrl1 { imageUrls.append(url) }
        if let url = imageUrl2 { imageUrls.append(url) }
        if let url = imageUrl3 { imageUrls.append(url) }

        return CardViewModel(uid: self.uid ?? "", imageNames: imageUrls, attributedString: attributedText, textAlignment: .left)
    }
}

