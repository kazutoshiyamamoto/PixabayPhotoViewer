//
//  SearchResultViewController.swift
//  PixabayPhotoViewer
//
//  Created by home on 2020/01/29.
//  Copyright © 2020 Swift-beginners. All rights reserved.
//

import UIKit
import Nuke

class SearchResultViewController: UIViewController {
    
    @IBOutlet weak var searchResultView: UICollectionView!
    
    private let preheater = ImagePreheater()
    
    // 検索対象のカテゴリ
    var categoryQuery = ""
    // 検索ワード
    private var searchWord = ""
    private var page = 1
    private var perPage = 60
    private var isLoadingList = false
    private var isLastPageReached = false
    
    private var searchResultItems: [Item.Hits] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchResultView.register(UINib(nibName: "PixabayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PixabayCollectionViewCell")
        self.searchResultView.register(UINib(nibName: "PixabayCollectionFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "PixabayCollectionFooterView")
        
        self.displaySearchResultItems()
        
        let refreshControl = UIRefreshControl()
        self.searchResultView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(SearchResultViewController.refresh(sender:)), for: .valueChanged)
    }
    
    private func displaySearchResultItems() {
        self.isLoadingList = true
        PixabayApi().fetchPixabayItems(category: self.categoryQuery, searchWord: self.searchWord, page: self.page, perPage: self.perPage, completion: { (result) in
            
            switch result {
            case .success(let item):
                self.page += 1
                self.searchResultItems.append(contentsOf: item.hits)
                
                // 返ってきたデータの数が0もしくは1ページあたりの件数で割り切れない数、PixabayAPIを介してアクセス可能な画像の上限に達した場合は最後のページにたどり着いたと判定する
                if item.hits.count % self.perPage != 0 || self.searchResultItems.count >= 500 {
                    self.isLastPageReached = true
                }
                
                DispatchQueue.main.async {
                    self.isLoadingList = false
                    self.searchResultView.reloadData()
                }
                
            case .failure(let error):
                self.isLoadingList = false
                self.isLastPageReached = true
                print(error)
            }
        })
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        // ページ番号を元に戻す
        self.page = 1
        self.searchResultItems = []
        self.isLastPageReached = false
        self.displaySearchResultItems()
        sender.endRefreshing()
    }
}

extension SearchResultViewController: UICollectionViewDataSource {
    // セルの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.searchResultItems.count
    }
    
    // セルの設定
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PixabayCollectionViewCell", for: indexPath) as! PixabayCollectionViewCell
        
        if collectionView.contentOffset.y >= 0 {
            let item = self.searchResultItems[indexPath.row]
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

extension SearchResultViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if self.searchResultItems.count > 0 && collectionView.contentOffset.y > 0 {
            let urls = indexPaths.map { URL(string: self.searchResultItems[$0.row].previewURL) }
            self.preheater.startPreheating(with: urls as! [URL])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        if self.searchResultItems.count > 0 && collectionView.contentOffset.y > 0 {
            let urls = indexPaths.map { URL(string: self.searchResultItems[$0.row].previewURL) }
            self.preheater.stopPreheating(with: urls as! [URL])
        }
    }
}

extension SearchResultViewController: UICollectionViewDelegate {
    // セル選択時の処理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = URL(string: self.searchResultItems[indexPath.row].webformatURL) {
            UIApplication.shared.open(url)
        }
    }
    
    // フッターが表示されそうになるタイミングで呼ばれる
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: "PixabayCollectionFooterView", for: indexPath) as! PixabayCollectionFooterView
            
            if self.isLoadingList == false && self.isLastPageReached == false {
                footerView.isHidden = false
                footerView.activityIndicatorView.startAnimating()
                self.isLoadingList = true
                
                PixabayApi().fetchPixabayItems(category: self.categoryQuery, searchWord: self.searchWord, page: self.page, perPage: self.perPage, completion: { (result) in
                    
                    switch result {
                    case .success(let item):
                        self.page += 1
                        self.searchResultItems.append(contentsOf: item.hits)
                        // 返ってきたデータの数が0もしくは1ページあたりの件数で割り切れない数、PixabayAPIを介してアクセス可能な画像の上限に達した場合は最後のページにたどり着いたと判定する
                        if item.hits.count % self.perPage != 0 || self.searchResultItems.count >= 500 {
                            self.isLastPageReached = true
                        }
                        DispatchQueue.main.async {
                            self.isLoadingList = false
                            footerView.activityIndicatorView.stopAnimating()
                            footerView.isHidden = true
                            self.searchResultView.reloadData()
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

extension SearchResultViewController: UICollectionViewDelegateFlowLayout {
    // セルのサイズ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfCell: CGFloat = 3
        let cellWidth = UIScreen.main.bounds.size.width  / numberOfCell - 2.8
        return CGSize(width: cellWidth, height: cellWidth + 45)
    }
    
    // フッターのサイズ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.searchResultItems.count > 0 && self.isLastPageReached == false {
            return CGSize(width: collectionView.frame.width, height: 40)
        }
        return .zero
    }
}
