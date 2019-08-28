//
//  Root.swift
//  ImageSearch
//
//  Created by user on 26/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation

struct JSONImageData: Codable {
    let documents: [Image]
    
    struct Image: Codable, ImageProtocol {
        let imageUrl: URL
        let width: Double
        let height: Double
    }
}
