#if os(iOS)
import UIKit
import Foundation

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
}

public struct EasyRequest {
    private static let handler = RequestHandler()
    
    public static func image(_ url: String) -> RemoteResourceView<UIImage> {
        return RemoteResourceView<UIImage>(url: url) { completion in
            handler.GET_image(url: url, completion: completion)
        }
    }
    
    public static func text(_ url: String) -> RemoteResourceView<String> {
        return RemoteResourceView<String>(url: url) { completion in
            handler.GET_text(url: url, completion: completion)
        }
    }
}

public struct RemoteResourceView<T>: View {
    @State private var result: Result<T, Error>?
    private let url: String
    private let loadData: (@escaping (Result<T, Error>) -> Void) -> Void
    
    public init(url: String, loadData: @escaping (@escaping (Result<T, Error>) -> Void) -> Void) {
        self.url = url
        self.loadData = loadData
    }
    
    public var body: some View {
        Group {
            if let result = result {
                switch result {
                case .success(let value):
                    if let image = value as? UIImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else if let text = value as? String {
                        Text(text)
                    }
                case .failure(let error):
                    Text("Failed to load: \(error.localizedDescription)")
                }
            } else {
                ProgressView()
                    .onAppear {
                        loadData { result in
                            DispatchQueue.main.async {
                                self.result = result
                            }
                        }
                    }
            }
        }
    }
}
#endif
