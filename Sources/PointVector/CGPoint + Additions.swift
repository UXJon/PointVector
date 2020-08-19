//
//  File.swift
//  
//
//  Created by Jonathan Hull on 8/19/20.
//

import Foundation
import CoreGraphics

public extension CGPoint {
    
    ///Calculate the distance between two points
    func distance(to:CGPoint) -> CGFloat {
        return sqrt(pow(self.x - to.x, 2) + pow(self.y - to.y, 2))
    }
    
    ///Returns true if the point lies in the half plane defined in the direction of the given point vector. The boundary is the line running perpendicular to the vector through it's origin point.
    func isInHalfPlane(_ vector:PointVector) -> Bool {
        if vector.isHorizontal {
            if vector.vector.dy <= 0 {
                return self.y <= vector.origin.y
            }
            return self.y >= vector.origin.y
        }else if vector.isVertical {
            if vector.vector.dx <= 0 {
                return self.x <= vector.origin.x
            }
            return self.x >= vector.origin.x
        }
        let perp = vector.perpendicular
        let cross = perp.vector.crossProduct(CGVector(start: vector.origin, end: self))
        if cross == 0 {return true} //On the boundary
        let ptSign = cross >= 0
        let vecSign = perp.vector.crossProduct(vector.vector) >= 0
        return ptSign == vecSign
    }
}
