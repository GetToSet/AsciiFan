//#-hidden-code

import UIKit
import PlaygroundSupport
import Accelerate

import Book_Sources

PlaygroundPage.current.needsIndefiniteExecution = true

//#-end-hidden-code
/*:
# How Images Composed

## Pixels

Images are made up of *pixels*. Think of them as tiny square blocks with a single, solid color.

### 🔬Pixel Discovery

* Experiment:
    Choose an image and then tap the 🔎 icon in the bottom right corner to bring up the magnifier. Drag it around to
    examine how pixels compose a whole image.

## Red, Green & Blue

Each pixel has a color. To store a color, we have to use a *color model* to measure them first. The *RGB Color model*
is mostly used to represent colors in digital world.

In *RGB color model*, all colors are mixed from lights three main colors: *red, green and blue*.

![RGB Color Model](rgb-model.png)

This model is close to the way how screens on our devices works. For old monitors with low resolution, you can
even see lighting units in these three colors with a close-up look.

![Close-up Look of LCD Screen](lcd-screen-closeup.jpg)

## Filters

*Filters* are used as the general technique for image processing. Mysterious it seems to be, a filter is more like a
mathematical function, receiving colors per pixel, recalculates them, producing a new image as output.

### 🔨Build Your First Image Filter

* Experiment:
    * In this experiment, we'll build a simple filter which takes red, green or blue component out of the source
    image.
    * Try to read and complete the following code snippet. When you finish it, run your code and tap the *R, G
    and B* button below the image to see whether it works.
*/

func applyRGBFilter(redEnabled: Bool,
                    greenEnabled: Bool,
                    blueEnabled: Bool,
                    sourceBuffer: inout vImage_Buffer,
                    destBuffer: inout vImage_Buffer) {
    var filterMatrix: [Float] = [
        (redEnabled ? 1 : 0), 0, 0, 0,
        0, (greenEnabled ? 1 : 0), 0, 0,
        0, 0,(blueEnabled ? 1 : 0), 0,
        0, 0, 0, 1
    ]
    imageMatrixMultiply(sourceBuffer: &sourceBuffer, matrix: filterMatrix, destinationBuffer: &destBuffer)
}

func imageMatrixMultiply(sourceBuffer: inout vImage_Buffer, matrix: [Float], destinationBuffer: inout vImage_Buffer) {
    let divisor: Int32 = 0x1000
    let fDivisor = Float(divisor)
    var matrixInt16 = matrix.map {
        Int16($0 * fDivisor)
    }
    vImageMatrixMultiply_ARGB8888(&sourceBuffer,
                                  &destinationBuffer,
                                  &matrixInt16,
                                  divisor,
                                  nil,
                                  nil,
                                  vImage_Flags(kvImageNoFlags))
}

let remoteView = getRemoteViewAsProxy()
let eventListener = EventListener(proxy: remoteView) { message in
    switch message {
    case .rgbFilterRequest(let redEnabled, let greenEnabled, let blueEnabled, let image):
        guard let image = image,
              let cgImage = image.cgImage,
              let sourceFormat = vImage_CGImageFormat(cgImage: cgImage),
              var sourceBuffer = try? vImage_Buffer(cgImage: cgImage, format: sourceFormat),
              var destinationBuffer =
              try? vImage_Buffer(width: Int(sourceBuffer.width), height: Int(sourceBuffer.height), bitsPerPixel: sourceFormat.bitsPerPixel)
            else {
            break
        }
        defer {
            sourceBuffer.free()
            destinationBuffer.free()
        }
        applyRGBFilter(redEnabled: redEnabled, greenEnabled: greenEnabled, blueEnabled: blueEnabled, sourceBuffer: &sourceBuffer, destBuffer: &destinationBuffer);
        if let destImage = try? UIImage(cgImage: destinationBuffer.createCGImage(format: sourceFormat)) {
            remoteView?.send(EventMessage.imageProcessingResponse(image: destImage).playgroundValue)
        }
    default:
        break
    }
}
