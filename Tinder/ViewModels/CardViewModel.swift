//
//  CardViewModel.swift
//  Tinder
//
//  Created by nag on 28/12/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

class CardViewModel {
    let imageNames: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    fileprivate var imageIndex = 0 {
        didSet {
//            let imageName = imageNames[imageIndex]
//            let imageUrl = UIImage(named: imageName)
            
            let imageUrl = imageNames[imageIndex]
            imageIndexObserver?(imageIndex, imageUrl)
        }
    }
    
    init(imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.imageNames = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
    
    var imageIndexObserver: ((Int, String?) -> ())?
    
    func advanceToNextPhoto() {
        imageIndex = min(imageIndex + 1, imageNames.count - 1)
    }
    
    func goToPreviousPhoto() {
        imageIndex = max(0, imageIndex - 1)
    }
}
