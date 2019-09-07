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
        var previewURL: String
        var tags: String
        var user: String
        var webformatURL: String
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var pixabayCollectionView: UICollectionView!
    
    private var items: Item?
    private let preheater = ImagePreheater()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pixabayCollectionView.register(UINib(nibName: "pixabayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "pixabayCollectionViewCell")
        
        self.pixabayCollectionView.delegate = self
        self.pixabayCollectionView.dataSource = self
        self.pixabayCollectionView.prefetchDataSource = self
        
        self.setUpCollectionItems()

        let refreshControl = UIRefreshControl()
        self.pixabayCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(ViewController.refresh(sender:)), for: .valueChanged)
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        self.setUpCollectionItems()
        sender.endRefreshing()
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
        
        if let url = URL(string: "https://pixabay.com/api/?key={APIKey}&q=sea&image_type=photo") {
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

// セル選択時の処理
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = URL(string: self.items?.hits[indexPath.row].webformatURL ?? "") {
            UIApplication.shared.open(url)
        }
    }
}

// セルの大きさ
extension ViewController:  UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let numberOfCell: CGFloat = 3
        let cellWidth = UIScreen.main.bounds.size.width  / numberOfCell - 6
        return CGSize(width: cellWidth, height: 160)
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
        
        cell.pixabayImageView.image = nil
        cell.imageTagLabel.text = nil
        cell.imageCreatorNameLabel.text = nil
        
        let item = self.items?.hits[indexPath.row]
        let previewUrl = URL(string: item?.previewURL ?? "")!
        Nuke.loadImage(with: previewUrl, into: cell.pixabayImageView)
        cell.imageTagLabel.text = item?.tags
        cell.imageCreatorNameLabel.text = item?.user
        
        return cell
    }
}

extension ViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.map { URL(string: self.items?.hits[$0.row].previewURL ?? "") }
        preheater.startPreheating(with: urls as! [URL])
        
        print("prefetchItemsAt: \(indexPaths)")
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.map { URL(string: self.items?.hits[$0.row].previewURL ?? "") }
        preheater.stopPreheating(with: urls as! [URL])
        
        print("cancelPrefetchingForItemsAt: \(indexPaths)")
    }
}


