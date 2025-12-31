//
//  CloudinaryService.swift
//  Khairk
//
//  Created by FM on 18/12/2025.
//

//
//  CloudinaryService.swift
//  Khairk
//
//  Created by vkc5 on 27/11/2025.
//

import Foundation
import UIKit

final class CloudinaryService {

    static let shared = CloudinaryService()
    private init() {}

    // TODO: replace with your real values
    private let cloudName = "dnadpx7kl"
    private let uploadPreset = "khairk_unsigned"

    func uploadImage(_ image: UIImage,
                     completion: @escaping (Result<String, Error>) -> Void) {

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            let err = NSError(domain: "CloudinaryService",
                              code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG"])
            completion(.failure(err))
            return
        }

        let urlString = "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload"
        guard let url = URL(string: urlString) else {
            let err = NSError(domain: "CloudinaryService",
                              code: -2,
                              userInfo: [NSLocalizedDescriptionKey: "Invalid Cloudinary URL"])
            completion(.failure(err))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)",
                         forHTTPHeaderField: "Content-Type")

        var body = Data()

        // upload_preset
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)

        // file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let url = json["secure_url"] as? String
            else {
                let err = NSError(domain: "CloudinaryService",
                                  code: -3,
                                  userInfo: [NSLocalizedDescriptionKey: "Could not parse Cloudinary response"])
                completion(.failure(err))
                return
            }

            completion(.success(url))
        }

        task.resume()
    }
}

