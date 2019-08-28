//
//  NetworkingTest.swift
//  ImageSearchTests
//
//  Created by user on 29/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxCocoa

@testable import ImageSearch

class NetworkingTest: XCTestCase {
    let bag = DisposeBag()
    
    var mockJSONImageData: JSONImageData?
    
    override func setUp() {
        let mockDic = ["documents" : [
            ["imageUrl" : "http://cfile210.uf.daum.net/image/190390254BD51B9C9BD14A", "height" : 442, "width" : 578],
            ["imageUrl" : "http://cfile234.uf.daum.net/image/182AA8284BD5206E0924EA", "height" : 442, "width" : 578],
            ["imageUrl" : "http://storep-phinf.pstatic.net/ogq_56a6fd284d18b/original_21.png?type=p50_50", "height" : 160, "width" : 185],
            ["imageUrl" : "http://postfiles15.naver.net/MjAxODEwMTBfMTU3/MDAxNTM5MTMwNDMwNzI2.-OyS2tMKEPbYZK03E5yx5rJE_az8G10g3byY2IAXpu4g.nzP4ei9QkcUXShD5tDAkugWq2aXgUlkipNC3zDNLUN4g.GIF.djsgi/20181009_194759_2.gif?type=w580", "height" : 325, "width" : 580]]
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: mockDic)
            let decoder = JSONDecoder()
            let model : JSONImageData = try decoder.decode(JSONImageData.self, from: jsonData)
            mockJSONImageData = model
        }  catch let error {
            XCTFail(error.localizedDescription)
        }
    }

    override func tearDown() {
        mockJSONImageData = nil
    }

    func testRequest() {
        // given
        let testParam = "설현"
        
        // when
        let value: Observable<JSONImageData> = Networking.shared.request(param: testParam)
        value
            //then
            .subscribe(onNext: { json in
                XCTAssertNotNil(json)
            }, onError: { error in
                XCTFail(error.localizedDescription)
            })
            .disposed(by: bag)
    }
    
    func testMock() {
        guard let mockJSONImageData = mockJSONImageData else {
            XCTFail("mock data not setup yet")
            return
        }
        
        //given
        let param = "선미누야"
        
        //when
        let value: Observable<JSONImageData> = Networking.shared.request(param: param)
        value
            //then
            .subscribe(onNext: { json in
                XCTAssertEqual(json, mockJSONImageData)
            }, onError: { error in
                XCTFail(error.localizedDescription)
            })
            .disposed(by: bag)
    }
}
