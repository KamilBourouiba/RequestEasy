import Foundation

public enum RequestType {
    case image
    case images(count: Int)
    case contentAsText(name: String)
    case contentAsInt(name: String)
    case contentAsJson
}
