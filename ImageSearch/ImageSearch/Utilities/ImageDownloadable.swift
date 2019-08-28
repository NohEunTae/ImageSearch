//
//  ImageDownloadable.swift
//  ImageSearch
//
//  Created by user on 28/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import Kingfisher

protocol ImageDownloadable: AnyObject, ImageProtocol {
    var downloader: ImageDownloader { get }
    var image: UIImage? { get set }
    func downloadImage(completion: ((_: UIImage)->())?)
    func cancelDownload()
}

extension ImageDownloadable {
    func downloadImage(completion: ((_: UIImage)->())?) {
        let cropRatio = CGFloat(width / height)
        let width = UIScreen.main.bounds.width
        let height = width / cropRatio
        let size = CGSize(width: width, height: height)
        downloader.downloadImage(
            with: imageUrl,
            retrieveImageTask: nil,
            options: [
                .processor(ResizingImageProcessor(referenceSize: size)),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ],
            progressBlock: nil,
            completionHandler: { [weak self] (image, error, cacheType, imageUrl) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    let validImage = image ?? UIImage(named: "notFound")!
                    self.image = validImage
                    completion?(validImage)
                }
        })
    }
    
    func cancelDownload() {
        downloader.cancelAll()
    }
}
