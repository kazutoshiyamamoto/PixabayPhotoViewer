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
    
    private var categoryItems: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.categoryMenuView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        
        JsonFileLoader().loadJsonFile(resource: "SearchCategory", model: [Category].self, completionHandler: { searchCategory in
            self.categoryItems.append(contentsOf: searchCategory)
        })
    }
}

extension CategorySearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.categoryMenuView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.titleLabel.text = self.categoryItems[indexPath.row].categoryName
        return cell
    }
}

extension CategorySearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.categoryMenuView.deselectRow(at: indexPath, animated: true)
        
        let storyboard: UIStoryboard = UIStoryboard(name: "SearchResult", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchResult") as! SearchResultViewController
        vc.categoryQuery = self.categoryItems[indexPath.row].parameterName
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
