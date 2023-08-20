//
//  ViewController.swift
//  manga
//
//  Created by Ryosuke Takaoka on 2023/05/14.
//

import UIKit


class CreatingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    
    
    @IBOutlet var collectionView: UICollectionView!
    //    @IBOutlet weak var img: UIImageView! // 画像
    let illustration = ["ika", "kuma", "neko", "zyazi"]
    let titleLabelArray = ["1ページ目","2ページ目","3ページ目","4ページ目"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
       //collectionViewの表示設定
        let layout = UICollectionViewFlowLayout()
        //横スクロールに設定
        layout.scrollDirection = .horizontal
        //セルの大きさを設定
        layout.itemSize = CGSize(width: collectionView.frame.width - 32, height: collectionView.frame.height)
        // 隙間
                layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom:10, right: 16)
        layout.minimumLineSpacing = 16
        //それぞれの表示設定を適応させる
        collectionView.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell: UICollectionViewCell =
        collectionView.dequeueReusableCell(withReuseIdentifier: "creatingCell", for: indexPath)
        // Cellの中でTagが「1」のものをUIImageViewとして取得する
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        imageView.image = UIImage(named: illustration[indexPath.row])
        // Cellの中でTagが「2」のものをUILabelとして取得する
        let titleLabel = cell.contentView.viewWithTag(2) as! UILabel
        titleLabel.text = titleLabelArray[indexPath.row]
       return cell
    }
    @IBAction func returnAction(_ sender: Any) {
         dismiss(animated: true, completion: nil)
     }
    
}


