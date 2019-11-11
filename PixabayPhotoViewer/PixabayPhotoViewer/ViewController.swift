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
    
    private let urlString =  "https://pixabay.com/api/"
    private var items: [Item.Hits] = []
    private var pageNo = 1
    private var isLoadingList = false
    private var isLastPageReached = false
    
    private let preheater = ImagePreheater()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pixabayCollectionView.register(UINib(nibName: "PixabayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PixabayCollectionViewCell")
        self.pixabayCollectionView.register(UINib(nibName: "PixabayCollectionFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "PixabayCollectionFooterView")
        
        self.pixabayCollectionView.delegate = self
        self.pixabayCollectionView.dataSource = self
        self.pixabayCollectionView.prefetchDataSource = self
        
        self.setUpPixabayItems()
        
        let refreshControl = UIRefreshControl()
        self.pixabayCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(ViewController.refresh(sender:)), for: .valueChanged)
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        // ページ番号を元に戻す
        self.pageNo = 1
        self.items = []
        self.isLastPageReached = false
        self.setUpPixabayItems()
        sender.endRefreshing()
    }
    
    private func setUpPixabayItems() {
        self.isLoadingList = true
        self.getPixabayItems(pageNo: self.pageNo, completion: { (item) in
            self.pageNo += 1
            self.items.append(contentsOf: item.hits)
            
            // 返ってきたデータの数が0もしくは3で割り切れない数が返ってきた場合は最後のページにたどり着いたと判定する
            if item.hits.count == 0 || item.hits.count % 3 != 0 {
                self.isLastPageReached = true
            }
            
            DispatchQueue.main.async {
                self.isLoadingList = false
                self.pixabayCollectionView.reloadData()
            }
        })
    }
    
    private func getPixabayItems(pageNo: Int, completion: @escaping (Item) -> ()) {
        let url = URL(string: "https://pixabay.com/api/")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "key", value: "13068565-c1fdd03743ba0daf1922d861e")] + [URLQueryItem(name: "page", value: "\(self.pageNo)")] + [URLQueryItem(name: "per_page", value: "60")] + [URLQueryItem(name: "q", value: "sea")] + [URLQueryItem(name: "image_type", value: "photo")]
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

extension ViewController: UICollectionViewDelegate {
    // セル選択時の処理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = URL(string: self.items[indexPath.row].webformatURL) {
            UIApplication.shared.open(url)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: "PixabayCollectionFooterView", for: indexPath) as! PixabayCollectionFooterView
            
            if self.isLoadingList == false && self.isLastPageReached == false {
                footerView.isHidden = false
                footerView.activityIndicatorView.startAnimating()
                self.isLoadingList = true
                
                self.getPixabayItems(pageNo: self.pageNo, completion: { (item) in
                    self.pageNo += 1
                    self.items.append(contentsOf: item.hits)
                    // 返ってきたデータの数が0もしくは3で割り切れない数が返ってきた場合は最後のページにたどり着いたと判定する
                    if item.hits.count == 0 || item.hits.count % 3 != 0 {
                        self.isLastPageReached = true
                    }
                    DispatchQueue.main.async {
                        self.isLoadingList = false
                        footerView.activityIndicatorView.stopAnimating()
                        footerView.isHidden = true
                        self.pixabayCollectionView.reloadData()
                    }
                })
            }
        }
    }
}

extension ViewController:  UICollectionViewDelegateFlowLayout {
    // セルの大きさ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfCell: CGFloat = 3
        let cellWidth = UIScreen.main.bounds.size.width  / numberOfCell - 6
        return CGSize(width: cellWidth, height: 160)
    }
    
    // フッターの高さ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.items.count > 0 && self.isLastPageReached == false {
            return CGSize(width: collectionView.frame.width, height: 40)
        }
        return .zero
    }
}

extension ViewController: UICollectionViewDataSource {
    // セルの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // セルの設定
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PixabayCollectionViewCell", for: indexPath) as! PixabayCollectionViewCell
        
        let item = self.items[indexPath.row]
        let previewUrl = URL(string: item.previewURL)!
        Nuke.loadImage(with: previewUrl, into: cell.pixabayImageView)
        cell.imageTagLabel.text = item.tags
        cell.imageCreatorNameLabel.text = item.user
        
        return cell
    }
    
    // フッターの設定
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PixabayCollectionFooterView", for: indexPath) as! PixabayCollectionFooterView
            return footerView
        }
        return UICollectionReusableView()
    }
}

extension ViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.map { URL(string: self.items[$0.row].previewURL) }
        self.preheater.startPreheating(with: urls as! [URL])
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.map { URL(string: self.items[$0.row].previewURL) }
        self.preheater.stopPreheating(with: urls as! [URL])
    }
}


