//
//  JsonFileLoader.swift
//  PixabayPhotoViewer
//
//  Created by home on 2020/02/07.
//  Copyright © 2020 Swift-beginners. All rights reserved.
//

import Foundation

class JsonFileLoader {
    func loadJsonFile<T: Decodable>(resource: String, model: [T].Type, completionHandler: @escaping ([T]) -> ()) {
        guard let path = Bundle.main.path(forResource: resource, ofType: "json") else {
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        guard let data = try? Data(contentsOf: url) else {
            return
        }
        
        let decoded = try! JSONDecoder().decode(model, from: data)
        
        completionHandler(decoded)
    }
}
