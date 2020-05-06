//
//  Image.swift
//  ImageRenderer
//
//  Created by J. Scott Tury on 7/22/18.
//  Copyright © 2018 self. All rights reserved.
//

// MARK: - macOS Specific code

#if os(macOS)

import Cocoa
/// Create an alias for NSImage that is called Image.  This way we can use the same code on iOS and macOS platforms.
public typealias Image = NSImage

// Extensions for a few UIImage methods/constructors we use internally.
public extension NSImage {
    
    /**
        Convienience initializer so we can instantialte an NSImage object with a CGImage.
        - parameter cgImage: The CGImage object you want to initialize the NSImage with.
     */
    convenience init(cgImage: CGImage) {
        self.init(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
    }
    
    /**
        Computed property for accessing the CGImage assotiated with an NSImage object.
     */
    var cgImage : CGImage? {
        get {
            var result : CGImage?
            if let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                result = cgImage
            }
            return result
        }
    }
}

#endif

// MARK: - iOS, tvOS, watchOS Specific code
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
/// Create an alias for UIImage that is called Image.  This way we can use the same code on iOS and macOS platforms.
public typealias Image = UIImage

extension UIImage {
    
    /**
    This method mimicks the NSImage convienience initializer for iOS!
     - parameter url: The URL of the file to open.  (This should be a file:// URL.)
     */
    public convenience init?(contentsOf url: URL) {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        self.init(data: data)
    }
}
#endif

// MARK: - OS Agnostic

/// global constant for referencing a device RGB color space.  (Only used internally.)
let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
/// Constant CGBitmapInfo value we use when creating bitmaps.
let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

/**
 Basic class that makes UIImage/NSImage operate like the same type of class on either macOS, iOS, watchOS and tvOS.
 */
public extension Image {
    
    /**
      Simple method for generating a CGContext, filled in with a particular background color.
     
        - parameter size: (Int, Int) of what size image you want to create.
        - parameter color: (CGFlloat, CGFloat, CGFloat, CGFloat) specifying the color you want filled into the image when it's created.
 
      - returns: A new CGContext if the bitmap was created.
     */
    static func context( size: (Int, Int), color:(CGFloat, CGFloat, CGFloat, CGFloat)) -> CGContext? {
        var result: CGContext?
        
        // Create a bitmap graphics context of the given size
        //
        let colorSpace = rgbColorSpace // CGColorSpaceCreateDeviceRGB()
        if let context = CGContext(data: nil, width: size.0, height: size.1, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue ) {
            
            // Draw the background color...
            context.setFillColor(red: color.0, green: color.1, blue: color.2, alpha: color.3)
            context.fill(CGRect(x: 0, y: 0, width: size.0, height: size.1))
            
            result = context
        }
        
        return result
    }
    
    /**
      This is a simple method for generating App Icons based on a single image.
     
      - parameter image: The Image you want to use as your basic Application Icon.
      - returns: A new Image object whose size is 1024 x 1024.
     */
    static func appIconImage(with image: Image ) -> Image? {
        var result : Image? = nil
        
        if let cgImage = image.cgImage {
            if let context = Image.context(size: (1024, 1024), color: (1.0, 1.0, 1.0, 1.0)) {
                let width = image.size.width
                let height = image.size.height
                let x = (1024 - width) / 2.0
                let y = (1024 - height) / 2.0
                
                context.draw(cgImage, in: CGRect(x: x, y: y, width: width, height: height))
                
                if let cgImage = context.makeImage() {
                    result = Image(cgImage: cgImage)
                }
            }
        }
        return result
    }
    
    /**
      Simple method for resizing a given image to a specific size...
     
      - parameter size: The (Int, Int) specifying the new size of the bitmap you want to create.
      - returns: A new Image object with the image horizontal line added in.
     */
    func resize(size: (Int, Int) ) -> Image? {
        var result : Image? = nil
        
        if let cgImage = self.cgImage {
            if let context = Image.context(size: size, color: (1.0, 1.0, 1.0, 1.0)) {
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.0, height: size.1))
                
                if let cgImage = context.makeImage() {
                    result = Image(cgImage: cgImage)
                }
            }
        }
        return result
    }
    
    /**
      Simple method for drawing a horizontal line at a particular location in the Image.
     
      - parameter at: The CGFloat for where you want the line to e drawn.
      - parameter color: The Double triplet that allows you to specify the color of the horizontal line you want to draw.  (Default value is GREEN.)
      - returns: A new Image object with the image horizontal line added in.
     */
    func drawHorizontalLine(at: CGFloat, color: (Double, Double, Double) = (0.0, 1.0, 0.0) ) -> Image? {
        var result : Image? = nil
        
        if let cgImage = self.cgImage {
            let size = (Int(self.size.width),Int(self.size.height))
            if let context = Image.context(size: size, color: (1.0, 1.0, 1.0, 1.0)) {
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.0, height: size.1))
                
                context.setStrokeColor(CGColor.from(color))
                context.drawLineSegment(points: [(0, Int(at)), (size.0, Int(at))])
                
                if let cgImage = context.makeImage() {
                    result = Image(cgImage: cgImage)
                }
            }
        }
        return result
    }
    
    /**
     This method will allow you to crop an image to a specified Rect
     
     - parameter rect: The rectangle you woud like cut out from the Image.
     - returns: A new Image object with the image cropped to the specified area.
     */
    func crop(_ rect: CGRect) -> Image? {
        var result : Image? = nil
        
        if let cgImage = self.cgImage {
            if let croppedImage = cgImage.cropping(to: rect) {
                result = Image(cgImage: croppedImage)
            }
        }
        
        return result
    }
    
    /**
     Simple method to retrieve the image as a PNG data, that can be written to disk.
     
     - returns: If the method was able to extract the PNG data for the current Image, you would get a Data object back, that you could write to disk.
     */
    func data() -> Data? {
        var result : Data? = nil
        
        let image = self
        #if os(macOS)
        if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            let bitmap = NSBitmapImageRep(cgImage: cgImage)
            if let data = bitmap.representation(using: .png, properties: [:]) {
                result = data
            }
        }
        #elseif os(iOS)
        result = image.pngData()
        #endif

        return result
    }
    
}
