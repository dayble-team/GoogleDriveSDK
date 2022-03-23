//
//  GoogleAuth+Publisher.swift
//  
//
//  Created by 김태완 on 2022/03/23.
//

import Foundation

import Combine


extension GoogleAuth {
    
    public func readyPublisher() -> AnyPublisher<Void, Never> {
        Just(isReady)
            .merge(with: publisher(for: \.isReady).eraseToAnyPublisher())
            .filter { $0 }
            .map { _ in }
            .first()
            .eraseToAnyPublisher()
    }
    
}
