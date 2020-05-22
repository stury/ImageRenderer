//
//  MultiImageRenderer.swift
//  ImageRenderer
//
//  A simple class to allow you to programatically create images without having to know
//  all the ins and outs of Core Graphics.  This one allows you to continuously draw to
//  the same canvas over and over again, to slowly build up an image for the user.  A
//  good example would be to draw a segment of a Spirograph on each call.  You get an
//  Image back, and you can then use that to show the user your progress.
//
//  Created by J. Scott Tury on 4/16/20.
//  Copyright © 2020 self. All rights reserved.
//
import Foundation
import CoreGraphics
import ImageIO

#if os(macOS)
import Cocoa
import CoreServices
import Quartz
#else // iOS, watchOS, tvOS
import UIKit
import MobileCoreServices
#endif

/**
 Class for creating multiple images based on the same context created at class creation.
 */
public class MultiImageRenderer : ImageRenderer {
    /// instance variable to specify the color you want drawn in the background when creating the new image.
    public var size : CGSize
    private var context : CGContext? = nil
    private var scale : CGFloat = 1.0
    
    /**
            Public initializer for creating a new ImageRenderer object.  If you want you can specify the default background color in this initializer.
     - parameter size: a CGSize specifying how large of an image you want to draw.
     - parameter scale: An optional initializer to specify what sort of scale you are drawing in.  If you've got a hires iPhone, or mac monitor, use the screen scaling, and the image you get back will have the right settings.
     - parameter backgroundColor: An optional background color you can specify the color in the image when you create it.
     - parameter image: An optional Image object to poulate the context with.  If specified, we will draw the image to the current context we create.
     */
    public init(_ size: CGSize, scale: CGFloat = 1.0, backgroundColor:(CGFloat, CGFloat, CGFloat, CGFloat)? = nil, image: Image? = nil ) {
        self.size = size
        self.scale = scale
        super.init(backgroundColor)

        self.context = Image.context( size: (Int(size.width), Int(size.height)), color: self.backgroundColor)
        
        // If we were asked to populate the context with an image, do that now!
        if let context = self.context, let image = image, let cgImage = image.cgImage {
            context.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: size.width, height:size.height), byTiling: false)
        }
    }

    deinit {
        self.context = nil
    }
    
    // MARK: - Creating Images
    
    /**
     Public method for creating a bitmap rasterized image.
     - parameter drawing: A simple closure you specify to draw the image inside a CGContext.
     - returns: Optional Image object.  If successful, you will have an Image you can use.
     */
    public func raster( drawing: (CGContext)->Void ) -> Image? {
        var result : Image? = nil
        
        if let context = context {
            drawing(context)
            
            if let cgImage = context.makeImage() {
                #if os(macOS)
                result = Image(cgImage: cgImage)
                #else
                result = Image(cgImage: cgImage, scale: scale, orientation: .up)
                #endif
            }
        }
        return result
    }
  
    // Need to support this as well at some point.
//    public func data( mode: ImageRenderEnum, size: CGSize, drawing: (CGContext)->Void ) -> Data? {
//    }

}
