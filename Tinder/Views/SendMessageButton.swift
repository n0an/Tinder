//
//  SendMessageButton.swift
//  Tinder
//
//  Created by nag on 03/04/2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import UIKit

class SendMessageButton: UIButton {

    // MARK: - DRAW
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let gradientLayer = CAGradientLayer()
        let leftColor = #colorLiteral(red: 0.9108716846, green: 0.3093190193, blue: 0.4357300997, alpha: 1)
        let rightColor = #colorLiteral(red: 0.9210886955, green: 0.425493598, blue: 0.3326678276, alpha: 1)

        gradientLayer.colors = [leftColor.cgColor, rightColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        
        layer.cornerRadius = rect.height / 2
        layer.masksToBounds = true
        
        gradientLayer.frame = rect
    }
}
