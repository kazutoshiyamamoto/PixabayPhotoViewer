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
    
    private let categoryMenuTitle = ["ファッション", "自然", "背景", "科学", "教育", "人々", "感情", "宗教", "健康", "場所", "動物", "産業", "食品", "コンピューター", "スポーツ", "交通", "旅行", "建物", "ビジネス", "音楽"]
    
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
