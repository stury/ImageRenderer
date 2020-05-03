//
//  ColorCalculator.swift
//  SpirographView
//
//  Created by Scott Tury on 4/27/20.
//  Copyright © 2020 Scott Tury. All rights reserved.
//
import CoreGraphics

class ColorCalculator {
    /// Colors that the pen can cycle through.
    let colors : [Color]
    /// Max Iterations per color.
    let maxIterationsPerColor : Int
    
    fileprivate init(colors: [Color], maxIterationsPerColor: Int) {
        self.colors = colors
        self.maxIterationsPerColor = maxIterationsPerColor
    }
    
    convenience init(colors: [Color], maxIterations: Int) {
        self.init(colors: colors, maxIterationsPerColor: maxIterations/colors.count)
    }
    
    // This function translates a given x value which is in the source range, into the destination range requested by the user.  It should be a purely linear calculation from one range to another.
    func translate(x: Double, in source: ClosedRange<Double>, to destination: ClosedRange<Double>) -> Double {
        return (((destination.upperBound-destination.lowerBound)*(x - source.lowerBound)) / (source.upperBound - source.lowerBound)) + destination.lowerBound
    }

    func invert( _ x: Double ) -> Double {
        return 1.0-x
    }
    
    // This method is looking for a range of numbers from -6 to 6.
    // Use the translate() method above to make sure your input data matches.
    // This method gives you a sigmoid output between -6...6.
    func logisticFunction(_ x:Double) -> Double {
        var result : Double
        // Need to map 0.0-1.0 to -5..5
        //let scale = mapRange(x: x)
        //let scale = translate(x: x, in:0.0...1.0, to:-6...6)
        result = Double(1.0)/((Double(1)+pow(Double(2.7182818284), Double(-x))))
        return result
    }

    func colorIndex( for index: Int) -> Int {
        return min(Int(index/maxIterationsPerColor), colors.count-1)
    }
    
    func color(for index: Int) -> Color {
        //print( "colorIndex:", colorIndex(for: index), "index:", index )
        return colors[colorIndex(for: index)]
    }
    
    func colorString(red: CGFloat, green: CGFloat, blue: CGFloat) -> String {
        return "(red: \(red), green: \(green), blue: \(blue))"
    }
}

class ColorLinearCalculator : ColorCalculator {
//    override init(colors: [UIColor], maxIterationsPerColor: Int) {
//        // A NOTE:  We override this init method, because in the case where we are transitioning from one color
//        // to another, the default calculation of maxIterationsPerColor passed in, will be wrong.  We actually need
//        // to modify it so that we can evenly distribute the colors across the entire cycle of iterations.  So
//        // the number of trtansitions isn't 2 for 2 colors, it's 1 transition between two colors.  This rule
//        // holds up for anything higher up the chain as well.  If you give me a set of 7 colors, there are 6 transitions.
//        // so we override the init to reset the calculations correctly to what we need.  The original ColorCalculator
//        // class is doing the right thing when you evenly distribute 7 colors over a set of iterations, you should see 7 colors.
//        // But for these transitions, I want to see colors.count-1 transitions.  That way all the transitions are evently distributed.
//        super.init(colors: colors, maxIterationsPerColor: (maxIterationsPerColor*colors.count)/(colors.count-1))
//    }
//
    convenience init(colors: [Color], maxIterations: Int) {
        let maxIterationsPerColor : Int
        if colors.count > 1 {
            maxIterationsPerColor = maxIterations/(colors.count-1)
        }
        else {
            maxIterationsPerColor = 1
        }
        
        self.init(colors: colors, maxIterationsPerColor: maxIterationsPerColor)
    }

    override func color(for index: Int) -> Color {
        let baseColorIndex = colorIndex(for: index)
        let sourceColor = colors[baseColorIndex]
        let destinationColor = colors[min(baseColorIndex+1, colors.count-1)]
        
        var sourceRed : CGFloat = 0.0
        var sourceGreen : CGFloat = 0.0
        var sourceBlue : CGFloat = 0.0
        var sourceAlpha : CGFloat = 0.0
        
        sourceColor.getRed(&sourceRed, green: &sourceGreen, blue: &sourceBlue, alpha: &sourceAlpha)

        var destRed : CGFloat = 0.0
        var destGreen : CGFloat = 0.0
        var destBlue : CGFloat = 0.0
        var destAlpha : CGFloat = 0.0
        
        destinationColor.getRed(&destRed, green: &destGreen, blue: &destBlue, alpha: &destAlpha)

        let percentage = translate(x: Double(index%maxIterationsPerColor), in: 0...Double(maxIterationsPerColor), to: 0.0...1.0)
        
        let calculatedRed : CGFloat = CGFloat(Double(sourceRed)*invert(percentage)+Double(destRed)*percentage)
        let calculatedGreen : CGFloat = CGFloat(Double(sourceGreen)*invert(percentage)+Double(destGreen)*percentage)
        let calculatedBlue : CGFloat = CGFloat(Double(sourceBlue)*invert(percentage)+Double(destBlue)*percentage)
        let calculatedAlpha : CGFloat = CGFloat(Double(sourceAlpha)*invert(percentage)+Double(destAlpha)*percentage)
        //print( "value: \(percentage):", "source:", colorString(red: sourceRed, green: sourceGreen, blue: sourceBlue), "dest:", colorString(red: destRed, green: destGreen, blue: destBlue), "calculated:", colorString(red: calculatedRed, green: calculatedGreen, blue: calculatedBlue) )
        return Color(red: calculatedRed, green: calculatedGreen, blue: calculatedBlue, alpha: calculatedAlpha)
    }
}

class ColorSigmoidCalculator : ColorCalculator {
//    override init(colors: [UIColor], maxIterationsPerColor: Int) {
//        // A NOTE:  We override this init method, because in the case where we are transitioning from one color
//        // to another, the default calculation of maxIterationsPerColor passed in, will be wrong.  We actually need
//        // to modify it so that we can evenly distribute the colors across the entire cycle of iterations.  So
//        // the number of trtansitions isn't 2 for 2 colors, it's 1 transition between two colors.  This rule
//        // holds up for anything higher up the chain as well.  If you give me a set of 7 colors, there are 6 transitions.
//        // so we override the init to reset the calculations correctly to what we need.  The original ColorCalculator
//        // class is doing the right thing when you evenly distribute 7 colors over a set of iterations, you should see 7 colors.
//        // But for these transitions, I want to see colors.count-1 transitions.  That way all the transitions are evently distributed.
//        super.init(colors: colors, maxIterationsPerColor: (maxIterationsPerColor*colors.count)/(colors.count-1))
//    }
    convenience init(colors: [Color], maxIterations: Int) {
        let maxIterationsPerColor : Int
        if colors.count > 1 {
            maxIterationsPerColor = maxIterations/(colors.count-1)
        }
        else {
            maxIterationsPerColor = 1
        }
        
        self.init(colors: colors, maxIterationsPerColor: maxIterationsPerColor)
    }

    override func color(for index: Int) -> Color {
        let baseColorIndex = colorIndex(for: index)
        let sourceColor = colors[baseColorIndex]
        let destinationColor = colors[min(baseColorIndex+1, colors.count-1)]
        
        var sourceRed : CGFloat = 0.0
        var sourceGreen : CGFloat = 0.0
        var sourceBlue : CGFloat = 0.0
        var sourceAlpha : CGFloat = 0.0
        
        sourceColor.getRed(&sourceRed, green: &sourceGreen, blue: &sourceBlue, alpha: &sourceAlpha)

        var destRed : CGFloat = 0.0
        var destGreen : CGFloat = 0.0
        var destBlue : CGFloat = 0.0
        var destAlpha : CGFloat = 0.0
        
        destinationColor.getRed(&destRed, green: &destGreen, blue: &destBlue, alpha: &destAlpha)

        let percentage = logisticFunction(translate(x: Double(index%maxIterationsPerColor), in: 0...Double(maxIterationsPerColor), to: -6.0...6.0))
            
        let calculatedRed : CGFloat = CGFloat(Double(sourceRed)*invert(percentage)+Double(destRed)*percentage)
        let calculatedGreen : CGFloat = CGFloat(Double(sourceGreen)*invert(percentage)+Double(destGreen)*percentage)
        let calculatedBlue : CGFloat = CGFloat(Double(sourceBlue)*invert(percentage)+Double(destBlue)*percentage)
        let calculatedAlpha : CGFloat = CGFloat(Double(sourceAlpha)*invert(percentage)+Double(destAlpha)*percentage)

        return Color(red: calculatedRed, green: calculatedGreen, blue: calculatedBlue, alpha: calculatedAlpha)
    }
}
