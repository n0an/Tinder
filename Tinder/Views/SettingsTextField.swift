//
//  SettingsTextField.swift
//  Tinder
//
//  Created by nag on 09/04/2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import UIKit

// MARK: - SettingsTextField
class SettingsTextField: UITextField {
    
    // MARK: - UITEXTFIELD OVERRIDES
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 24, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 24, dy: 0)
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 44)
    }
}
