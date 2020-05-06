//
//  ImageRenderer.swift
//  ImageRenderer
//
//  A simple class to allow you o programatically create images without having to know
//  all the ins and outs of Core Graphics.
//
//  Created by J. Scott Tury on 7/22/18.
//  Copyright © 2018 self. All rights reserved.
//

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

/// Enumeration to specify the different Image types we support.
public enum ImageRenderEnum : String {
    
    /// PNG raster image
    case png
    /// PDF vector image
    case pdf
    /// JPG compressed bitmap image
    case jpg // jpeg2000, etc.
}

/**
 Class for creating images.  It allows a simple abstraction for dealing with the details of creating a Bitmap vs Vector type image.
 */
public class ImageRenderer {
    /// instance variable to specify the color you want drawn in the background when creating the new image.
    public var backgroundColor : (CGFloat, CGFloat, CGFloat, CGFloat)
    
    /**
            Public initializer for creating a new ImageRenderer object.  If you want you can specify the default background color in this initializer.
     - parameter backgroundColor: An optional background color you can specify the color in the image when you create it.
     */
    public init(_ backgroundColor:(CGFloat, CGFloat, CGFloat, CGFloat)? = nil ) {
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
        else {
            self.backgroundColor = (1.0, 1.0, 1.0, 1.0)
        }
    }
        
    // MARK: - Creating Images
    
    /**
     Public method for creating a bitmap rasterized image.
     - parameter size: CGSize specifying the width/height of the image you want to create.
     - parameter drawing: A simple closure you specify to draw the image inside a CGContext.
     - returns: Optional Image object.  If successful, you will have an Image you can use.
     */
    public func raster( size: CGSize, drawing: (CGContext)->Void ) -> Image? {
        var result : Image? = nil
        
        result = image(size: size, drawing: drawing)
        
        return result
    }
    
    //
    /**
        This method is a simple method for allowing you to load in any CoreImage known file, and create an Image object out of it.
        Depending upon the image file type, once Data object might contain multiple Images that need to be created.
        As an example, if you pass in a PDF image  as the Data object, we will return an array of Image objects.  One for each page of the PDF.
     - parameter data: The Data object to use for converting the image to a rasterized image.
     - returns: An array of Image opbjects.
     */
    public func raster( _ data: Data ) -> [Image] {
        var result = [Image]()
        
        let cgImages = loadCGImageFromData( data )
        for cgImage in cgImages {
            // convert each cgImage into a Image!
            result.append(Image(cgImage: cgImage))
        }
        
        return result
    }
    
    /**
     Simple public method for specifying a URL to load into memory as a rasterized bitmap object.
     This method should allow you to load in any CoreImage known file, and create an Image out of it.
     - parameter url: URL of where the image is located.  Note: This should be a file URL!
     - returns: Array of Image objects.
     */
    public func raster( _ url: URL ) -> [Image] {
        var result = [Image]()
        if let data = try? Data(contentsOf: url) {
            result = raster( data )
        }
        else {
            result = [Image]()
        }
        return result
    }
    
    /**
     Simple public method for specifying a URL to load into memory as a rasterized bitmap object.
     This method should allow you to load in any CoreImage known file, and create an Image out of it.
     - parameter path: String with the path of the file to open, and render.
     - returns: Array of Image objects.
     */
    public func raster( _ path: String ) -> [Image] {
        return raster( URL(fileURLWithPath: path) )
    }
    
    /**
     Simple public method for creating a Data object given a size and a closure for drawing your image.  You can use this to draw an image
     into a pdf context, and get a PDF data returned from this call.
     - parameter mode: An ImageRenderEnum value for the type of image data you want to get back from this call.
     - parameter size: A CGSize value specifying the area that you want to draw into.
     - parameter drawing: A closure where you will be given the constructed CGContext that you can draw into.
     - returns: An optional Data object.  If we could create the requested Data, you'll get a Data object, if not, you will not have an object you can work with.
     */
    public func data( mode: ImageRenderEnum, size: CGSize, drawing: (CGContext)->Void ) -> Data? {
        var result : Data? = nil
        
        switch mode {
        case .png:
            if let image = raster(size: size, drawing: drawing) {
                // Now convert this image into a data blob for the type needed....
                #if os(macOS)
                result = macOSImageData( image, storageType: .png )
                #else // os(iOS) || os(tvOS) || os(watchOS)
                result = image.pngData()
                #endif
            }
        case .jpg:
            if let image = raster(size: size, drawing: drawing) {
                // Now convert this image into a data blob for the type needed....
                #if os(macOS)
                result = macOSImageData( image, storageType: .jpeg )
                #else // os(iOS) || os(tvOS) || os(watchOS)
                result = image.jpegData(compressionQuality: 0.8)
                #endif
            }
            
        case .pdf:
            result = pdf(size: size, drawing: drawing)
        }
        
        return result
    }

    // MARK: - Helper methods
    
    /**
    Simple generic method for generating a bitmap Image, filled in with a particular background color, and rendered with the closure provided.
     - parameter size: A tuple (Int, Int) of the width, height in pixels you want the image render to be.
     - parameter drawing: A closure provided by the caller for drawing inside of the CGContext we will create.
     - returns: An optional Image object.  If we could create the bitmap image, you'll get an Image back.
     */
    private func image( size: (Int, Int), drawing: (CGContext)->Void ) -> Image? {
        
        var result : Image?
        
        if let context = Image.context( size: size, color:backgroundColor) {
            drawing(context)
            
            if let cgImage = context.makeImage() {
                result = Image(cgImage: cgImage)
            }
        }
        
        return result
    }
    
    /**
    Simple convienience method for generating a bitmap Image, filled in with a particular background color, and rendered with the closure provided.
     - parameter size: A CGSize object specifying the width and height in pixels you want the image render to be.
     - parameter drawing: A closure provided by the caller for drawing inside of the CGContext we will create.
     - returns: An optional Image object.  If we could create the bitmap image, you'll get an Image back.
     */
    private func image( size: CGSize, drawing: (CGContext)->Void ) -> Image? {
        return image(size: (Int(size.width), Int(size.height)), drawing: drawing)
    }
    
    /**
    Simple method for generating a pdf data blob, filled in with a particular background color, and rendered with the closure provided.
     - parameter size: A tuple (Int, Int) specifying the width and height you want the image to be.
     - parameter drawing: A closure provided by the caller for drawing inside of the CGContext we will create.
     - returns: An optional Data object.  If we could create the pdf, you'll get a Data object back.
     */
    private func pdf( size: (Int, Int), drawing: (CGContext)->Void ) -> Data? {
        
        var result : Data? = nil
        
        var mediaBox = CGRect(x: 0, y: 0, width: size.0, height: size.1)
        
        // Example showing how to create a CGDataConsumer to grab the data, then allow me to write out that data myself.
        if let pdfData = CFDataCreateMutable(nil, 0) {
            if let consumer = CGDataConsumer(data: pdfData) {
                if let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) {
                    context.beginPDFPage(nil)
                    
//                    if backgroundColor.3 == 0.0 {
//                        // If the background color is completely transparent - clear everything from the PDF!
//                        context.clear(mediaBox)
//                    }
//                    else
//                    {
                        // Draw the background color...
                        context.setFillColor(red: backgroundColor.0, green: backgroundColor.1, blue: backgroundColor.2, alpha: backgroundColor.3)
                        context.fill(CGRect(x: 0, y: 0, width: size.0, height: size.1))
//                    }
                    // Draw the image
                    drawing(context)
                    context.endPDFPage()
                    context.closePDF()
                    
                    let size = CFDataGetLength(pdfData)
                    if let bytePtr = CFDataGetBytePtr(pdfData) {
                        result = Data(bytes: bytePtr, count: size)
//                        if let result = result {
//                            print( result )
//                        }
                    }
                    //print("Created PDF using a CFMutableData.  Size is \(size)")
                }
                else {
                    print( "Failed to create a context")
                }
            }
            else {
                print("Failed to create a consumer")
            }
        }
        
        return result
    }
    
    /**
    Simple convienience method for generating a pdf data blob, filled in with a particular background color, and rendered with the closure provided.
     - parameter size: A CGSize object specifying the width and height you want the pdf bounds to be.
     - parameter drawing: A closure provided by the caller for drawing inside of the CGContext we will create.
     - returns: An optional Data object.  If we could create the pdf, you'll get a Data object back.
     */
    private func pdf( size: CGSize, drawing: (CGContext)->Void ) -> Data? {
        return pdf(size: (Int(size.width), Int(size.height)), drawing: drawing)
    }

// NOTE:  This commented out method is an older function I'd used at an earlier time.
//    #if os(macOS) || os(iOS)
//    public func pdf( size: CGSize, drawing: (CGContext)->Void ) -> PDFDocument? {
//        var result : PDFDocument? = nil
//        if let data = data( mode: .pdf, size: size, drawing: drawing ) {
//            result = PDFDocument(data: data)
//        }
//        return result
//    }
//    #endif
    
    // MARK: - Internal Private Utility Methods
    
    #if os(macOS)
    /**
    macOS only private function to pull out the bitmap data in a particular format.
     - parameter image: An Image object to get the data in a particular file format.
     - parameter storageType: An NSBitmapImageRep.FileType value specifying what type of file data the caller wants.
     - returns: An optional Data object.  If we could create the requested Data, you'll get a Data object, if not, you will not have an object you can work with.
     */
    private func macOSImageData(_ image: Image, storageType: NSBitmapImageRep.FileType ) -> Data? {
        var result : Data? = nil
        if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            let bitmap = NSBitmapImageRep(cgImage: cgImage)
            result = bitmap.representation(using: storageType, properties: [:])
        }
        return result
    }
    #endif
    
    
    /**
    Private method for creating an array of CGImage object from a Data object.  If you have a multi page PDF for example, you'll get
    a CGImage for each page in the PDF data.
     - parameter data: The Data to rasterize into a CGImage.
     - returns: An array of CGImage objects.
     */
    private func loadCGImageFromData( _ data: Data) -> [CGImage] {
        var result: [CGImage] = [CGImage]()
        
        var imageSource : CGImageSource?
        
        // Setup the options if you want them.  The options here are for caching the image
        // in a decoded form.and for using floating-point values if the image format supports them.
        let options = [ kCGImageSourceShouldCache:kCFBooleanTrue as CFTypeRef,
                        kCGImageSourceShouldAllowFloat: kCFBooleanTrue as CFTypeRef ]
        
        // Create an image source from the URL.
        imageSource = CGImageSourceCreateWithData(data as CFData, options as CFDictionary)
        
        // Make sure the image source exists before continuing
        if let imageSource = imageSource {
            
            if let type = CGImageSourceGetType(imageSource) as String? {
                
                //print( "imageSource type is \(type)")
                // If it's a PDF, we need to load in the file differently.
                if type == kUTTypePDF as String {
                    // Need to do something different for PDF data...
                    if let dataProvider = CGDataProvider(data: data as CFData) {
                        if let pdfReference = CGPDFDocument(dataProvider) {
                            let numberOfPages = pdfReference.numberOfPages
                            var mediaBox: CGRect
                            for index in 1...numberOfPages {
                                guard let page = pdfReference.page(at:index) else {
                                    NSLog("Error occurred in creating page")
                                    return result
                                }
                                mediaBox = page.getBoxRect(.mediaBox)
                                // Create a CGImage or Context, and draw the PDF into it?
                                
                                // Need to create a CGContext, then draw the PDFPage into the context.
                                if let context = Image.context(size: (Int(mediaBox.width), Int(mediaBox.height)), color: (1.0, 1.0, 1.0, 0.0)) {
                                    context.drawPDFPage( page )
                                    if let image = context.makeImage() {
                                        result.append( image )
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    let totalItems = CGImageSourceGetCount( imageSource )
//                    print( "\(totalItems) in the image source...")
                    for index in 0..<totalItems {
                        // Create an image from the first item in the image source.
//                        print("Attempting to create an image at index \(index)" )
                        let image = CGImageSourceCreateImageAtIndex(imageSource, index, nil)
                        // Make sure the image exists before continuing
                        if let image = image {
                            result.append( image )
                        }
//                        else {
//                            print("Image not created from image source.")
//                        }
                    }
                }
            }
        }
        else {
            print( "Image source is NULL.")
        }
        
        return result
    }
    
}
