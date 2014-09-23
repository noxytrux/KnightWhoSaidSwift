//
//  CGFloat+Extensions.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 30.08.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import Foundation
import UIKit

prefix operator √ {}

prefix func √ (number: CGFloat) -> CGFloat {
    return sqrt(number)
}

extension CGFloat {
    
    static func random(minimum: CGFloat, maximum: CGFloat) -> CGFloat {
        
        return minimum + CGFloat(Float(rand())) / (CGFloat(Float(RAND_MAX))/(maximum-minimum))
    }
    
}
