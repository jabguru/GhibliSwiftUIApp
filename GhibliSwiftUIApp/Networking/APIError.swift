//
//  APIError.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 05/08/2026.
//


import Foundation

enum APIError : LocalizedError {
    case invalidURL, invalidResponse
    case decoding(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The URL is Invalid"
        case .invalidResponse: return "Invalid response from server"
        case .decoding(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
    
}
