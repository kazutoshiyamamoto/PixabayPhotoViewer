//
//  CategorySearchViewController.swift
//  PixabayPhotoViewer
//
//  Created by home on 2020/01/22.
//  Copyright © 2020 Swift-beginners. All rights reserved.
//

import UIKit

class CategorySearchViewController: UIViewController {
    
    @IBOutlet weak var categoryMenuView: UITableView!
    
    private let categoryMenuTitle = ["ファッション", "自然", "背景", "人", "場所", "動物", "食べ物", "スポーツ", "乗り物", "旅行", "建物", "音楽"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.categoryMenuView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }
}

extension CategorySearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryMenuTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.categoryMenuView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.titleLabel.text = self.categoryMenuTitle[indexPath.row]
        return cell
    }
}

extension CategorySearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.categoryMenuView.deselectRow(at: indexPath, animated: true)
    }
}
