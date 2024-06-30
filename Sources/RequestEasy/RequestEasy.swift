import Foundation
import UIKit

public enum ResponseType {
    case image
    case text
}

public class RequestHandler {
    
    public init() {}
    
    public func GET() -> RequestGetter {
        return RequestGetter()
    }
    
    public class RequestGetter {
        private var url: URL?
        private var type: ResponseType = .text // Default type
        
        public func image(url: String) -> RequestGetter {
            self.url = URL(string: url)
            self.type = .image
            return self
        }
        
        public func text(url: String) -> RequestGetter {
            self.url = URL(string: url)
            self.type = .text
            return self
        }
        
        public func onCompletion(_ completion: @escaping (Result<Any, Error>) -> Void) {
            guard let url = self.url else {
                completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                    return
                }
                
                switch self.type {
                case .image:
                    if let image = UIImage(data: data) {
                        completion(.success(image))
                    } else {
                        completion(.failure(NSError(domain: "Failed to create image", code: -1, userInfo: nil)))
                    }
                    
                case .text:
                    if let text = String(data: data, encoding: .utf8) {
                        completion(.success(text))
                    } else {
                        completion(.failure(NSError(domain: "Failed to decode text", code: -1, userInfo: nil)))
                    }
                }
            }.resume()
        }
    }
}
