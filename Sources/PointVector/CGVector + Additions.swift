//
//  CGVector + Additions.swift
//
//  Created by Jonathan Hull on 10/12/16.
//  Copyright © 2016 UX Detectives. All rights reserved.
//

import Foundation
import CoreGraphics
import Angle

public extension CGVector {
    
    ///Create a CGVector between two points
    ///- Parameter start: The origin of the vector
    ///- Parameter end: The target point
    init(start:CGPoint, end:CGPoint){
        self.init(dx:end.x - start.x, dy:end.y - start.y)
    }
    
    ///Create a CGVector of the given length and radian angle
    ///- Parameter length: The length of the vector. Defaults to 1.
    ///- Parameter radians: The angle of the vector in radians.
    init(length:CGFloat = 1.0, radians:CGFloat){
        self.init(dx: length * cos(radians), dy: length * sin(radians))
    }
    
    ///Creates a CGVector of the given length and radian angle relative to a reference vector
    ///- Parameter length: The length of the vector. Defaults to 1.
    ///- Parameter radians: The angle of the vector in radians.
    ///- Parameter reference: The vector which the angle is relative to.
    init(length:CGFloat = 1.0, radians:CGFloat, reference:CGVector){
        let newAngle = radians + reference.radians()
        self.init(dx: length * cos(newAngle), dy: length * sin(newAngle))
    }
    
    ///A unit vector pointing to the right
    static var unitRight:CGVector = CGVector(dx: 1, dy: 0)
    ///A unit vector pointing up
    static var unitUp:CGVector = CGVector(dx: 0, dy: -1)
    ///A unit vector pointing left
    static var unitLeft:CGVector = CGVector(dx: -1, dy: 0)
    ///A unit vector pointing down
    static var unitDown:CGVector = CGVector(dx: 0, dy: 1)
    
    ///The angle defined by the vector
    var angle:Angle {
        get{self.angle()}
        set{
            let length = self.length
            self = CGVector(length: length, angle: newValue)
        }
    }
    
    ///The length of the vector
    var length:CGFloat {
        get{sqrt(dx * dx + dy * dy)}
        set{
            self = CGVector(length: newValue, angle: self.angle())
        }
    }
    
    ///The length of the vector squared
    var lengthSquared:CGFloat {
        return dx * dx + dy * dy
    }
    
    ///Returns true if the vector is a unit vector (has length 1)
    var isUnit:Bool {
        return self.lengthSquared == 1
    }
    
    ///Returns a vector with the same angle as the current vector, but with a length of 1.
    var normalized:CGVector {
        let sqLen = self.lengthSquared
        if sqLen == 1 {return self}
        let len = sqrt(sqLen)
        return CGVector(dx: dx/len, dy: dy/len)
    }
    
    ///Returns a vector perpendicular to the current vector in a counter-clockwise direction
    var perpendicular:CGVector {
        return CGVector(dx: -dy, dy: dx)
    }
    
    ///Returns a vector which is perpendicular to the current vector in a clockwise direction
    var clockwisePerpendicular:CGVector {
        return CGVector(dx: dy, dy: dx)
    }
    
    ///Returns a vector with the same length which is pointing in the opposite direction
    var inverse:CGVector {
        return CGVector(dx: -dx, dy: -dy)
    }
    
    ///Returns the dot product of the vector
    func dotProduct(_ vec:CGVector) -> CGFloat {
        return self.dx * vec.dx + self.dy * vec.dy
    }
    
    ///Returns the perpendicular dot product / cross product of the vector
    func crossProduct(_ vec:CGVector) -> CGFloat {
        ///Also sometimes called the perpendicular dot product or cross product magnitude in 2D
        return -self.dy * vec.dx + self.dx * vec.dy
    }
    
    ///Angle between vectors (or from standard if nil)
    func radians(from reference:CGVector? = nil) -> CGFloat {
        if let ref = reference {
            let dot = self.dotProduct(ref)
            if dot == 0 {return 0} //If dot is zero so is mag
            let mag = sqrt(self.lengthSquared * ref.lengthSquared)
            if self.crossProduct(ref) > 0 {
                return -acos(dot/mag)
            }
            return acos(dot/mag)
        }
        
        ///If no reference vector, use unit vector (1,0)
        if self.dy < 0 {
            return -acos(self.dx / self.length)
        }
        return acos(self.dx / self.length)
    }
    
    ///Returns a vector which has been rotated by the given radian angle
    func rotated(byRadians rad:CGFloat) -> CGVector {
        let cosR = cos(rad)
        let sinR = sin(rad)
        return CGVector(dx: dx * cosR - dy * sinR, dy: dx * sinR + dy * cosR)
    }

    ///Shorthand for the inverse of the vector
    static prefix func - (vec:CGVector)->CGVector {
        return CGVector(dx: -vec.dx, dy: -vec.dy)
    }

    //MARK: -
    
    ///Returns the point at the end of the vector, starting from the given origin point
    ///- Parameter origin: A CGPoint representing the origin of the vector
    ///- Returns: A CGPoint at the end of the vector
    func point(from origin:CGPoint) -> CGPoint {
        return CGPoint(x: origin.x + dx, y: origin.y + dy)
    }
    
    ///Returns a point a given distance along the vector from a given point
    ///- Parameter d:The distance to travel along the vector from the origin point
    ///- Parameter origin: The CGPoint to start from
    ///- Returns: A CGPoint the given distance from the start point along the vector
    func point(atDistance d:CGFloat, from origin:CGPoint = .zero) -> CGPoint {
        let norm = self.normalized
        return CGPoint(x: origin.x + d * norm.dx, y: origin.y + d * norm.dy)
    }
    
    ///Returns the y value which is the given distance along the x axis of the vector (starting from the given origin)
    func y(atDistanceAlongX d:CGFloat, from origin:CGPoint = .zero) -> CGFloat {
        guard dx != 0 else {return origin.y}
        return origin.y + d * dy/dx
    }
    
    ///Returns the x value which is the given distance along the y axis of the vector (starting from the given origin)
    func x(atDistanceAlongY d:CGFloat, from origin:CGPoint = .zero) -> CGFloat {
        guard dy != 0 else {return origin.x}
        return origin.x + d * dx/dy
    }
    
    
}

extension CGVector:AdditiveArithmetic {
    public static func + (lhs:CGVector, rhs:CGVector)->CGVector {
        return CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }
    
    public static func += (lhs: inout CGVector, rhs: CGVector) {
        lhs.dx += rhs.dx
        lhs.dy += rhs.dy
    }
    
    public static func - (lhs:CGVector, rhs:CGVector)->CGVector {
        return CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }
    
    public static func -= (lhs: inout CGVector, rhs: CGVector) {
        lhs.dx -= rhs.dx
        lhs.dy -= rhs.dy
    }
}

//MARK: - Mult/Divide by Scalar

extension CGVector {
    ///Multiply by the given scalar value
    static func * (vec:CGVector, scalar:CGFloat)->CGVector {
        return CGVector(dx: vec.dx * scalar, dy: vec.dy * scalar)
    }
    
    ///Multiply by the given scalar value
    static func * (scalar:CGFloat, vec:CGVector)->CGVector {
        return CGVector(dx: vec.dx * scalar, dy: vec.dy * scalar)
    }
    
    ///Divide by the given scalar value
    static func / (vec:CGVector, scalar:CGFloat)->CGVector {
        return CGVector(dx: vec.dx / scalar, dy: vec.dy / scalar)
    }
    
}

extension CGVector {
    
    ///Create a CGVector with the given length and angle from the given reference vector
    init(length:CGFloat = 1.0, angle:Angle, reference:CGVector) {
        self.init(length:length, radians:angle.radians, reference:reference)
    }
    
    ///Returns the angle from the given reference vector (or from the (1,0) normal vector if no reference is provided)
    ///- Parameter ref: The CGVector to measure the angle from. If nil, then the (1,0) normal vector is used
    ///- Returns: The Angle between the vectors
    func angle(from ref:CGVector? = nil) -> Angle {
        if let ref = ref {
            let dot = self.dotProduct(ref)
            if dot == 0 {return Angle.zero} //If dot is zero so is mag
            let mag = sqrt(self.lengthSquared * ref.lengthSquared)
            if self.crossProduct(ref) > 0 {
                return Angle(radians: -acos(dot/mag))
            }
            return Angle(radians: acos(dot/mag))
        }
        
        //If no reference vector, use normal vector (1,0)
        if self.dy < 0 {
            return Angle(radians: -acos(self.dx / self.length))
        }
        return Angle(radians: acos(self.dx / self.length))
    }
    
}


