//
//  UserViewController.swift
//  manga2
//
//  Created by Ryosuke Takaoka on 2024/01/28.
//

import UIKit

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var iconImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80
        
    
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! MainTableViewCell
        return cell
    }
//    let myImage = UIImage(named: "myImage") // 表示させたい画像
//    let imageWidth: CGFloat = 50 // 表示するときの幅
//
//    let imageView = UIImageView()
//    imageView.image = myImage?.cropResizedSquare(imageWidth)
//    imageView.layer.cornerRadius = imageWidth * 0.5
//    imageView.clipsToBounds = true
}
