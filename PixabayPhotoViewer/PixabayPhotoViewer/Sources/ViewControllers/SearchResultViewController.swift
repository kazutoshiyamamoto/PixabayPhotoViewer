//
//  SearchResultViewController.swift
//  PixabayPhotoViewer
//
//  Created by home on 2020/01/29.
//  Copyright © 2020 Swift-beginners. All rights reserved.
//

import UIKit

class SearchResultViewController: UIViewController {
    
    @IBOutlet weak var searchResultView: UICollectionView!
    
    private var searchResultItems: [Item.Hits] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchResultView.register(UINib(nibName: "PixabayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PixabayCollectionViewCell")
        self.searchResultView.register(UINib(nibName: "PixabayCollectionFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "PixabayCollectionFooterView")
    }
}
