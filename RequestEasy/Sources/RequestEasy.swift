// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public func GET(url: URL, type: RequestType, completion: @escaping (Result<Any, Error>) -> Void) {
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
                completion(.failure(NSError(domain: "Invalid image data", code: -1, userInfo: nil)))
            }
            
        case .images(let count):
            // Assuming the response data contains multiple images
            var images = [UIImage]()
            // Process the data to extract images (placeholder logic)
            for _ in 0..<count {
                if let image = UIImage(data: data) {
                    images.append(image)
                }
            }
            completion(.success(images))
            
        case .contentAsText(let name):
            if let text = String(data: data, encoding: .utf8) {
                completion(.success([name: text]))
            } else {
                completion(.failure(NSError(domain: "Invalid text data", code: -1, userInfo: nil)))
            }
            
        case .contentAsInt(let name):
            if let text = String(data: data, encoding: .utf8), let number = Int(text) {
                completion(.success([name: number]))
            } else {
                completion(.failure(NSError(domain: "Invalid integer data", code: -1, userInfo: nil)))
            }
            
        case .contentAsJson:
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                completion(.success(json))
            } catch {
                completion(.failure(error))
            }
        }
    }
    task.resume()
}
