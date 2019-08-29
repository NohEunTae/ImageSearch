//
//  Networking.swift
//  ImageSearch
//
//  Created by user on 26/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

protocol NetworkBuilder {
    var baseUrl: String { get }
    var key: [String: String] { get }
    static var shared: NetworkBuilder { get }
    func request<T: Codable>(_ param: String) -> Observable<T>
}

extension NetworkBuilder {
    var baseUrl: String {
        return "https://dapi.kakao.com/v2/search/image?query="
    }
    
    var key: [String: String] {
        return ["Authorization": "KakaoAK 57c7624a2478f7c7ebc1678f82867b69"]
    }
}

struct Networking: NetworkBuilder {
    static let shared: NetworkBuilder = Networking()
    
    func request<T: Codable>(_ param: String) -> Observable<T> {
        var str_search = baseUrl + param
        
        return Observable<T>.create({ observer in
            str_search = str_search.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let dataRequest = Alamofire.request(str_search,
                                                method: .get,
                                                encoding: JSONEncoding.prettyPrinted,
                                                headers: self.key)
                .responseJSON{ response in
                    switch response.result {
                    case .success(let json):
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: json)
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            let model : T = try decoder.decode(T.self, from: jsonData)
                            observer.onNext(model)
                        } catch let error {
                            observer.onError(error)
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                    observer.onCompleted()
            }
            return Disposables.create {
                dataRequest.cancel()
            }
        })
    }
}
