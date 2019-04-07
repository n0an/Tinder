//
//  Advertiser.swift
//  Tinder
//
//  Created by nag on 28/12/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

struct Advertiser: ProducesCardViewModel {
    
    // MARK: - PROPERTIES
    let title: String
    let brandName: String
    let posterPhotoName: String
    
    // MARK: - HELPER METHODS
    func toCardViewModel() -> CardViewModel {
        
        let attributedText = NSMutableAttributedString(string: title, attributes: [.font: UIFont.systemFont(ofSize: 34, weight: .heavy)])
        attributedText.append(NSAttributedString(string: "\n\(brandName)", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .bold)]))
        
        return CardViewModel(uid: "", imageNames: [posterPhotoName], attributedString: attributedText, textAlignment: .center)
    }
}
