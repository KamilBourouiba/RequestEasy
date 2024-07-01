import UIKit
import Foundation
import SwiftUI

public enum ResponseType {
    case image
    case text
    case json
    case integer
}

public class RequestHandler {
    public init() {}

    public func GET(url: String, type: ResponseType, key: String? = nil, completion: @escaping (Result<Any, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

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
                    completion(.failure(NSError(domain: "Failed to decode image", code: -1, userInfo: nil)))
                }
                #else
                completion(.failure(NSError(domain: "UIImage not available on this platform", code: -1, userInfo: nil)))
                #endif

            case .text:
                if let text = String(data: data, encoding: .utf8) {
                    completion(.success(text))
                } else {
                    completion(.failure(NSError(domain: "Failed to decode text", code: -1, userInfo: nil)))
                }

            case .json:
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    if let key = key, let jsonDict = jsonObject as? [String: Any], let value = jsonDict[key] {
                        completion(.success(value))
                    } else {
                        completion(.success(jsonObject))
                    }
                } catch {
                    completion(.failure(error))
                }

            case .integer:
                if let intText = String(data: data, encoding: .utf8), let integer = Int(intText) {
                    completion(.success(integer))
                } else {
                    completion(.failure(NSError(domain: "Failed to decode integer", code: -1, userInfo: nil)))
                }
            }
        }

        task.resume()
    }

    public func GETSync(url: String, type: ResponseType, key: String? = nil) -> Result<Any, Error> {
        var result: Result<Any, Error>?
        let semaphore = DispatchSemaphore(value: 0)

        GET(url: url, type: type, key: key) { res in
            result = res
            semaphore.signal()
        }

        _ = semaphore.wait(timeout: .distantFuture)
        return result!
    }
}

public func GETJson(url: String, key: String? = nil) -> String {
    let result = RequestHandler().GETSync(url: url, type: .json, key: key)

    switch result {
    case .success(let value):
        return "\(value)"
    case .failure(let error):
        print("Error fetching JSON: \(error.localizedDescription)")
        return "Error fetching data"
    }
}