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
    func generateSearchQueryItems(category: String?, page: Int?, perPage: Int?) -> [URLQueryItem] {
        
        var namedValues: [(name: String, value: String)] = []
        
        if category != nil {
            let category = (name: "category", value: "\(category!)")
            namedValues.append(category)
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
