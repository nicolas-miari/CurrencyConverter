//
//  MockNetworkClient.swift
//  CurrencyConverterTests
//
//  Created by Nicolás Miari on 2019/10/07.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation
@testable import CurrencyConverter

/**
 */
class MockNetworkClient: NetworkClientProtocol {

    private enum Behaviour {
        case success (result: Any)
        case failure (error: Error)
    }

    private let behaviour: Behaviour

    // MARK: - Initialization

    /**
     Creates an instance for which calling `get(url:params:completion:failure)` always **succeeds**, resulting in
     the completion handler `completion` being called with `result` as the argument.

     - parameter result: An arbitrary value that will be passed as the completion handler argument whenever
     `get(url:params:completion:failure)` is called.
     */
    init(result: Any) {
        self.behaviour = .success(result: result)
    }

    /**
    Creates an instance for which calling `get(url:params:completion:failure)` always **fails**, resulting in
    the failure handler `failure` being called with `error` as the argument.

     - parameter error: An custom error that will be passed as the failure handler argument whenever
     `get(url:params:completion:failure)` is called.
    */
    init(error: Error) {
        self.behaviour = .failure(error: error)
    }

    // MARK: - NetworkClientProtocol

    func get(url: URL, params: [String : Any], completion: @escaping ((Any) -> Void), failure: @escaping ((Error) -> Void)) {
        switch behaviour {
        case .success(let result):
            completion(result)

        case .failure(let error):
            failure(error)
        }
    }
}
