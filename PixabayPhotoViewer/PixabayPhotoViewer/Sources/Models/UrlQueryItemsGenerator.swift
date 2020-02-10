//
//  UrlQueryItemsGenerator.swift
//  PixabayPhotoViewer
//
//  Created by home on 2020/02/10.
//  Copyright © 2020 Swift-beginners. All rights reserved.
//

import Foundation

class UrlQueryItemsGenerator {
    // 商品一覧取得時のURLQueryItemを生成
    func generateSearchQueryItems(category: String?, searchWord: String?, page: Int?, perPage: Int?) -> [URLQueryItem] {
        
        var namedValues: [(name: String, value: String)] = []
        
        let apiKey = (name: "key", value: "\(Consts.apiKey)")
        namedValues.append(apiKey)
        
        let lang = (name: "lang", value: "ja")
        namedValues.append(lang)
        
        let photo = (name: "image_type", value: "photo")
        namedValues.append(photo)
        
        if category != nil {
            let category = (name: "category", value: "\(category!)")
            namedValues.append(category)
        }
        
        if searchWord != nil {
            let searchWord = (name: "q", value: "\(searchWord!)")
            namedValues.append(searchWord)
        }
        
        if page != nil {
            let page = (name: "page", value: "\(page!)")
            namedValues.append(page)
        }
        
        if perPage != nil {
            let perPage = (name: "per_page", value: "\(perPage!)")
            namedValues.append(perPage)
        }
        
        let queryItems = namedValues.map { URLQueryItem(name: $0.name, value: $0.value) }
        
        return queryItems
    }
}
