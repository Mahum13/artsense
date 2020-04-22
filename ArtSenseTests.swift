//
//  ArtSenseTests.swift
//  ArtSenseTests
//
//  Created by Mahum Hashmi on 13/01/2020.
//  Copyright © 2020 Mahum Hashmi. All rights reserved.
//

import XCTest
@testable import ArtSense

class ArtSenseTests: XCTestCase {
    
    var photoView = ArtSense.PhotoViewController()
    
    // Create test image of one size, in any colour
    
    func createTestImage(width: CGFloat, height: CGFloat, color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        let ctx = UIGraphicsBeginImageContext(rect.size)
        color.set()
        UIRectFill(rect)
        let testImage = (UIGraphicsGetImageFromCurrentImageContext() ?? nil)!
        UIGraphicsEndImageContext()
        return testImage
    }
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        super.tearDown()
    }

    func testResizeImage() {
        // Resize test image
        var testImage = self.createTestImage(width: 100, height: 100, color: .red)
        let scale = 2.8
        let testHeight = CGFloat(100 * 2.8)
        var resizedImage = photoView.resizeImage(image: testImage, newWidth: 280)
        var newHeight = resizedImage.size.height
        XCTAssertEqual(newHeight, testHeight)
        
        
        
        
    }

}
