//
//  AppDelegate.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case statusCode(Int)
    case decoding(Error)
    case transport(Error)
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid server response."
        case .statusCode(let code): return "Unexpected status code: \(code)."
        case .decoding(let err): return "Decoding failed: \(err.localizedDescription)"
        case .transport(let err): return "Network error: \(err.localizedDescription)"
        case .noData: return "No data received."
        }
    }
}
