//
//  AppDelegate.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import Foundation

protocol APIClientProtocol {
    func fetchHoldings(completion: @escaping (Result<HoldingsResponse, Error>) -> Void)
}

final class APIClient: APIClientProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchHoldings(completion: @escaping (Result<HoldingsResponse, Error>) -> Void) {
        let request = URLRequest(url: Endpoint.baseURL)
        DispatchQueue.global().async {
            let task = self.session.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(NetworkError.transport(error)))
                        return
                    }

                    guard let http = response as? HTTPURLResponse else {
                        completion(.failure(NetworkError.invalidResponse))
                        return
                    }

                    guard (200...299).contains(http.statusCode) else {
                        completion(.failure(NetworkError.statusCode(http.statusCode)))
                        return
                    }

                    guard let data = data else {
                        completion(.failure(NetworkError.invalidResponse))
                        return
                    }

                    do {
                        let decoded = try JSONDecoder().decode(HoldingsResponse.self, from: data)
                        completion(.success(decoded))
                    } catch let e as DecodingError {
                        completion(.failure(NetworkError.decoding(e)))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
            task.resume()
        }
    }
}
