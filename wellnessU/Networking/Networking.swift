//
//  Networking.swift
//  wellnessU
//
//  Created by Brayden Harris on 10/7/21.
//

import UIKit

class Networking {
    func fetchQuotes() async throws -> ContentList {
        var request = URLRequest(url: Endpoint.quotes.url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkingError.invalidResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(ContentList.self, from: data)
        } catch {
            throw NetworkingError.parsingError(description: error.localizedDescription)
        }
    }

    func fetchProfileImage(urlString: String?) async throws -> UIImage {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            throw NetworkingError.invalidURL
        }
        let request = URLRequest(url: url)

        let (data, _) = try await URLSession.shared.data(for: request)

        guard let image = UIImage(data: data) else {
            throw NetworkingError.unableToDecodeImage
        }

        return image
    }
}

enum NetworkingError: Error {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case parsingError(description: String)
    case unableToDecodeImage
}

enum Endpoint {
    case quotes

    var host: String {
        "live.bored-tester.net"
    }

    var path: String {
        switch self {
        case .quotes:
            return "/api/quotes"
        }
    }

    var url: URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
        urlComponents.path = path
        guard let url = urlComponents.url else {
            fatalError("Failed to construct URL")
        }
        return url
    }
}
