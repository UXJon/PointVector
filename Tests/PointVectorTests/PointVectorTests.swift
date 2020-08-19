import XCTest
@testable import PointVector

final class PointVectorTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(PointVector().text, "Hello, World!")
    }
    
    func testPointIntersection() {
        let ptA = CGPoint(x: 1, y: 1)
        let ptB = CGPoint(x: 4, y: 4)
        let ptC = CGPoint(x: 1, y: 8)
        let ptD = CGPoint(x: 2, y: 4)
        
        let vecAB = PointVector(origin: ptA, distantPt: ptB)
        let vecCD = PointVector(origin: ptC, distantPt: ptD)
        
        let intersect = vecAB.pointIntersecting(vector: vecCD) ?? .zero
        let correct = CGPoint(x: 2.4, y: 2.4)
        
        XCTAssertEqual(intersect.x, correct.x, accuracy: 0.000001)
        XCTAssertEqual(intersect.y, correct.y, accuracy: 0.000001)
    }
    
    func testHalfPlane() {
        let inPt = CGPoint(x: 1, y: 2)
        let outPt = CGPoint(x: -2, y: -2)
        let origin = CGPoint.zero
        let onPt = CGPoint(x: 1, y: -1) ///Vector on boundary should register as in half plane
        
        let halfPlane = PointVector(origin: origin, distantPt: CGPoint(x: 1, y: 1))
        
        XCTAssertTrue(inPt.isInHalfPlane(halfPlane))
        XCTAssertFalse(outPt.isInHalfPlane(halfPlane))
        XCTAssertTrue(origin.isInHalfPlane(halfPlane))
        XCTAssertTrue(onPt.isInHalfPlane(halfPlane))
        
    }

    static var allTests = [
        ("interecting vectors", testPointIntersection),
        ("testExample", testExample),
    ]
}
