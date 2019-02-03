//
//  APIClient.swift
//  Flickr
//
//  Created by Sebastian Garbarek on 2/02/19.
//  Copyright © 2019 Sebastian Garbarek. All rights reserved.
//

import Foundation
import Alamofire

typealias Response<T> = (_ result: Result<T>) -> Void

class APIClient {

    private static let baseUrl: URL = URL(string: "https://api.flickr.com/services/rest")!
    private static let key: String = "8e15e775f3c4e465131008d1a8bcd616"

    private static let parameters: Parameters = [
        "api_key": key,
        "format": "json",
        "nojsoncallback": 1
    ]

    static let shared: APIClient = APIClient()

    let imageCache = NSCache<NSString, UIImage>()

    @discardableResult
    private static func request<T: Decodable>(path: String? = nil,
                                              method: HTTPMethod,
                                              parameters: Parameters?,
                                              decoder: JSONDecoder = JSONDecoder(),
                                              completion: @escaping (Result<T>) -> Void) -> DataRequest {
        let parameters = parameters?.merging(APIClient.parameters, uniquingKeysWith: { (a, _) in a })
        return AF.request(try! encode(path: path, method: method, parameters: parameters))
            .responseDecodable (decoder: decoder) { (response: DataResponse<T>) in completion(response.result) }
    }

    private static func encode(path: String?, method: HTTPMethod, parameters: Parameters?) throws -> URLRequest {
        var url = APIClient.baseUrl

        if let path = path {
            url = url.appendingPathComponent(path)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        return try URLEncoding.default.encode(urlRequest, with: parameters)
    }

    static func getRecentPhotos(page: Int, response: @escaping Response<PagedRecentPhotos>) {
        let parameters: Parameters = [
            "method": "flickr.photos.getRecent",
            "page": page,
            "per_page": 50,
            "extras": "date_upload"
        ]

        request(method: .get, parameters: parameters, completion: response)
    }

    static func getUser(id: String?, response: @escaping Response<Profile>) {
        guard let id = id else {
            return
        }

        let parameters: Parameters = [
            "method": "flickr.profile.getProfile",
            "user_id": id
        ]

        request(method: .get, parameters: parameters, completion: response)
    }

    static func search(page: Int, text: String, response: @escaping Response<PagedSearchPhotos>) {
        guard !text.isEmpty else {
            return
        }

        let parameters: Parameters = [
            "method": "flickr.photos.search",
            "text": text,
            "page": page,
            "per_page": 50
        ]

        request(method: .get, parameters: parameters, completion: response)
    }

}

struct PagedRecentPhotos: Codable {

    let photos: Photos?

}

struct PagedSearchPhotos: Codable {

    let photos: SearchPhotos?

}

struct Photos: Codable {

    let page: Int64?
    let pages: Int64?
    let perpage: Int64?
    let photo: [Photo]?

    var isLastPage: Bool {
        return page == pages
    }

}

struct SearchPhotos: Codable {

    let page: Int64?
    let pages: Int64?
    let perpage: Int64?
    let photo: [Photo]?
    let total: String?

    var isLastPage: Bool {
        return page == pages
    }

}

struct Photo: Codable, Hashable {

    let id: String?
    let owner: String?
    let secret: String?
    let server: String?
    let farm: Int64?
    let title: String?
    let uploadDate: String?

    private func imageUrl(size: String) -> String? {
        guard let farm = farm, let server = server, let id = id, let secret = secret else {
            return nil
        }

        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_\(size).jpg"
    }

    var thumbnailUrl: URL? {
        guard let url = imageUrl(size: "t") else {
            return nil
        }

        return URL(string: url)!
    }

    var largeUrl: URL? {
        guard let url = imageUrl(size: "b") else {
            return nil
        }

        return URL(string: url)!
    }

}

struct Profile: Codable {

    let profile: User
    
}

struct User: Codable {

    let firstName: String?
    let lastName: String?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
    }

}
