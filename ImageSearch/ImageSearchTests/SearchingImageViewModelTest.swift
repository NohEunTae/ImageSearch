//
//  SearchingImageViewModelTest.swift
//  ImageSearchTests
//
//  Created by user on 29/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest

@testable import ImageSearch

struct FakeNetworking: NetworkBuilder {
    static var shared: NetworkBuilder = FakeNetworking()
    
    func request<T: Codable>(_ param: String) -> Observable<T> {
        return Observable<T>.create({ observer in
            do {
                let data = param.data(using: .utf8)!
                let jsonDic = try JSONSerialization.jsonObject(with: data, options: [])
                let jsonData = try JSONSerialization.data(withJSONObject: jsonDic)
                let decoder = JSONDecoder()
                let model : T = try decoder.decode(T.self, from: jsonData)
                observer.onNext(model)
            }  catch let error {
                observer.onError(error)
            }
            observer.onCompleted()
            return Disposables.create()
        })
    }
}

class SearchingImageViewModelTest: XCTestCase {
    
    private var searchingImageViewModel: SearchImageViewModel!
    private var bag: DisposeBag!
    private var scheduler: TestScheduler!

    private let fourValues = ["documents" : [
        ["imageUrl" : "http://cfile210.uf.daum.net/image/190390254BD51B9C9BD14A", "height" : 442, "width" : 578],
        ["imageUrl" : "http://cfile234.uf.daum.net/image/182AA8284BD5206E0924EA", "height" : 442, "width" : 578],
        ["imageUrl" : "http://storep-phinf.pstatic.net/ogq_56a6fd284d18b/original_21.png?type=p50_50", "height" : 160, "width" : 185],
        ["imageUrl" : "http://postfiles15.naver.net/MjAxODEwMTBfMTU3/MDAxNTM5MTMwNDMwNzI2.-OyS2tMKEPbYZK03E5yx5rJE_az8G10g3byY2IAXpu4g.nzP4ei9QkcUXShD5tDAkugWq2aXgUlkipNC3zDNLUN4g.GIF.djsgi/20181009_194759_2.gif?type=w580", "height" : 325, "width" : 580]]
    ]
    private let zeroValues = ["documents" : []]

    override func setUp() {
        searchingImageViewModel = SearchImageViewModel(builder: FakeNetworking.shared)
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        searchingImageViewModel = nil
        bag = nil
        scheduler = nil
    }
    
    private func dictionaryToString(dic: [String: Any]) -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: dic)
        return String(data: jsonData, encoding: .utf8)!
    }

    func testDataSource() {
        // given
        let expected = 4
        
        // when
        scheduler.createColdObservable([.next(1, dictionaryToString(dic: fourValues))])
            .bind(to: searchingImageViewModel.searchText)
            .disposed(by: bag)
        
        scheduler.start()
        
        searchingImageViewModel.data.drive(onNext: { imagePresenters in
            // then
            XCTAssertEqual(imagePresenters.count, expected)
        }).disposed(by: bag)
    }
    
    func testZeroDataSource() {
        // given
        let expected = SearchImageViewModel.Error.json
        
        // when
        scheduler.createColdObservable([.next(1, dictionaryToString(dic: zeroValues))])
            .bind(to: searchingImageViewModel.searchText)
            .disposed(by: bag)
        
        scheduler.start()
        
        searchingImageViewModel.data.drive(onNext: { imagePresenters in
            // then
            XCTAssertEqual(imagePresenters.count, 0)
        }).disposed(by: bag)
        
        searchingImageViewModel.error.subscribe(onNext: { error in
            // then
            XCTAssertEqual(error, expected)
        }).disposed(by: bag)
    }
    
    func testTableViewCellSelect() {
        
        // given
        let expectedCount = 4
        let expectedIndex = 1
        
        //when
        scheduler.createColdObservable([.next(1, dictionaryToString(dic: fourValues))])
            .bind(to: searchingImageViewModel.searchText)
            .disposed(by: bag)
        scheduler.start()
        
        let indexObservable = Observable<Int>.just(expectedIndex)
        
        Observable.combineLatest(searchingImageViewModel.data.asObservable(), indexObservable) {
            ($0, $1)
            }
            .subscribe(onNext: { imagePresenters, index in
                
                // then
                XCTAssertEqual(imagePresenters.count, expectedCount)
                XCTAssertEqual(index, expectedIndex)
            })
            .disposed(by: bag)
    }
}
