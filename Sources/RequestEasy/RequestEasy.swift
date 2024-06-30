#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif
#if os(iOS)
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
    
    public func GET_image(url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
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
            
            #if canImport(UIKit)
            if let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(NSError(domain: "Failed to decode image", code: -1, userInfo: nil)))
            }
            #else
            completion(.failure(NSError(domain: "UIImage not available on this platform", code: -1, userInfo: nil)))
            #endif
        }
        
        task.resume()
    }
    
    public func GET_text(url: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let text = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "Failed to decode text", code: -1, userInfo: nil)))
                return
            }
            
            completion(.success(text))
        }
        
        task.resume()
    }
    
    // Additional methods for json and integer types if needed...
}
#endif
