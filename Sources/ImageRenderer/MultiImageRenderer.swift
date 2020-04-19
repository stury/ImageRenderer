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
    
    /**
            Public initializer for creating a new ImageRenderer object.  If you want you can specify the default background color in this initializer.
     - parameter backgroundColor: An optional background color you can specify the color in the image when you create it.
     */
    public init(_ size: CGSize, backgroundColor:(CGFloat, CGFloat, CGFloat, CGFloat)? = nil ) {
        self.size = size
        super.init(backgroundColor)

        self.context = Image.context( size: (Int(size.width), Int(size.height)), color: self.backgroundColor)
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
                result = Image(cgImage: cgImage)
            }
        }
        return result
    }
  
    // Need to support this as well at some point.
//    public func data( mode: ImageRenderEnum, size: CGSize, drawing: (CGContext)->Void ) -> Data? {
//    }

}
