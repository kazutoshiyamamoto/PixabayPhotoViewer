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
    
    private let searchMenuTitle = ["カテゴリから探す"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchMenuView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.searchMenuView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.titleLabel.text = self.searchMenuTitle[indexPath.row]
        return cell
    }
}
