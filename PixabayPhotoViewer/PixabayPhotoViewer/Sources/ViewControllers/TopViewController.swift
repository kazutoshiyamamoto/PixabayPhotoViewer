//
//  ViewController.swift
//  PixabayPhotoViewer
//
//  Created by home on 2019/07/27.
//  Copyright © 2019 Swift-beginners. All rights reserved.
//

import UIKit
import Nuke

class TopViewController: UIViewController {
    
    @IBOutlet weak var pixabayCollectionView: UICollectionView!
    
    private var items: [Item.Hits] = []
    private var page = 1
    private var perPage = 60
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
        refreshControl.addTarget(self, action: #selector(TopViewController.refresh(sender:)), for: .valueChanged)
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        // ページ番号を元に戻す
        self.page = 1
        self.items = []
        self.isLastPageReached = false
        self.setUpPixabayItems()
        sender.endRefreshing()
    }
    
    private func setUpPixabayItems() {
        self.isLoadingList = true
        PixabayApi().fetchPixabayItems(category: nil, searchWord: "海", page: self.page, perPage: self.perPage, completion: { (result) in
            
            switch result {
            case .success(let item):
                self.page += 1
                self.items.append(contentsOf: item.hits)
                
                // 返ってきたデータの数が0もしくは1ページあたりの件数で割り切れない数、PixabayAPIを介してアクセス可能な画像の上限に達した場合は最後のページにたどり着いたと判定する
                if item.hits.count % self.perPage != 0 || self.items.count >= 500 {
                    self.isLastPageReached = true
                }
                
                DispatchQueue.main.async {
                    self.isLoadingList = false
                    self.pixabayCollectionView.reloadData()
                }
                
            case .failure(let error):
                self.isLoadingList = false
                self.isLastPageReached = true
                print(error)
            }
        })
    }
}

extension TopViewController: UICollectionViewDataSource {
    // セルの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // セルの設定
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PixabayCollectionViewCell", for: indexPath) as! PixabayCollectionViewCell
        
        if collectionView.contentOffset.y >= 0 {
            let item = self.items[indexPath.row]
            let previewUrl = URL(string: item.previewURL)!
            Nuke.loadImage(with: previewUrl, into: cell.pixabayImageView)
            cell.imageTagLabel.text = item.tags
            cell.imageCreatorNameLabel.text = item.user
        }
        
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

extension TopViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if self.items.count > 0 && collectionView.contentOffset.y > 0 {
            let urls = indexPaths.map { URL(string: self.items[$0.row].previewURL) }
            self.preheater.startPreheating(with: urls as! [URL])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        if self.items.count > 0 && collectionView.contentOffset.y > 0 {
            let urls = indexPaths.map { URL(string: self.items[$0.row].previewURL) }
            self.preheater.stopPreheating(with: urls as! [URL])
        }
    }
}

extension TopViewController: UICollectionViewDelegate {
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
                
                PixabayApi().fetchPixabayItems(category: nil, searchWord: "海", page: self.page, perPage: self.perPage, completion: { (result) in
                    
                    switch result {
                    case .success(let item):
                        self.page += 1
                        self.items.append(contentsOf: item.hits)
                        
                        // 返ってきたデータの数が0もしくは1ページあたりの件数で割り切れない数、PixabayAPIを介してアクセス可能な画像の上限に達した場合は最後のページにたどり着いたと判定する
                        if item.hits.count % self.perPage != 0 || self.items.count >= 500 {
                            self.isLastPageReached = true
                        }
                        
                        DispatchQueue.main.async {
                            self.isLoadingList = false
                            footerView.activityIndicatorView.stopAnimating()
                            footerView.isHidden = true
                            self.pixabayCollectionView.reloadData()
                        }
                        
                    case .failure(let error):
                        self.isLoadingList = false
                        self.isLastPageReached = true
                        print(error)
                    }
                })
            }
        }
    }
}

extension TopViewController: UICollectionViewDelegateFlowLayout {
    // セルのサイズ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfCell: CGFloat = 3
        let cellWidth = UIScreen.main.bounds.size.width  / numberOfCell - 2.8
        return CGSize(width: cellWidth, height: cellWidth + 45)
    }
    
    // フッターのサイズ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.items.count > 0 && self.isLastPageReached == false {
            return CGSize(width: collectionView.frame.width, height: 40)
        }
        return .zero
    }
}
