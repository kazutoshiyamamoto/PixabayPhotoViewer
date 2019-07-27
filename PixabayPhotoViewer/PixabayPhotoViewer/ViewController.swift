//
//  ViewController.swift
//  PixabayPhotoViewer
//
//  Created by home on 2019/07/27.
//  Copyright © 2019 Swift-beginners. All rights reserved.
//

import UIKit
import Nuke

class ViewController: UIViewController {
    
    @IBOutlet weak var pixabayCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pixabayCollectionView.register(UINib(nibName: "pixabayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "pixabayCollectionViewCell")
        
        self.pixabayCollectionView.delegate = self
        self.pixabayCollectionView.dataSource = self
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
        return 3
    }
    
    // セルの設定
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pixabayCollectionViewCell", for: indexPath) as! pixabayCollectionViewCell
        
        return cell
    }
}

