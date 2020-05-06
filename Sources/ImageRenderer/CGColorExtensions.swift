//
//  CGColorExtensions.swift
//  ImageRenderer
//
//  Created by Scott Tury on 9/13/18.
//  Copyright © 2018 self. All rights reserved.
//
import Foundation
import CoreGraphics
#if os(iOS)
    import UIKit
#endif

extension CGColor {
    
    /**
    Simple static method for converting between a triplet RGB of Double values into a CGColor object.  This particular method does not create transparent CGColor values.  They're all opaque.
     
     - parameter rgbColor: A triplet of Double values specifying the RGB values of a color you want.
     */
    static public func from(_ rgbColor: (Double, Double, Double)) -> CGColor {
        return CGColor.from( (rgbColor.0, rgbColor.1, rgbColor.2, 1.0) )
    }

    /**
    Simple static method for converting between a triplet RGBA of Double values into a CGColor object.  This particular method does not create transparent CGColor values.  They're all opaque.
     
     - parameter rgbaColor: A tuple of Double values specifying the RGBA values of a CGColor you want.
     */
    static public func from(_ rgbaColor: (Double, Double, Double, Double)) -> CGColor {
        #if os(macOS)
        return CGColor(red: CGFloat(rgbaColor.0), green: CGFloat(rgbaColor.1), blue: CGFloat(rgbaColor.2), alpha: CGFloat(rgbaColor.3))
        #else
        let color = UIColor(red: CGFloat(rgbaColor.0), green: CGFloat(rgbaColor.1), blue: CGFloat(rgbaColor.2), alpha: CGFloat(rgbaColor.3))
        return color.cgColor
        #endif
    }
}
