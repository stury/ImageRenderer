//
//  Color.swift
//  ImageRenderer
//
//  Created by Scott Tury on 5/3/20.
//  Copyright © 2020 Scott Tury. All rights reserved.
//

#if os(macOS)
    import Cocoa
    public typealias Color = NSColor
#else // os(iOS) watchOS and tvOS
    import UIKit
    public typealias Color = UIColor
#endif

//{
//    "name": "Color Spectrum",
//    "colors":["#000000", "#FF0000", "#FFFF00", "#FF00FF", "#00FF00", "#FF00FF", "#00FFFF", "#0000FF"]
//},


/// Simple public extension to NSColor/UIColor to provide simple converters from hex color strings to color objects, and back.
public extension Color {
    /// Simple initializer that takes a hexstring, and converts it into a NSColor/UIColor object.
    /// - Parameter hexString: A String object starting with #, and consisting of 6 or 8 hexadecimal characters following.  This would correspond to #RRGGBB or #RRGGBBAA colors.
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
            else if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    b = CGFloat((hexNumber & 0x000000ff) >> 0) / 255
                    a = 1.0
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
    
    /// Simple method for converting a NSColor/UIColor object into a hexstring.
    /// - Returns: String?  If nil was returned, then the color could not be converted to RGB.
    /// Otherwise you'll have a hexcolor string specifying the RGB and possibly A components.
    public func hexColor() -> String? {
        var result : String? = nil
        
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue : CGFloat = 0.0
        var alpha : CGFloat = 0.0
        
        #if os(macOS)
        if let color = usingColorSpace(.deviceRGB) {
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            print( red*255.0 )
            print( Int(red*255.0) )
            if alpha == 1.0 {
                result = String(format: "#%2.2x%2.2x%2.2x", Int(red*255.0), Int(green*255.0), Int(blue*255.0))
            }
            else {
                result = String(format: "#%2.2x%2.2x%2.2x%2.2x", Int(red*255.0), Int(green*255.0), Int(blue*255.0), Int(alpha*255.0))
            }
        }
        #else
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            if alpha == 1.0 {
                result = String(format: "#%2.2x%2.2x%2.2x", Int(red*255.0), Int(green*255.0), Int(blue*255.0))
            }
            else {
                result = String(format: "#%2.2x%2.2x%2.2x%2.2x", Int(red*255.0), Int(green*255.0), Int(blue*255.0), Int(alpha*255.0))
            }
        }
        #endif
        
        return result
    }

}
