# ImageRenderer
By Scott Tury

This is a simple library for wrapping up the logic needed for rendering graphics programatically into an `Image`.  An `Image`, as discusses below, will be either an `NSImage` on `macOS`, or a `UIImage` on `iOS`/`tvOS`/`watchOS`.  So the end user doesn't need to know all the low level `CGGraphcs` details in order to create an image. 

## ImageRenderer

Class for creating images.  It allows a simple abstraction for dealing with the details of creating a Bitmap vs Vector type image.

`public func raster( size: CGSize, drawing: (CGContext)->Void ) -> Image?`

This is the main method you would use.  You tell the `ImageRenderer` how large you want the bitmap to be, and it will set everything up for you, then call your closure, so you can draw your image into the context.  After your closure has finished executing, it will convert that into an `Image` that you can then show the user.

`public func raster( _ data: Data ) -> [Image]`
`public func raster( _ url: URL ) -> [Image]`
`public func raster( _ path: String ) -> [Image]`

You can use these methods for loading a png, pdf, or jpg file directly to a `Image`, that you can display to the user.

`public func data( mode: ImageRenderEnum, size: CGSize, drawing: (CGContext)->Void ) -> Data?`

Public method for creating a `Data` object given a size and a closure for drawing your image.  You can use this to draw an image into a pdf context, and get a PDF data blob returned from this call.

## MultiImageRenderer
Subclass of `ImageRenderer`.

This class is used for creating multiple images based on the same image context, which is created once at class creation.  If you need a new context, create a new instance of the class.

An example of using this like this would be to create a bitmap context, and you need to draw different line segments, but you want to be able to supply different `Image` objects to the UI for display to the user.  In this case, it's better to just draw to the bitmap context you already have, instead of having to redraw the entrire image you had before, plus a little bit more.

`public func raster( drawing: (CGContext)->Void ) -> Image?`

## Image

On `macOS`, `Image` is a typealias for `NSImage`.
On `iOS`/`tvOS`/`watchOS` `Image` is a typealias for `UIImage`.

This llows us to treat either concrete type as one simple `Image` class.  We also provide a couple of methods that are not available by defaut, in order to allow us to write code once, for all platforms.

## FileWriter

Class for creating writing data out to a specific directory. It tries to allow you to set some default folder you want to write into.  It then uses that to generate all the URL's/file paths for data you want to save to that folder.




## CGContextExtensions

`func drawPolygon( points: [(Int, Int)], using: CGPathDrawingMode = .fillStroke )`
`func drawPolygon( points: [(CGFloat, CGFloat)], using: CGPathDrawingMode = .fillStroke )`

Simple method for drawing a Polygon using abn array of (x, y) points.

`func drawLineSegment( points: [(Int, Int)], discrete: Bool = true )` 
`func drawLineSegment( points: [(CGFloat, CGFloat)], discrete: Bool = true )`
`func drawLineSegment( points: [(Double, Double)], discrete: Bool = true )`

 Simple method to draw a line segment in the current context.
 
## CGColorExtensions

Provides two static method variants to create a `CGColor` object from a Tuple of either three or four `Double` values (RGB, RGBA).  

`static public func from(_ rgbColor: (Double, Double, Double)) -> CGColor`
`static public func from(_ rgbaColor: (Double, Double, Double, Double)) -> CGColor`

