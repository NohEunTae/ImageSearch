//
//  ImageProtocol.swift
//  ImageSearch
//
//  Created by user on 28/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation

protocol Size {
    var width: Double { get }
    var height: Double { get }
}

protocol ImageProtocol: Size {
    var imageUrl: URL { get }
}
