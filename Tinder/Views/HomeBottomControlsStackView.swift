//
//  HomeBottomControlsStackView.swift
//  Tinder
//
//  Created by nag on 23/12/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

class HomeBottomControlsStackView: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        distribution = .fillEqually
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        let buttons = [#imageLiteral(resourceName: "3 1"), #imageLiteral(resourceName: "3 2"), #imageLiteral(resourceName: "3 3"), #imageLiteral(resourceName: "3 4"), #imageLiteral(resourceName: "3 5")].map { (img) -> UIView in
            let button = UIButton(type: .system)
            button.setImage(img.withRenderingMode(.alwaysOriginal), for: .normal)
            return button
        }

        buttons.forEach { (v) in
            addArrangedSubview(v)
        }
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
