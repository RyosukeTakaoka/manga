//
//  HouseViewController.swift
//  manga
//
//  Created by Ryosuke Takaoka on 2023/08/20.
//

import UIKit

class HouseViewController: UIViewController, UICollectionViewDelegate,
                           UICollectionViewDataSource {
    
    let spacer: CGFloat = 16
    
    @IBOutlet var collectionView: UICollectionView!
    // 表示する画像の配列
    let imageArray = ["ika","ika","ika","ika","ika"]
    // 表示するタイトルの配列
    let titleArray = ["ika","ika","ika","ika","ika"]
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        super.viewDidLoad()
        // 省略
        // collectionViewの表示設定

        let layout = UICollectionViewFlowLayout()
        // 縦スクロールに設定

        layout.scrollDirection = .vertical
        // セルの大きさ設定

        layout.itemSize = CGSize(width: view.frame.width / 2 - spacer * 2, height:
        view.frame.width / 2)
        // 余白の設定

        layout.sectionInset = UIEdgeInsets(top: spacer, left: spacer, bottom: spacer, right: spacer)
        // レイアウトをcollectionViewに適応させる

        collectionView.collectionViewLayout = layout
        
        // Do any additional setup after loading the view.
    }
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // imagesArrayの要素分表示する
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt
                        indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: UICollectionViewCell =
        collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        // Cellの中でTagが「1」のものをUIImageViewとして取得する
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        imageView.image = UIImage(named: imageArray[indexPath.row])
        
        // Cellの中でTagが「2」のものをUILabelとして取得する
        let titleLabel = cell.contentView.viewWithTag(2) as! UILabel
        titleLabel.text = titleArray[indexPath.row]
        
        return cell
        
    }
    // collectionviewでcellをタップした時
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //画面遷移をする
        performSegue(withIdentifier: "toCreatingVC", sender: nil)
    }
}
