//
//  SearchImageViewModel.swift
//  ImageSearch
//
//  Created by user on 26/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct SearchImageViewModel {
    enum Error {
        case network
        case json
        case none
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    let searchText = BehaviorRelay(value: "")
    let indicatorAnimating = BehaviorRelay<Bool>(value: false)
    let error = BehaviorRelay<Error>(value: .none)
    
    lazy var data: Driver<[ImagePresenter]> = {
        return self.searchText.asObservable()
            .flatMapLatest(fetchData)
            .asDriver(onErrorJustReturn: [])
    }()
    
    func fetchData(_ text: String) -> Observable<[ImagePresenter]> {
        guard !text.isEmpty else { return Observable.just([]) }
        let value: Observable<JSONImageData> = Networking.request(param: text)
        
        return Observable<[ImagePresenter]>.create({ observer in
            value.subscribe(onNext: { json in
                let models = json.documents
                let results = models.map { ImagePresenter(model: $0, image: nil)}
                observer.onNext(results)
                models.isEmpty ? self.error.accept(.json) : self.error.accept(.none)
                self.indicatorAnimating.accept(false)
            }, onError: { error in
                self.indicatorAnimating.accept(false)
                self.error.accept(.network)
            })
        })
    }
}
