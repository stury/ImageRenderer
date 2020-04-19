import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif
import XCTest
@testable import ImageRenderer

final class ImageRendererTests: XCTestCase {

//    func testLoadPNG() {
//        let mainBundle = Bundle(for: ImageRendererTests.self)
//        if let path = mainBundle.path(forResource:"braided_aldousBroder_1", ofType:"png") {
//            let renderer = ImageRenderer()
//            let images = renderer.raster( path )
//
//            XCTAssertNil( images )
//            XCTAssertNotEqual( images.count, 1)
//        }
//        else {
//            print( mainBundle )
//            XCTFail("Could not find resource!!")
//        }
//    }
//
//    func testLoadPDF() {
//        let mainBundle = Bundle.main
//        if let path = mainBundle.path(forResource:"braided_aldousBroder_1", ofType:"pdf") {
//            let renderer = ImageRenderer()
//            let images = renderer.raster( path )
//
//            XCTAssertNil( images )
//            XCTAssertNotEqual( images.count, 1)
//        }
//        else {
//            XCTFail("Could not find resource!!")
//        }
//    }
    
    func testRasterImage() {
        let renderer = ImageRenderer()
        let image = renderer.raster( size: CGSize(width:100, height:100), drawing: { (context) in
            context.saveGState()
            
            #if os(macOS)
            context.setStrokeColor( CGColor(red:0.0, green:0.0, blue:1.0, alpha: 1.0) )
            #else
            context.setStrokeColor( UIColor.blue.cgColor )
            #endif
            
            context.addRect( CGRect(x:50, y:50, width:50, height:50) )
            
            context.strokePath()
            context.restoreGState()
        } )
        XCTAssertNotNil( image )
//        if let image = image {
//            
//        }

    }

    static var allTests = [
//        ("testLoadPNG", testLoadPNG),
//        ("testLoadPDF", testLoadPDF),
            ("testRasterImage", testRasterImage),
    ]
}
