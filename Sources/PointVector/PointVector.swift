//
//  PointVector.swift
//  DrawKit Attempt 5
//
//  Created by Jonathan Hull on 5/29/19.
//  Copyright © 2019 UX Detectives. All rights reserved.
//

import Foundation
import CoreGraphics
import Angle

///A PointVector is a vector anchored at a point. Useful for graphics calculations as well as user interfaces which allow dragging along an arbitrary line (e.g. to resize an object proportionally).
struct PointVector {
    ///The origin which anchors the vector
    var origin:CGPoint
    ///A CGVector which is anchored on the point
    var vector:CGVector
    
    ///Creates a PointVector using an origin point and a vector. This is the default initializer
    ///- Parameter origin: The starting point of the vector
    ///- Parameter vector: The vector which is anchored on the point
    init(origin:CGPoint, vector:CGVector) {
        self.origin = origin
        self.vector = vector.normalized
    }
    
    ///Creates a unit PointVector using an origin point and an angle.
    ///- Parameter origin: The starting point of the vector
    ///- Parameter angle: the angle of the unit vector
    init(origin:CGPoint, angle:Angle) {
        self.origin = origin
        self.vector = CGVector(angle: angle)
    }
    
    ///Creates a PointVector using two points. Optionally allows the vector to be inverted
    ///- Parameter origin: The starting point of the vector
    ///- Parameter distantPt: The end point of the vector
    ///- Parameter invert: True if the vector should be inverted. Default is false.
    init(origin:CGPoint, distantPt:CGPoint, invert:Bool = false){
        self.origin = origin
        if invert {
            self.vector = CGVector(start: origin, end: distantPt).normalized.inverse
        }else{
            self.vector = CGVector(start: origin, end: distantPt).normalized
        }
    }
    
    ///The end point of the vector
    var endPoint:CGPoint {
        get{vector.point(from: origin)}
        set{
            self.vector = CGVector(start: origin, end: newValue)
        }
    }
    
    ///The angle of the vector
    var angle:Angle {
        get{vector.angle()}
        set{vector.angle = newValue}
    }
    
    ///Gives a point at a given distance from the origin along the vector
    ///- Parameter distance: The distance to travel along the vector
    ///- Returns: A CGPoint the given distance from the origin along the vector
    func point(atDistance distance:CGFloat) -> CGPoint {
        return vector.point(atDistance: distance, from: origin)
    }
    
    ///Gives a point at a given distance along the perpendicular of the vector
    ///- Parameter distance: The distance to travel along the perpendicular vector
    ///- Parameter clockwise: Whether to choose the clockwise or counter-clockwise perpendicular. Defaults to counter-clockwise.
    ///- returns: A CGPoint the given distance along the perpendicular
    func pointAlongPerpendicular(atDistance distance:CGFloat, clockwise:Bool = false) -> CGPoint {
        if clockwise {
            return vector.clockwisePerpendicular.point(atDistance: distance, from: origin)
        }
        return vector.perpendicular.point(atDistance: distance, from: origin)
    }
    
    ///Gives a pair of points separated by the given distance along the perpendicular axis (centered on the origin).
    ///- Parameter separation: The distance between the resulting points
    ///- Returns: A Two-Tuple of points along the perpendicular axis separated by the given amount
    func parallelPoints(separation:CGFloat) -> (CGPoint,CGPoint) {
        let halfSep = separation/2.0
        return (self.pointAlongPerpendicular(atDistance: halfSep),
                self.pointAlongPerpendicular(atDistance: halfSep, clockwise: true))
    }
    
    ///Gives a pair of points which are found by traveling a given distance along the vector, and then separated in the perpendicular axis by the given amount. Useful for complex drawing calculations.
    ///- Parameter distance: The distance to travel from the origin along the vector
    ///- Parameter separation: The distance to separate the points along the perpendicular axis
    ///- Returns: A two-tuple of points
    func pointsParallelToPoint(atDistance distance:CGFloat, separation:CGFloat) -> (CGPoint,CGPoint) {
        return self.withOrigin(atDistance: distance).parallelPoints(separation: separation)
    }
    
    ///A new PointVector with it's origin at the given distance along the vector
    func withOrigin(atDistance distance:CGFloat) -> PointVector {
        return PointVector(origin: self.point(atDistance: distance), vector: vector)
    }
    
    ///A new PointVector with it's origin at the given distance along the perpendicular of the vector
    ///- Parameter distance: The distance to travel along the perpendicular vector
    ///- Parameter clockwise: Whether to choose the clockwise or counter-clockwise perpendicular. Defaults to counter-clockwise.
    func withOriginAlongPerpendicular(atDistance distance:CGFloat, clockwise:Bool = false) -> PointVector {
        let pt = self.pointAlongPerpendicular(atDistance: distance, clockwise: clockwise)
        return PointVector(origin: pt, vector: vector)
    }

    ///A PointVector which is (counter-clockwise) perpendicular to the vector
    var perpendicular:PointVector {
        return PointVector(origin: origin, vector: vector.perpendicular)
    }
    
    ///A PointVector which is clockwise perpendicular to the vector
    var clockwisePerpendicular:PointVector {
        return PointVector(origin: origin, vector: vector.clockwisePerpendicular)
    }
    
    ///A PointVector which is pointing in the opposite direction
    var inverse:PointVector {
        return PointVector(origin: origin, vector: vector.inverse)
    }
    
    ///A PointVector which is rotated by the given angle
    ///- Parameter angle: The Angle to rotate by
    ///- Returns: A PointVector rotated by the given angle
    func rotated(by angle: Angle) -> PointVector {
        return PointVector(origin: origin, vector: vector.rotated(by: angle))
    }
    
    ///Calculates the point along the vector which intersects a given y value (returns nil if the vector is horizontal)
    ///- Parameter y: The y value to intersect
    ///- Parameter allowInverse: True if the intesection is allowed to be found behind the vector. Default is true.
    ///- Returns: The point of intersection or nil if no intersection exists
    func pointIntersecting(horizontal y:CGFloat, allowInverse:Bool = true) -> CGPoint? {
        guard vector.dy != 0 else {return nil}///The vector is horizontal and will never intersect another horizontal line (or will infinitely intersect)
        let dist = y - origin.y
        guard dist >= 0 || allowInverse else {return nil}
        let x = vector.x(atDistanceAlongY: dist, from: origin)
        return CGPoint(x: x, y: y)
    }
    
    ///Calculates the point along the vector which intersects a given x value (returns nil if the vector is vertical)
    ///- Parameter x: The x value to intersect
    ///- Returns: The point of intersection or nil if no intersection exists
    func pointIntersecting(vertical x:CGFloat, allowInverse:Bool = true) -> CGPoint? {
        guard vector.dx != 0 else {
            return nil ///The vector is vertical and will never intersect another vertical line (or will infinitely intersect)
        }
        let dist = x - origin.x
        guard dist >= 0 || allowInverse else {return nil}
        let y = vector.y(atDistanceAlongX: dist, from: origin)
        return CGPoint(x: x, y: y)
    }
    
    ///Calculates the intersection points of the vector with a rectangle (returns nil if no intersection).
    ///- Parameter rect: The rect to intersect
    ///- Returns: A two-tuple of points which intersect or nil if no intersection exists.
    func pointsIntersecting(rect:CGRect) -> (CGPoint,CGPoint)? {
        guard let leftPt = pointIntersecting(vertical: rect.minX) else{
            ///Line is vertical
            if origin.x >= rect.minX && origin.x <= rect.maxX { //If it intersects rect
                return (CGPoint(x: origin.x, y: rect.minY), CGPoint(x: origin.x, y: rect.maxY))
            }
            return nil
        }
        let rightPt = pointIntersecting(vertical: rect.maxX)!
        
        if leftPt.y < rect.minY { //Line intersects left above rect
            guard rightPt.y >= rect.minY else {return nil} //Line passes entirely above rect
            let topPt = pointIntersecting(horizontal: rect.minY)! //Has to intersect top
            if rightPt.y <= rect.maxY {
                return (topPt,rightPt) //Intersect on top and right sides
            }
            let botPt = pointIntersecting(horizontal: rect.maxY)! //Has to intersect bottom
            return (topPt,botPt)
            
        }else if leftPt.y > rect.maxY { //Line intersects left below rect
            guard rightPt.y <= rect.maxY else {return nil} //line passes entirely below rect
            let botPt = pointIntersecting(horizontal: rect.maxY)! //Has to intersect bottom
            if rightPt.y >= rect.minY {
                return (botPt,rightPt) //Intersect on bottom and right sides
            }
            let topPt = pointIntersecting(horizontal: rect.minY)! //Has to intersect top
            return (topPt,botPt)
        }
        
        ///Intersects left side of rect
        if rightPt.y < rect.minY {
            let topPt = pointIntersecting(horizontal: rect.minY)! //Must intersect top
            return (leftPt,topPt)
            
        }else if rightPt.y > rect.maxY {
            let botPt = pointIntersecting(horizontal: rect.maxY)! //Must intersect bottom
            return (leftPt,botPt)
        }
        
        return (leftPt,rightPt)
    }
    
}
