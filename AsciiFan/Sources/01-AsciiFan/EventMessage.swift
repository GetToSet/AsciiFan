//
// Created by Bunny Wong on 2020/2/13.
//

import UIKit
import PlaygroundSupport

private enum EventPayloadType: String {

    case rgbFilterRequest
    case grayScaleRequest
    case imageProcessingResponse

}

private protocol EventPayload {

    var payloadType: EventPayloadType { get }

}

private struct RGBFilterRequest: EventPayload, Codable {

    var payloadType: EventPayloadType {
        return .rgbFilterRequest
    }

    let redEnabled: Bool
    let greenEnabled: Bool
    let blueEnabled: Bool

}

private struct GrayScaleFilterRequest: EventPayload, Codable {

    var payloadType: EventPayloadType {
        return .grayScaleRequest
    }

    let enabled: Bool

}

private struct ImageProcessingResponse: EventPayload, Codable {

    var payloadType: EventPayloadType {
        return .imageProcessingResponse
    }

}


public enum EventMessage {

    case rgbFilterRequest(redEnabled: Bool, greenEnabled: Bool, blueEnabled: Bool, image: UIImage?)
    case grayScaleRequest(enabled: Bool, image: UIImage?)
    case imageProcessingResponse(image: UIImage?)

    public static func from(playgroundValue: PlaygroundValue) -> EventMessage? {
        guard case .dictionary(let dict) = playgroundValue else {
            return nil
        }
        return decodeFromDictionary(dict)
    }

    public var playgroundValue: PlaygroundValue {
        get {
            return PlaygroundValue.dictionary(encodeToDictionary())
        }
    }

    private func encodeToDictionary() -> Dictionary<String, PlaygroundValue> {
        let encoder = JSONEncoder()

        var jsonData: Data?
        var imageData: Data?
        let payloadToEncode: EventPayload

        switch self {
        case .rgbFilterRequest(let red, let green, let blue, let image):
            payloadToEncode = RGBFilterRequest(redEnabled: red, greenEnabled: green, blueEnabled: blue)
            jsonData = try? encoder.encode(payloadToEncode as! RGBFilterRequest)
            imageData = image?.jpegData(compressionQuality: 1.0)
        case .grayScaleRequest(let enabled, let image):
            payloadToEncode = GrayScaleFilterRequest(enabled: enabled)
            jsonData = try? encoder.encode(payloadToEncode as! GrayScaleFilterRequest)
            imageData = image?.jpegData(compressionQuality: 1.0)
        case .imageProcessingResponse(let image):
            payloadToEncode = ImageProcessingResponse()
            imageData = image?.jpegData(compressionQuality: 1.0)
        }
        var dict = [
            "type": PlaygroundValue.string(payloadToEncode.payloadType.rawValue),
        ]
        if let jsonData = jsonData {
            dict["data"] = PlaygroundValue.data(jsonData)
        }
        if let imageData = imageData {
            dict["image"] = PlaygroundValue.data(imageData)
        }
        return dict
    }

    private static func decodeFromDictionary(_ dictionary: Dictionary<String, PlaygroundValue>) -> Self? {
        guard case .string(let typeStr) = dictionary["type"],
              let type = EventPayloadType(rawValue: typeStr) else {
            return nil
        }

        let decoder = JSONDecoder()

        var image: UIImage? = nil

        if case .data(let imageData) = dictionary["image"] {
            image = UIImage(data: imageData)
        }
        switch type {
        case .rgbFilterRequest:
            guard case .data(let data) = dictionary["data"],
                  let rgbFilterRequest = try? decoder.decode(RGBFilterRequest.self, from: data) else {
                return nil
            }
            return Self.rgbFilterRequest(
                redEnabled: rgbFilterRequest.redEnabled,
                greenEnabled: rgbFilterRequest.greenEnabled,
                blueEnabled: rgbFilterRequest.blueEnabled,
                image: image
            )
        case .grayScaleRequest:
            guard case .data(let data) = dictionary["data"],
                  let grayscaleFilterRequest = try? decoder.decode(GrayScaleFilterRequest.self, from: data) else {
                return nil
            }
            return Self.grayScaleRequest(
                enabled: grayscaleFilterRequest.enabled,
                image: image
            )
        case .imageProcessingResponse:
            return Self.imageProcessingResponse(image: image)
        }
    }

}