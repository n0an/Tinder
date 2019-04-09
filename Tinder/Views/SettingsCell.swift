//
//  SettingsCell.swift
//  Tinder
//
//  Created by nag on 27/03/2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    // MARK: - PROPERTIES
    let textField: UITextField = {
        let tf = SettingsTextField()
        tf.placeholder = "Enter Name"
        return tf
    }()

    // MARK: - INIT
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(textField)
        textField.fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
