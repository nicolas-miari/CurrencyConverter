//
//  Networking.swift
//  CurrencyConverter
//
//  Created by Nicolás Miari on 2019/10/04.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation

/**
 Minimal network client just for the sake of this basic example, based around the `URLSession` API.
 If and when things get more serious (e.g., reuqirement to handle all sorts of errors and more complex
 behaviours) we can always adopt a robust, third-part library such as AlamoFire and wrap it behind
 this class, and keep the rest of the code untainted by the external dependency.

 Loosely based on: https://thatthinginswift.com/write-your-own-api-clients-swift/
 and: https://stackoverflow.com/a/42697085/433373
 */
class NetworkClient {

    static let shared = NetworkClient()

    func get(url: URL, params: [String: Any], completion: @escaping ((Any) -> Void), failure: @escaping ((Error) -> Void)) {
        let request = getRequest(url: url, params: params)

        //let request = clientURLRequest(url: url, method: "GET", params: params)

        dataTask(request: request, method: "GET") { (success, object) in
            if success, let object = object {
                completion(object)
            } else {
                failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error"]))
            }
        }
    }
}

// MARK: - Supporting Functions

func getRequest(url: URL, params: [String: Any]? = nil) -> URLRequest {
    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

    let queryItems = params?.compactMap { (key, value) -> URLQueryItem? in
        if let integerValue = value as? Int {
            return URLQueryItem(name: key, value: String(integerValue))
        } else if let stringValue = value as? String {
            return URLQueryItem(name: key, value: stringValue)
        }
        return nil
    }
    components.queryItems = queryItems

    var request = URLRequest(url: components.url!)
    request.httpMethod = "GET"

    return request
}

private func dataTask(request: URLRequest, method: String, completion: @escaping (Bool, Any?) -> Void) {
    let session = URLSession(configuration: .default)

    session.dataTask(with: request) { (data, response, error) -> Void in
        if let data = data {
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                completion(true, json ?? data)
            } else {
                completion(false, json)
            }
        } else {
            // No data
            print(error?.localizedDescription ?? "")
            completion(false, nil)
        }
    }.resume()
}
