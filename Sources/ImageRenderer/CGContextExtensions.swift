//
//  CGContextExtensions.swift
//  Mazes
//
//  Created by Scott Tury on 9/13/18.
//  Copyright © 2018 self. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGContext {
    
    /**
     Simple method for drawing a Polygon using abn array of (x, y) points.
     
     - parameter points: array of (x,y) coordinates (Int) to draw between
     - parameter using: drawing mode to use for the Polygon.  Default is .fillStroke.
     */
    func drawPolygon( points: [(Int, Int)], using: CGPathDrawingMode = .fillStroke ) {
        
        if points.count > 0 {
            for (index, point) in points.enumerated() {
                if index == 0 {
                    move(to: CGPoint(x:point.0, y:point.1))
                }
                else {
                    addLine(to: CGPoint(x:point.0, y:point.1))
                }
            }
            addLine(to: CGPoint(x:points[0].0, y:points[0].1))
            
            drawPath(using: using)
        }
    }
   
    /**
     Simple method for drawing a Polygon using abn array of (x, y) points.
     
     - parameter points: array of (x,y) coordinates (CGFloats) to draw between
     - parameter using: drawing mode to use for the Polygon.  Default is .fillStroke.
     */
    func drawPolygon( points: [(CGFloat, CGFloat)], using: CGPathDrawingMode = .fillStroke ) {
        
        if points.count > 0 {
            for (index, point) in points.enumerated() {
                if index == 0 {
                    move(to: CGPoint(x:point.0, y:point.1))
                }
                else {
                    addLine(to: CGPoint(x:point.0, y:point.1))
                }
            }
            addLine(to: CGPoint(x:points[0].0, y:points[0].1))
            
            drawPath(using: using)
        }
    }

    
    /**
     Simple method to draw a line segment in the current context.
     
     - parameter points: array of (x,y) coordinates to draw between
     - parameter discrete: default to true to draw this piece by itself.  If you are trtying to draw a larger path, set this to false.
     */
    func drawLineSegment( points: [(Int, Int)], discrete: Bool = true ) {
        
        if points.count == 2 {
            if discrete {
                move(to: CGPoint(x:points[0].0, y:points[0].1))
            }
            addLine(to: CGPoint(x:points[1].0, y:points[1].1))
            if discrete {
                strokePath()
            }
        }
    }

    /**
     Simple method to draw a line segment in the current context.
     
     - parameter points: array of (x,y) coordinates to draw between
     - parameter discrete: default to true to draw this piece by itself.  If you are trtying to draw a larger path, set this to false.
     */
    func drawLineSegment( points: [(CGFloat, CGFloat)], discrete: Bool = true ) {
        
        if points.count == 2 {
            
            if discrete {
                move(to: CGPoint(x:points[0].0, y:points[0].1))
            }
            addLine(to: CGPoint(x:points[1].0, y:points[1].1))
            if discrete {
                strokePath()
            }
        }
    }

    /**
     Simple method to draw a line segment in the current context.
     
     - parameter points: array of (x,y) coordinates to draw between
     - parameter discrete: default to true to draw this piece by itself.  If you are trtying to draw a larger path, set this to false.
     */
    func drawLineSegment( points: [(Double, Double)], discrete: Bool = true ) {
        
        if points.count == 2 {
            if discrete {
                move(to: CGPoint(x:CGFloat(points[0].0), y:CGFloat(points[0].1)))
            }
            addLine(to: CGPoint(x:CGFloat(points[1].0), y:CGFloat(points[1].1)))
            if discrete {
                strokePath()
            }
        }
    }

}
