//#-hidden-code
//
// Copyright © 2020 Bunny Wong
// Created on 2019/12/18.
//

import UIKit
import PlaygroundSupport

import BookCore

PlaygroundPage.current.needsIndefiniteExecution = true

//#-end-hidden-code
/*:
# The “ASCIIfication” Magic

## Character Map

ASCII art can be generated by substituting pixels in different brightness levels with ASCII characters. To achieve
desired result, the font must be **monospaced**, which has fixed width for all characters.

Here is a **character map** built with font “Fira Code”, by arranging characters to fit a gradient from white to black.

（图）

## Resampling

Since characters are much wider than pixels, images have to be shrunken the before mapping to ASCII characters.
Technically, scaling down an image is known as **downsampling** or broadly speaking, **resampling**. When scaling an
image, different *scaling algorithms* can applied. Most of them takes nearby pixels into consideration to produce a
smooth result.

### 🔬Scaling & Resampling

* Experiment:
    * Following code snippet shrinks an image according to the aspect ratio of characters.
    * Run the code and tap the *shrink* button to see the effect. Try tapping the button at the lower right corner,
    notice how pixels are resampled when scaling a small image up.
*/
//#-code-completion(everything, hide)
//#-code-completion(literal, show, float, double, integer)
//#-editable-code

let charactersPerRow = 80

func calculateCharactersRows(charactersPerRow: Int) -> Int {
    // The aspect ratio of characters in the font “Fira Code”
    let ratio = 1.70667
    return Int((Double(charactersPerRow) / ratio).rounded())
}

func scaleImageForAsciification(rawImage: RawImage) -> RawImage? {
    // Scale the image to match the dimension of resulting ASCII art.
    let scaledWidth = charactersPerRow
    let scaledHeight = calculateCharactersRows(charactersPerRow: charactersPerRow)
    return rawImage.scaled(width: scaledWidth, height: scaledHeight)
}

//#-end-editable-code
/*:
## Final Magic

### 🔨Mapping Pixels with Characters

* Experiment:
    * In this experiment, we'll build another filter to turn an image into grayscaled version, with consideration.
    * Try to read and complete the following code snippet. When you finish, run your code and tap the *Switch to
    Grayscale* button below the image to see whether it works.
*/
//#-editable-code

func applyAsciification(rawImage: RawImage) {


}

//#-end-editable-code
/*:
* Note:
    In this code snippet, we transform the image by multiplying it with a custom filter matrix. If you're not familiar
    with limier algebra, the following figure will explain how this transform matrix works.
*/
//#-hidden-code
let remoteView = remoteViewAsLiveViewProxy()
let eventListener = EventListener(proxy: remoteView) { message in
    switch message {
    case .shrinkingRequest(let image):
        guard let rawImage = RawImage(uiImage: image) else {
            return
        }
        let destinationBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        if let destRawImage = scaleImageForAsciification(rawImage: rawImage),
           let destCGImage = destRawImage.cgImage(bitmapInfo: destinationBitmapInfo) {
            remoteView?.send(EventMessage.imageProcessingResponse(image: UIImage(cgImage: destCGImage)).playgroundValue)
        }
    case .asciificationRequest(let image):
        guard let rawImage = RawImage(uiImage: image) else {
            return
        }
        applyAsciification(rawImage: rawImage);
        let destinationBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        if let destCGImage = rawImage.cgImage(bitmapInfo: destinationBitmapInfo) {
            remoteView?.send(EventMessage.imageProcessingResponse(image: UIImage(cgImage: destCGImage)).playgroundValue)
        }
    default:
        break
    }
}
//#-end-hidden-code
