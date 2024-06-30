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
    
    public func GET(url: String, type: ResponseType, completion: @escaping (Result<Any, Error>) -> Void) {
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
                    completion(.success(jsonObject))
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

public struct GETImage: View {
    @State private var image: UIImage?
    private let url: String
    
    public init(url: String) {
        self.url = url
    }
    
    public var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
                    .onAppear {
                        RequestHandler().GET(url: url, type: .image) { result in
                            switch result {
                            case .success(let fetchedImage):
                                DispatchQueue.main.async {
                                    self.image = fetchedImage as? UIImage
                                }
                            case .failure(let error):
                                print("Error fetching image: \(error.localizedDescription)")
                            }
                        }
                    }
            }
        }
    }
}

public struct GETText: View {
    @State private var text: String?
    private let url: String
    
    public init(url: String) {
        self.url = url
    }
    
    public var body: some View {
        Group {
            if let text = text {
                Text(text)
            } else {
                ProgressView()
                    .onAppear {
                        RequestHandler().GET(url: url, type: .text) { result in
                            switch result {
                            case .success(let fetchedText):
                                DispatchQueue.main.async {
                                    self.text = fetchedText as? String
                                }
                            case .failure(let error):
                                print("Error fetching text: \(error.localizedDescription)")
                            }
                        }
                    }
            }
        }
    }
}
#endif