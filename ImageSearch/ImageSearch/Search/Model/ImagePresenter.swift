//
//  Image.swift
//  ImageSearch
//
//  Created by user on 26/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class ImagePresenter: ImageDownloadable {
    let imageUrl: URL
    let width: Double
    let height: Double
    var image: UIImage?
    let downloader: ImageDownloader

    init(model: JSONImageData.Image, image: UIImage?) {
        self.image = image
        self.imageUrl = model.imageUrl
        self.width = model.width
        self.height = model.height
        self.downloader = ImageDownloader(name: model.imageUrl.absoluteString)
    }
}
