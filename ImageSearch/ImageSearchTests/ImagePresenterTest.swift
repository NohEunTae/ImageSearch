//
//  ImagePresenterTest.swift
//  ImageSearchTests
//
//  Created by user on 29/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import XCTest

@testable import ImageSearch

class ImagePresenterTest: XCTestCase {
    private var imagePresenter: ImagePresenter!
    
    override func setUp() {
    }

    override func tearDown() {
        imagePresenter = nil
    }

    func testImageDownload() {
        
        // given
        let image = JSONImageData.Image(imageUrl: URL(string: "http://cfile210.uf.daum.net/image/190390254BD51B9C9BD14A")!, width: 578, height: 442)
        imagePresenter = ImagePresenter(model: image)

        let expectation = self.expectation(description: "Image")
        var checkImage: UIImage? = nil
        
        // when
        imagePresenter.downloadImage { image in
            checkImage = image
            expectation.fulfill()
        }
        
        // then
        waitForExpectations(timeout: 5) { error in
            guard error == nil else {
                XCTFail()
                return
            }
            
        }
        
        XCTAssertNotNil(checkImage)
    }

}
