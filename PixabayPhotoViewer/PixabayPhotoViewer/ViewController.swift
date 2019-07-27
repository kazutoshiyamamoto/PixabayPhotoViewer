//
//  ViewController.swift
//  PixabayPhotoViewer
//
//  Created by home on 2019/07/27.
//  Copyright © 2019 Swift-beginners. All rights reserved.
//

import UIKit
import Nuke

struct Item: Codable {
    var hits: [Hits]
    struct Hits: Codable {
        var user: String
        var previewURL: String
        var webformatURL: String
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var pixabayCollectionView: UICollectionView!
    
    private var items: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pixabayCollectionView.register(UINib(nibName: "pixabayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "pixabayCollectionViewCell")
        
        self.pixabayCollectionView.delegate = self
        self.pixabayCollectionView.dataSource = self
        
        self.setUpCollectionItems()
    }
    
    private func setUpCollectionItems() {
        self.getCollectionItems(completionHandler: { (item) in
            self.items = item
            DispatchQueue.main.async {
                self.pixabayCollectionView.reloadData()
            }
        })
    }
    
    private func getCollectionItems(completionHandler: @escaping (Item) -> ()) {
        let configuration = URLSessionConfiguration.default
        
        if let url = URL(string: "https://pixabay.com/api/?key={APIKey}&q=city&image_type=photo") {
            self.getAddConfiguration(url: url, configuration: configuration, completionHandler: {(data, response, error) -> Void in
                if let data = data {
                    
                    do {
                        let decoder = JSONDecoder()
                        let items = try decoder.decode(Item.self, from: data)
                        completionHandler(items)
                    } catch {
                        print("Serialize Error")
                    }
                } else {
                    print(error ?? "Error")
                }
            })
        }
    }
    
    private func getAddConfiguration(url: URL, configuration: URLSessionConfiguration, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let session = URLSession(configuration: configuration)
        session.dataTask(with: url, completionHandler: completionHandler).resume()
    }
}

extension ViewController:  UICollectionViewDelegateFlowLayout {
    // セルの大きさ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfCell: CGFloat = 3
        let cellWidth = UIScreen.main.bounds.size.width / numberOfCell - 3
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

extension ViewController: UICollectionViewDataSource {
    // セルの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items?.hits.count ?? 0
    }
    
    // セルの設定
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pixabayCollectionViewCell", for: indexPath) as! pixabayCollectionViewCell
        
        let item = self.items?.hits[indexPath.row]
        cell.imageCreatorNameLabel.text = item?.user
        let previewUrl = URL(string: item?.previewURL ?? "")!
        Nuke.loadImage(with: previewUrl, into: cell.pixabayImageView)
        
        return cell
    }
}

