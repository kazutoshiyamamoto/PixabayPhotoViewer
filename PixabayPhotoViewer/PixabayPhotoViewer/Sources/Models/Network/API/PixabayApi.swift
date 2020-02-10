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
    func fetchPixabayItems(category: String?, searchWord: String?, page: Int?, perPage: Int?, completion: @escaping (Item) -> ()) {
        let url = URL(string: Consts.apiUrl)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = UrlQueryItemsGenerator().generateSearchQueryItems(category: category, searchWord: searchWord, page: page, perPage: perPage)
        components?.queryItems = queryItems
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
