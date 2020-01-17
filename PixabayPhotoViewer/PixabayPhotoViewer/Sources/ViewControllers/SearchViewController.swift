//
//  SearchViewController.swift
//  PixabayPhotoViewer
//
//  Created by home on 2020/01/15.
//  Copyright © 2020 Swift-beginners. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchMenuView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchMenuView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }
}
