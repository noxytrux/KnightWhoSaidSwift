//
//  Boolean+KWSExtensions.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 08.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import Foundation
import AudioToolbox

extension Boolean : BooleanType {
    
    public var boolValue: Bool {
        
        switch self {
        case 1 : return true
        case 0 : return false
        default: return true
        }
    }
}

extension Boolean : BooleanLiteralConvertible {
    
    public static func convertFromBooleanLiteral(value: Bool) -> Boolean {
        
        return value ? 1 : 0
    }
}
