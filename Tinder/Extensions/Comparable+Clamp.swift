//
//  Comparable+Clamp.swift
//  Tinder
//
//  Created by nag on 30/12/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import Foundation

extension Comparable {
    func clamp(low: Self, high: Self) -> Self {
        if (self > high) {
            return high
        } else if (self < low) {
            return low
        }
        
        return self
    }
}
