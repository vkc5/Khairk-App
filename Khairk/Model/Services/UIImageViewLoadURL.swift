//
//  UIImageViewLoadURL.swift
//  Khairk
//
//  Created by BP-19-130-16 on 28/12/2025.
//

import Foundation
import UIKit

extension UIImageView {
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
