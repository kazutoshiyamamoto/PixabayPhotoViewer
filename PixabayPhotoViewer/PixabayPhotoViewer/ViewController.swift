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
        pixabayCollectionView.register(UINib(nibName: "pixabayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "pixabayCollectionViewCell")
    }
}

