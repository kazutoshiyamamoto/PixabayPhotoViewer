//
//  ViewController.swift
//  PixabayPhotoViewer
//
//  Created by home on 2019/07/27.
//  Copyright © 2019 Swift-beginners. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var pixabayCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pixabayCollectionView.register(UINib(nibName: "pixabayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "pixabayCollectionViewCell")
        
        self.pixabayCollectionView.delegate = self
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

