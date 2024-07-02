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
                if let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    completion(.failure(NSError(domain: "Failed to decode image", code: -1, userInfo: nil)))
                }

            case .text:
                if let text = String(data: data, encoding: .utf8) {
                    completion(.success(text))
                } else {
                    completion(.failure(NSError(domain: "Failed to decode text", code: -1, userInfo: nil)))
                }

            case .json:
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    if let key = key {
                        let value = self.getValueForKeyPath(jsonObject, keyPath: key)
                        completion(.success(value ?? "Key not found"))
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

    private func getValueForKeyPath(_ json: Any, keyPath: String) -> Any? {
        let keys = keyPath.split(separator: "/").map { String($0) }
        var current: Any = json

        for key in keys {
            if let dictionary = current as? [String: Any], let value = dictionary[key] {
                current = value
            } else {
                return nil
            }
        }

        return current
    }
}

struct ImageLoader: View {
    let url: URL
    @State private var image: UIImage? = nil

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }

    private func loadImage() {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = uiImage
                }
            }
        }.resume()
    }
}

public func GETJson(url: String, key: String? = nil) -> AnyView {
    let result = RequestHandler().GETSync(url: url, type: .json, key: key)

    switch result {
    case .success(let value):
        if let urlString = value as? String, let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            return AnyView(ImageLoader(url: url))
        } else {
            return AnyView(Text("\(value)").padding())
        }
    case .failure(let error):
        return AnyView(Text("Error fetching data: \(error.localizedDescription)").padding())
    }
}
