//
//  DetailsViewController.swift
//  manga2
//
//  Created by Ryosuke Takaoka on 2025/01/26.
//

import UIKit
import Firebase

class DetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let db = Firestore.firestore()
    var post: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.title = post.title
        
        // ③レイアウト設定をする（縦方向にスクロールするように設定&セルの間の距離を設定）
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal // スクロール方向
        layout.minimumLineSpacing = 0 // セル間の縦の間隔
        layout.minimumInteritemSpacing = 0 // セル間の横の間隔
        collectionView.collectionViewLayout = layout
        
        collectionView.register(UINib(nibName: "DetailsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "customCell")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.postImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //名前をCellにする
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! DetailsCollectionViewCell
        cell.postImageView.image = UIImage(url: post.postImages[indexPath.row])
        let borderColor = UIColor.black
        let borderWidth = 10.0
        // 左ボーダー
        let leftBorder = CALayer()
        leftBorder.name = "leftBorder"
        leftBorder.backgroundColor = borderColor.cgColor
        leftBorder.frame = CGRect(x: 0, y: 0, width: borderWidth, height: cell.frame.height)
        cell.layer.addSublayer(leftBorder)
        
        // 右ボーダー
        let rightBorder = CALayer()
        rightBorder.name = "rightBorder"
        rightBorder.backgroundColor = borderColor.cgColor
        rightBorder.frame = CGRect(x: cell.frame.width - borderWidth, y: 0, width: borderWidth, height: cell.frame.height)
        cell.layer.addSublayer(rightBorder)
        
        
        //cellを返却
        return cell
    }
    
    // ④ここでセルのサイズを調節する（インスタっぽく1:1にするならこんな感じ！）
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width // 横幅いっぱいにする
        let hight = collectionView.frame.height//縦幅いっぱいにする
        return CGSize(width: width, height: hight) // 縦幅いっぱいにする
    }
    
}
