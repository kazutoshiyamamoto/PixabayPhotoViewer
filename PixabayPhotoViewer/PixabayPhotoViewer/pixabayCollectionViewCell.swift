//
//  pixabayCollectionViewCell.swift
//  PixabayPhotoViewer
//
//  Created by home on 2019/07/27.
//  Copyright © 2019 Swift-beginners. All rights reserved.
//

import UIKit

class pixabayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pixabayImageView: UIImageView!
    @IBOutlet weak var imageTagLabel: UILabel!
    @IBOutlet weak var imageCreatorNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
