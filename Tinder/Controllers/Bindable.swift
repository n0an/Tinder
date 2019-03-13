//
//  Bindable.swift
//  Tinder
//
//  Created by nag on 13/03/2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import Foundation

struct Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    
    var observer: ((T?)->())?
    
    mutating func bind(observer: @escaping (T?) ->()) {
        self.observer = observer
    }
    
}
