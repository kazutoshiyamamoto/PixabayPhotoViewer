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
    
    private var searchResultItems: [Item.Hits] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchResultView.register(UINib(nibName: "PixabayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PixabayCollectionViewCell")
        self.searchResultView.register(UINib(nibName: "PixabayCollectionFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "PixabayCollectionFooterView")
    }
}

extension SearchResultViewController: UICollectionViewDataSource {
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
}
