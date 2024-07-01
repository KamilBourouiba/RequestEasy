#if os(iOS)
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
}

public struct GETJson: View {
    @State private var jsonData: Any?
    private let url: String
    private let key: String?
    
    public init(url: String, key: String? = nil) {
        self.url = url
        self.key = key
    }
    
    public var body: some View {
        Group {
            if let jsonData = jsonData {
                if let jsonDict = jsonData as? [String: Any] {
                    Text("JSON Data: \(jsonDict.description)")
                } else if let jsonArray = jsonData as? [Any] {
                    Text("JSON Array: \(jsonArray.description)")
                } else {
                    Text("JSON Data: \(String(describing: jsonData))")
                }
            } else {
                ProgressView()
                    .onAppear {
                        RequestHandler().GET(url: url, type: .json, key: key) { result in
                            switch result {
                            case .success(let fetchedJson):
                                DispatchQueue.main.async {
                                    self.jsonData = fetchedJson
                                }
                            case .failure(let error):
                                print("Error fetching JSON: \(error.localizedDescription)")
                            }
                        }
                    }
            }
        }
    }
}
#endif