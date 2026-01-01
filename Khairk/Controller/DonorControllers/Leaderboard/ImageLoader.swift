import UIKit

final class ImageLoader {

    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()

    private init() {}

    func load(url: URL, completion: @escaping (UIImage?) -> Void) {

        let key = url as NSURL

        if let cached = cache.object(forKey: key) {
            DispatchQueue.main.async { completion(cached) }
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }

            guard let data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            self.cache.setObject(image, forKey: key)
            DispatchQueue.main.async { completion(image) }

        }.resume()
    }
}
