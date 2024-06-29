import Foundation

#if canImport(UIKit)
import UIKit
#endif

public enum ResponseType {
    case image
    case images(count: Int)
    case contentAsText(name: String)
    case contentAsInt(name: String)
    case contentAsJson
}

public class RequestHandler {

    public init() {}

    public func GET(url: URL, type: ResponseType, completion: @escaping (Result<Any, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }

            switch type {
            case .image:
                #if canImport(UIKit)
                if let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    completion(.failure(NSError(domain: "Failed to create image", code: -1, userInfo: nil)))
                }
                #else
                completion(.failure(NSError(domain: "UIImage not available on this platform", code: -1, userInfo: nil)))
                #endif

            case .images(let count):
                #if canImport(UIKit)
                var images: [UIImage] = []
                for i in 0..<count {
                    if let image = UIImage(data: data) {
                        images.append(image)
                    } else {
                        completion(.failure(NSError(domain: "Failed to create image at index \(i)", code: -1, userInfo: nil)))
                        return
                    }
                }
                completion(.success(images))
                #else
                completion(.failure(NSError(domain: "UIImage not available on this platform", code: -1, userInfo: nil)))
                #endif

            case .contentAsText(let name):
                if let text = String(data: data, encoding: .utf8) {
                    completion(.success([name: text]))
                } else {
                    completion(.failure(NSError(domain: "Failed to decode text", code: -1, userInfo: nil)))
                }

            case .contentAsInt(let name):
                if let text = String(data: data, encoding: .utf8), let number = Int(text) {
                    completion(.success([name: number]))
                } else {
                    completion(.failure(NSError(domain: "Failed to decode integer", code: -1, userInfo: nil)))
                }

            case .contentAsJson:
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    completion(.success(jsonObject))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
