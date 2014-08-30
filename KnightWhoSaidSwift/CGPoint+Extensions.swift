//
//  CGPoint+Extensions.swift
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 30.08.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

import Foundation
import UIKit

func * (left: CGPoint, right : CGFloat) -> CGPoint {
    
    return CGPointMake(left.x * right, left.y * right)
}

func * (left: CGPoint, right : CGPoint) -> CGPoint {
    
    return CGPointMake(left.x * right.x, left.y * right.y)
}

func / (left: CGPoint, right : CGFloat) -> CGPoint {
    
    return CGPointMake(left.x / right, left.y / right)
}

func / (left: CGPoint, right : CGPoint) -> CGPoint {
    
    return CGPointMake(left.x / right.x, left.y / right.y)
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {

    return CGPointMake(left.x + right.x, left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    
    return CGPointMake(left.x - right.x, left.y - right.y)
}

func += (inout left: CGPoint, right: CGPoint) {

    left = left + right
}

func -= (inout left: CGPoint, right: CGPoint) {
    
    left = left - right
}

func *= (inout left: CGPoint, right: CGPoint) {

    left = left * right
}

func /= (inout left: CGPoint, right: CGPoint) {
    
    left = left / right
}

extension CGPoint {

    
}