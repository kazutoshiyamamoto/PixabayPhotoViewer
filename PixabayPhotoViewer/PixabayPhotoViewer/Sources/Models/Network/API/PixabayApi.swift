//
//  PixabayApi.swift
//  PixabayPhotoViewer
//
//  Created by home on 2020/01/02.
//  Copyright © 2020 Swift-beginners. All rights reserved.
//

import Foundation

struct Item: Codable {
    var hits: [Hits]
    struct Hits: Codable {
        var previewURL: String
        var tags: String
        var user: String
        var webformatURL: String
    }
}

class PixabayApi {
    func getPixabayItems(pageNo: Int, perPage: Int, completion: @escaping (Item) -> ()) {
        let url = URL(string: "https://pixabay.com/api/")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "key", value: "")] + [URLQueryItem(name: "page", value: "\(pageNo)")] + [URLQueryItem(name: "per_page", value: "\(perPage)")] + [URLQueryItem(name: "q", value: "sea")] + [URLQueryItem(name: "image_type", value: "photo")]
        let queryStringAddedUrl = components?.url
        
        if let url = queryStringAddedUrl {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    
                    do {
                        let decoder = JSONDecoder()
                        let items = try decoder.decode(Item.self, from: data)
                        completion(items)
                    } catch {
                        print("Serialize Error")
                    }
                } else {
                    print(error ?? "Error")
                }
            }
            task.resume()
        }
    }
}